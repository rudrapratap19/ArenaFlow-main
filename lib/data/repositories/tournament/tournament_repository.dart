import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../../models/tournament/tournament_model.dart';
import '../../models/match/match_model.dart';
import '../../services/firebase/firebase_service.dart';

class TournamentRepository {
  final FirebaseService _firebaseService;

  TournamentRepository({required FirebaseService firebaseService})
      : _firebaseService = firebaseService;

  // Create Tournament
  Future<String> createTournament(TournamentModel tournament) async {
    final docRef = await _firebaseService.tournamentsCollection.add(tournament.toMap());
    return docRef.id;
  }

  // Get Tournament
  Future<TournamentModel?> getTournament(String tournamentId) async {
    final doc = await _firebaseService.getTournamentDoc(tournamentId).get();
    if (!doc.exists) return null;
    return TournamentModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  // Get All Tournaments - filtered by current user
  Stream<List<TournamentModel>> getAllTournaments() {
    final currentUserId = _firebaseService.currentUserId;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firebaseService.tournamentsCollection
        .where('createdBy', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
          final tournaments = snapshot.docs
              .map((doc) => TournamentModel.fromMap(
                  doc.id, doc.data() as Map<String, dynamic>))
              .toList();
          // Sort in memory
          tournaments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return tournaments;
        });
  }

  // Get All Tournaments for a specific admin
  Stream<List<TournamentModel>> getAllTournamentsByAdmin(String adminId) {
    if (adminId.isEmpty) {
      return Stream.value([]);
    }

    return _firebaseService.tournamentsCollection
        .where('createdBy', isEqualTo: adminId)
        .snapshots()
        .map((snapshot) {
          final tournaments = snapshot.docs
              .map((doc) => TournamentModel.fromMap(
                  doc.id, doc.data() as Map<String, dynamic>))
              .toList();
          tournaments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return tournaments;
        });
  }

  // Update Tournament
  Future<void> updateTournament(TournamentModel tournament) async {
    await _firebaseService.getTournamentDoc(tournament.id).update(tournament.toMap());
  }

  // Delete Tournament
  Future<void> deleteTournament(String tournamentId) async {
    // Delete all tournament matches first
    final matches = await _firebaseService.tournamentMatchesCollection
        .where('tournamentId', isEqualTo: tournamentId)
        .get();

    final linkedMatches = await _firebaseService.matchesCollection
        .where('tournamentId', isEqualTo: tournamentId)
        .get();

    final batch = _firebaseService.firestore.batch();
    for (var doc in matches.docs) {
      batch.delete(doc.reference);
    }
    for (var doc in linkedMatches.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_firebaseService.getTournamentDoc(tournamentId));
    await batch.commit();
  }

  // Generate Bracket
  Future<void> generateBracket(String tournamentId, TournamentType type,
      List<String> teamIds) async {
    // Fetch team names first
    final teamNames = <String, String>{};
    for (final teamId in teamIds) {
      final teamDoc = await _firebaseService.getTeamDoc(teamId).get();
      if (teamDoc.exists) {
        final teamData = teamDoc.data() as Map<String, dynamic>;
        teamNames[teamId] = teamData['name'] ?? teamId;
      } else {
        teamNames[teamId] = teamId;
      }
    }

    switch (type) {
      case TournamentType.singleElimination:
        await _generateSingleEliminationBracket(tournamentId, teamIds, teamNames);
        break;
      case TournamentType.doubleElimination:
        await _generateDoubleEliminationBracket(tournamentId, teamIds, teamNames);
        break;
      case TournamentType.roundRobin:
        await _generateRoundRobinBracket(tournamentId, teamIds, teamNames);
        break;
    }
  }

  Future<void> _generateSingleEliminationBracket(
      String tournamentId, List<String> teamIds, Map<String, String> teamNames) async {
    final shuffledTeams = List<String>.from(teamIds)..shuffle(Random());
    final totalTeams = shuffledTeams.length;
    final rounds = (log(totalTeams) / log(2)).ceil();
    final nextPowerOfTwo = pow(2, rounds).toInt();
    final byes = nextPowerOfTwo - totalTeams;

    List<String?> currentRoundTeams = List<String?>.from(shuffledTeams);
    for (int i = 0; i < byes; i++) {
      currentRoundTeams.add(null);
    }

    final batch = _firebaseService.firestore.batch();
    int matchPosition = 0;

    for (int round = 1; round <= rounds; round++) {
      final matchesInRound = currentRoundTeams.length ~/ 2;
      List<String?> nextRoundTeams = [];

      for (int i = 0; i < matchesInRound; i++) {
        final team1Id = currentRoundTeams[i * 2];
        final team2Id = currentRoundTeams[i * 2 + 1];

        if (team1Id != null && team2Id != null) {
          final matchData = {
            'tournamentId': tournamentId,
            'team1Id': team1Id,
            'team2Id': team2Id,
            'team1Name': teamNames[team1Id] ?? team1Id,
            'team2Name': teamNames[team2Id] ?? team2Id,
            'team1Score': 0,
            'team2Score': 0,
            'round': round,
            'position': matchPosition++,
            'matchType': _getMatchTypeForRound(round, rounds).toString(),
            'status': 'Scheduled',
            'venue': 'TBD',
            'scheduledTime': Timestamp.now(),
            'createdAt': Timestamp.now(),
            'createdBy': _firebaseService.currentUserId ?? '',
          };
          
          final matchRef = _firebaseService.tournamentMatchesCollection.doc();
          batch.set(matchRef, matchData);
          nextRoundTeams.add(null);
        } else {
          nextRoundTeams.add(team1Id ?? team2Id);
        }
      }

      currentRoundTeams = nextRoundTeams;
    }

    await batch.commit();
  }

  Future<void> _generateDoubleEliminationBracket(
      String tournamentId, List<String> teamIds, Map<String, String> teamNames) async {
    // Winner bracket
    await _generateSingleEliminationBracket(tournamentId, teamIds, teamNames);

    // Loser bracket (round 1 placeholders for first losers)
    final batch = _firebaseService.firestore.batch();
    int position = 0;
    for (int i = 0; i < teamIds.length; i += 2) {
      if (i + 1 >= teamIds.length) break;
      final matchRef = _firebaseService.tournamentMatchesCollection.doc();
      batch.set(matchRef, {
        'tournamentId': tournamentId,
        'team1Id': teamIds[i],
        'team2Id': teamIds[i + 1],
        'team1Name': teamNames[teamIds[i]] ?? teamIds[i],
        'team2Name': teamNames[teamIds[i + 1]] ?? teamIds[i + 1],
        'team1Score': 0,
        'team2Score': 0,
        'round': 1, // loser bracket round 1
        'position': position++,
        'matchType': MatchType.loserBracket.toString(),
        'status': 'Scheduled',
        'venue': 'TBD',
        'scheduledTime': Timestamp.now(),
        'createdAt': Timestamp.now(),
        'createdBy': _firebaseService.currentUserId ?? '',
      });
    }

    await batch.commit();
  }

  Future<void> _generateRoundRobinBracket(
      String tournamentId, List<String> teamIds, Map<String, String> teamNames) async {
    final batch = _firebaseService.firestore.batch();
    int matchPosition = 0;

    for (int i = 0; i < teamIds.length; i++) {
      for (int j = i + 1; j < teamIds.length; j++) {
        final matchData = {
          'tournamentId': tournamentId,
          'team1Id': teamIds[i],
          'team2Id': teamIds[j],
          'team1Name': teamNames[teamIds[i]] ?? teamIds[i],
          'team2Name': teamNames[teamIds[j]] ?? teamIds[j],
          'team1Score': 0,
          'team2Score': 0,
          'round': 1,
          'position': matchPosition++,
          'matchType': MatchType.groupStage.toString(),
          'status': 'Scheduled',
          'venue': 'TBD',
          'scheduledTime': Timestamp.now(),
          'createdAt': Timestamp.now(),
          'createdBy': _firebaseService.currentUserId ?? '',
        };

        final matchRef = _firebaseService.tournamentMatchesCollection.doc();
        batch.set(matchRef, matchData);
      }
    }

    await batch.commit();
  }

  MatchType _getMatchTypeForRound(int round, int totalRounds) {
    final roundsFromEnd = totalRounds - round;
    switch (roundsFromEnd) {
      case 0:
        return MatchType.final_;
      case 1:
        return MatchType.semiFinal;
      case 2:
        return MatchType.quarterFinal;
      case 3:
        return MatchType.roundOf16;
      default:
        return MatchType.groupStage;
    }
  }

  // Get Tournament Matches
  Stream<List<MatchModel>> getTournamentMatches(String tournamentId) {
    return _firebaseService.tournamentMatchesCollection
        .where('tournamentId', isEqualTo: tournamentId)
        .orderBy('round')
        .orderBy('position')
        .snapshots()
        .asyncMap((snapshot) async {
          final matches = <MatchModel>[];
          
          for (var doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            var team1Name = data['team1Name'] ?? '';
            var team2Name = data['team2Name'] ?? '';
            
            // Fetch team names from teams collection if not present
            if (team1Name.isEmpty && data['team1Id'] != null) {
              try {
                final teamDoc = await _firebaseService.getTeamDoc(data['team1Id']).get();
                if (teamDoc.exists) {
                  final teamData = teamDoc.data() as Map<String, dynamic>;
                  team1Name = teamData['name'] ?? '';
                }
              } catch (e) {
                // Keep empty if fetch fails
              }
            }
            
            if (team2Name.isEmpty && data['team2Id'] != null) {
              try {
                final teamDoc = await _firebaseService.getTeamDoc(data['team2Id']).get();
                if (teamDoc.exists) {
                  final teamData = teamDoc.data() as Map<String, dynamic>;
                  team2Name = teamData['name'] ?? '';
                }
              } catch (e) {
                // Keep empty if fetch fails
              }
            }
            
            // Update the data map with fetched names
            final updatedData = Map<String, dynamic>.from(data);
            if (team1Name.isNotEmpty) updatedData['team1Name'] = team1Name;
            if (team2Name.isNotEmpty) updatedData['team2Name'] = team2Name;
            
            matches.add(MatchModel.fromMap(doc.id, updatedData));
          }
          
          return matches;
        });
  }

  // Update Match Result
  Future<void> updateMatchResult(
      String matchId, int team1Score, int team2Score) async {
    String? winnerId;
    String? loserId;

    final matchDoc =
        await _firebaseService.getTournamentMatchDoc(matchId).get();
    if (!matchDoc.exists) return;

    final matchData = matchDoc.data() as Map<String, dynamic>;
    final team1Id = matchData['team1Id'];
    final team2Id = matchData['team2Id'];

    if (team1Score > team2Score) {
      winnerId = team1Id;
      loserId = team2Id;
    } else if (team2Score > team1Score) {
      winnerId = team2Id;
      loserId = team1Id;
    }

    await _firebaseService.getTournamentMatchDoc(matchId).update({
      'team1Score': team1Score,
      'team2Score': team2Score,
      if (winnerId != null) 'winnerId': winnerId,
      if (loserId != null) 'loserId': loserId,
      'status': 'Completed',
    });
  }

  // Get Standings (Round Robin)
  Future<List<Map<String, dynamic>>> getStandings(String tournamentId) async {
    final matches = await _firebaseService.tournamentMatchesCollection
        .where('tournamentId', isEqualTo: tournamentId)
        .where('status', isEqualTo: 'Completed')
        .get();

    Map<String, Map<String, dynamic>> standings = {};
    Map<String, String> teamNames = {};

    // First pass - collect all team IDs
    for (var doc in matches.docs) {
      final match = doc.data() as Map<String, dynamic>;
      final team1Id = match['team1Id'];
      final team2Id = match['team2Id'];
      if (!teamNames.containsKey(team1Id)) teamNames[team1Id] = '';
      if (!teamNames.containsKey(team2Id)) teamNames[team2Id] = '';
    }

    // Fetch team names from teams collection
    for (final teamId in teamNames.keys) {
      try {
        final teamDoc = await _firebaseService.getTeamDoc(teamId).get();
        if (teamDoc.exists) {
          final teamData = teamDoc.data() as Map<String, dynamic>;
          teamNames[teamId] = teamData['name'] ?? teamId;
        } else {
          teamNames[teamId] = teamId;
        }
      } catch (e) {
        teamNames[teamId] = teamId;
      }
    }

    // Second pass - process matches and build standings
    for (var doc in matches.docs) {
      final match = doc.data() as Map<String, dynamic>;
      final team1Id = match['team1Id'];
      final team2Id = match['team2Id'];
      final team1Score = match['team1Score'] ?? 0;
      final team2Score = match['team2Score'] ?? 0;
      final team1Name = teamNames[team1Id] ?? team1Id;
      final team2Name = teamNames[team2Id] ?? team2Id;

      standings.putIfAbsent(team1Id, () => {
        'teamId': team1Id,
        'teamName': team1Name,
        'played': 0,
        'won': 0,
        'drawn': 0,
        'lost': 0,
        'goalsFor': 0,
        'goalsAgainst': 0,
        'goalDifference': 0,
        'points': 0,
      });

      standings.putIfAbsent(team2Id, () => {
        'teamId': team2Id,
        'teamName': team2Name,
        'played': 0,
        'won': 0,
        'drawn': 0,
        'lost': 0,
        'goalsFor': 0,
        'goalsAgainst': 0,
        'goalDifference': 0,
        'points': 0,
      });

      standings[team1Id]!['played']++;
      standings[team2Id]!['played']++;
      standings[team1Id]!['goalsFor'] += team1Score;
      standings[team1Id]!['goalsAgainst'] += team2Score;
      standings[team2Id]!['goalsFor'] += team2Score;
      standings[team2Id]!['goalsAgainst'] += team1Score;

      if (team1Score > team2Score) {
        standings[team1Id]!['won']++;
        standings[team1Id]!['points'] += 3;
        standings[team2Id]!['lost']++;
      } else if (team2Score > team1Score) {
        standings[team2Id]!['won']++;
        standings[team2Id]!['points'] += 3;
        standings[team1Id]!['lost']++;
      } else {
        standings[team1Id]!['drawn']++;
        standings[team2Id]!['drawn']++;
        standings[team1Id]!['points']++;
        standings[team2Id]!['points']++;
      }

      standings[team1Id]!['goalDifference'] =
          standings[team1Id]!['goalsFor'] - standings[team1Id]!['goalsAgainst'];
      standings[team2Id]!['goalDifference'] =
          standings[team2Id]!['goalsFor'] - standings[team2Id]!['goalsAgainst'];
    }

    final standingsList = standings.values.toList();
    standingsList.sort((a, b) {
      final pointsCompare = b['points'].compareTo(a['points']);
      if (pointsCompare != 0) return pointsCompare;
      return b['goalDifference'].compareTo(a['goalDifference']);
    });

    return standingsList;
  }
}
