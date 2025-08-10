import 'package:cloud_firestore/cloud_firestore.dart';
import 'tournament_models.dart';
import 'dart:math';

class TournamentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new tournament
  Future<String> createTournament({
    required String name,
    required String sport,
    required TournamentType type,
    required DateTime startDate,
    required List<String> teamIds,
    required String createdBy,
    Map<String, dynamic> settings = const {},
  }) async {
    final tournament = Tournament(
      id: '',
      name: name,
      sport: sport,
      type: type,
      status: TournamentStatus.registration,
      startDate: startDate,
      teamIds: teamIds,
      settings: settings,
      createdAt: DateTime.now(),
      createdBy: createdBy,
    );

    final docRef = await _firestore.collection('tournaments').add(tournament.toMap());
    return docRef.id;
  }

  // Generate bracket for single elimination
  Future<void> generateSingleEliminationBracket(String tournamentId, List<String> teamIds) async {
    final shuffledTeams = List<String>.from(teamIds)..shuffle(Random());
    
    // Calculate rounds needed
    final totalTeams = shuffledTeams.length;
    final rounds = (log(totalTeams) / log(2)).ceil();
    
    // Add byes if needed
    final nextPowerOfTwo = pow(2, rounds).toInt();
    final byes = nextPowerOfTwo - totalTeams;
    
    List<String?> currentRoundTeams = List<String?>.from(shuffledTeams);
    
    // Add null entries for byes
    for (int i = 0; i < byes; i++) {
      currentRoundTeams.add(null);
    }

    final batch = _firestore.batch();
    
    for (int round = 1; round <= rounds; round++) {
      final matchesInRound = currentRoundTeams.length ~/ 2;
      List<String?> nextRoundTeams = [];
      
      for (int match = 0; match < matchesInRound; match++) {
        final team1Index = match * 2;
        final team2Index = match * 2 + 1;
        
        final team1Id = team1Index < currentRoundTeams.length ? currentRoundTeams[team1Index] : null;
        final team2Id = team2Index < currentRoundTeams.length ? currentRoundTeams[team2Index] : null;
        
        // Get team names
        String? team1Name, team2Name;
        if (team1Id != null) {
          final team1Doc = await _firestore.collection('teams').doc(team1Id).get();
          team1Name = team1Doc.data()?['teamName'];
        }
        if (team2Id != null) {
          final team2Doc = await _firestore.collection('teams').doc(team2Id).get();
          team2Name = team2Doc.data()?['teamName'];
        }
        
        // Handle byes
        if (team1Id == null && team2Id != null) {
          nextRoundTeams.add(team2Id);
          continue;
        } else if (team2Id == null && team1Id != null) {
          nextRoundTeams.add(team1Id);
          continue;
        } else if (team1Id == null && team2Id == null) {
          nextRoundTeams.add(null);
          continue;
        }

        final matchType = _getMatchTypeForRound(round, rounds);
        
        final tournamentMatch = TournamentMatch(
          id: '',
          tournamentId: tournamentId,
          team1Id: team1Id,
          team2Id: team2Id,
          team1Name: team1Name,
          team2Name: team2Name,
          matchType: matchType,
          round: round,
          position: match,
          status: 'Scheduled',
          venue: 'TBD',
          metadata: {},
        );

        final matchRef = _firestore.collection('tournamentMatches').doc();
        batch.set(matchRef, tournamentMatch.toMap());
        
        nextRoundTeams.add(null); // Placeholder for winner
      }
      
      currentRoundTeams = nextRoundTeams;
    }

    await batch.commit();
  }

  // Generate bracket for round robin
  Future<void> generateRoundRobinBracket(String tournamentId, List<String> teamIds) async {
    final batch = _firestore.batch();
    int matchPosition = 0;

    // Generate all possible matches
    for (int i = 0; i < teamIds.length; i++) {
      for (int j = i + 1; j < teamIds.length; j++) {
        final team1Id = teamIds[i];
        final team2Id = teamIds[j];
        
        // Get team names
        final team1Doc = await _firestore.collection('teams').doc(team1Id).get();
        final team2Doc = await _firestore.collection('teams').doc(team2Id).get();
        
        final team1Name = team1Doc.data()?['teamName'];
        final team2Name = team2Doc.data()?['teamName'];

        final tournamentMatch = TournamentMatch(
          id: '',
          tournamentId: tournamentId,
          team1Id: team1Id,
          team2Id: team2Id,
          team1Name: team1Name,
          team2Name: team2Name,
          matchType: MatchType.groupStage,
          round: 1,
          position: matchPosition++,
          status: 'Scheduled',
          venue: 'TBD',
          metadata: {},
        );

        final matchRef = _firestore.collection('tournamentMatches').doc();
        batch.set(matchRef, tournamentMatch.toMap());
      }
    }

    await batch.commit();
  }

  // Update match result and progress bracket
  Future<void> updateMatchResult({
    required String matchId,
    required int team1Score,
    required int team2Score,
    String? winnerId,
  }) async {
    final batch = _firestore.batch();
    
    final matchRef = _firestore.collection('tournamentMatches').doc(matchId);
    final matchDoc = await matchRef.get();
    
    if (!matchDoc.exists) throw Exception('Match not found');
    
    final match = TournamentMatch.fromMap(matchDoc.id, matchDoc.data()!);
    
    // Determine winner
    String? actualWinnerId = winnerId;
    String? loserId;
    
    if (actualWinnerId == null) {
      if (team1Score > team2Score) {
        actualWinnerId = match.team1Id;
        loserId = match.team2Id;
      } else if (team2Score > team1Score) {
        actualWinnerId = match.team2Id;
        loserId = match.team1Id;
      }
      // Handle tie - you might want to implement tie-breaking rules
    }

    // Update current match
    batch.update(matchRef, {
      'team1Score': team1Score,
      'team2Score': team2Score,
      'winnerId': actualWinnerId,
      'loserId': loserId,
      'status': 'Completed',
    });

    // Progress winner to next round (for elimination tournaments)
    if (actualWinnerId != null) {
      await _progressWinnerToNextRound(batch, match, actualWinnerId);
    }

    await batch.commit();
  }

  // Progress winner to next round
  Future<void> _progressWinnerToNextRound(
    WriteBatch batch, 
    TournamentMatch completedMatch, 
    String winnerId,
  ) async {
    final tournament = await _firestore
        .collection('tournaments')
        .doc(completedMatch.tournamentId)
        .get();
    
    final tournamentData = Tournament.fromMap(tournament.id, tournament.data()!);
    
    if (tournamentData.type == TournamentType.singleElimination) {
      // Find next match in single elimination
      final nextRound = completedMatch.round + 1;
      final nextPosition = completedMatch.position ~/ 2;
      
      final nextMatchQuery = await _firestore
          .collection('tournamentMatches')
          .where('tournamentId', isEqualTo: completedMatch.tournamentId)
          .where('round', isEqualTo: nextRound)
          .where('position', isEqualTo: nextPosition)
          .limit(1)
          .get();

      if (nextMatchQuery.docs.isNotEmpty) {
        final nextMatchRef = nextMatchQuery.docs.first.reference;
        final nextMatch = TournamentMatch.fromMap(
          nextMatchQuery.docs.first.id, 
          nextMatchQuery.docs.first.data(),
        );

        // Get winner team data
        final winnerTeamDoc = await _firestore.collection('teams').doc(winnerId).get();
        final winnerTeamName = winnerTeamDoc.data()?['teamName'];

        // Determine if winner goes to team1 or team2 slot
        if (completedMatch.position % 2 == 0) {
          // Even position -> team1 in next match
          batch.update(nextMatchRef, {
            'team1Id': winnerId,
            'team1Name': winnerTeamName,
          });
        } else {
          // Odd position -> team2 in next match
          batch.update(nextMatchRef, {
            'team2Id': winnerId,
            'team2Name': winnerTeamName,
          });
        }
      }
    }
  }

  MatchType _getMatchTypeForRound(int round, int totalRounds) {
    final remainingRounds = totalRounds - round + 1;
    switch (remainingRounds) {
      case 1:
        return MatchType.finall;
      case 2:
        return MatchType.semiFinal;
      case 3:
        return MatchType.quarterFinal;
      default:
        return MatchType.roundOf16;
    }
  }

  // Get tournament standings for round robin
  Future<List<Map<String, dynamic>>> getRoundRobinStandings(String tournamentId) async {
    final matches = await _firestore
        .collection('tournamentMatches')
        .where('tournamentId', isEqualTo: tournamentId)
        .where('status', isEqualTo: 'Completed')
        .get();

    Map<String, Map<String, dynamic>> standings = {};

    for (var matchDoc in matches.docs) {
      final match = TournamentMatch.fromMap(matchDoc.id, matchDoc.data());
      
      // Initialize team stats if not exists
      if (match.team1Id != null) {
        standings[match.team1Id!] ??= {
          'teamId': match.team1Id,
          'teamName': match.team1Name,
          'played': 0,
          'won': 0,
          'drawn': 0,
          'lost': 0,
          'goalsFor': 0,
          'goalsAgainst': 0,
          'goalDifference': 0,
          'points': 0,
        };
      }
      
      if (match.team2Id != null) {
        standings[match.team2Id!] ??= {
          'teamId': match.team2Id,
          'teamName': match.team2Name,
          'played': 0,
          'won': 0,
          'drawn': 0,
          'lost': 0,
          'goalsFor': 0,
          'goalsAgainst': 0,
          'goalDifference': 0,
          'points': 0,
        };
      }

      // Update stats
      if (match.team1Id != null && match.team2Id != null) {
        standings[match.team1Id!]!['played']++;
        standings[match.team2Id!]!['played']++;
        
        standings[match.team1Id!]!['goalsFor'] += match.team1Score;
        standings[match.team1Id!]!['goalsAgainst'] += match.team2Score;
        standings[match.team2Id!]!['goalsFor'] += match.team2Score;
        standings[match.team2Id!]!['goalsAgainst'] += match.team1Score;

        if (match.team1Score > match.team2Score) {
          standings[match.team1Id!]!['won']++;
          standings[match.team1Id!]!['points'] += 3;
          standings[match.team2Id!]!['lost']++;
        } else if (match.team2Score > match.team1Score) {
          standings[match.team2Id!]!['won']++;
          standings[match.team2Id!]!['points'] += 3;
          standings[match.team1Id!]!['lost']++;
        } else {
          standings[match.team1Id!]!['drawn']++;
          standings[match.team1Id!]!['points'] += 1;
          standings[match.team2Id!]!['drawn']++;
          standings[match.team2Id!]!['points'] += 1;
        }

        // Update goal difference
        standings[match.team1Id!]!['goalDifference'] = 
            standings[match.team1Id!]!['goalsFor'] - standings[match.team1Id!]!['goalsAgainst'];
        standings[match.team2Id!]!['goalDifference'] = 
            standings[match.team2Id!]!['goalsFor'] - standings[match.team2Id!]!['goalsAgainst'];
      }
    }

    // Sort standings
    final sortedStandings = standings.values.toList();
    sortedStandings.sort((a, b) {
      // Sort by points, then goal difference, then goals for
      if (a['points'] != b['points']) {
        return b['points'].compareTo(a['points']);
      }
      if (a['goalDifference'] != b['goalDifference']) {
        return b['goalDifference'].compareTo(a['goalDifference']);
      }
      return b['goalsFor'].compareTo(a['goalsFor']);
    });

    return sortedStandings;
  }
}
