import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/match/match_model.dart';
import '../../services/firebase/firebase_service.dart';

class MatchRepository {
  final FirebaseService _firebaseService;

  MatchRepository({required FirebaseService firebaseService})
      : _firebaseService = firebaseService;

  // Create Match
  Future<String> createMatch(MatchModel match) async {
    final docRef = await _firebaseService.matchesCollection.add(match.toMap());
    return docRef.id;
  }

  // Get Match
  Future<MatchModel?> getMatch(String matchId) async {
    final doc = await _firebaseService.getMatchDoc(matchId).get();
    if (!doc.exists) return null;
    return MatchModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  // Get Match Stream
  Stream<MatchModel?> getMatchStream(String matchId) {
    return _firebaseService.getMatchDoc(matchId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return MatchModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    });
  }

  // Get All Matches (includes both regular and tournament matches)
  Stream<List<MatchModel>> getAllMatches() {
    return _firebaseService.matchesCollection
        .snapshots()
        .asyncMap((snapshot) async {
      final regularMatches = snapshot.docs
          .map((doc) =>
              MatchModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      final results = await Future.wait([
        _getTournamentMatchesSnapshot(),
      ]);
      final tournamentMatches = results[0] as List<MatchModel>;
      final allMatches = [...regularMatches, ...tournamentMatches];
      
      // Enrich with team names
      final enrichedMatches = await _enrichMatchesWithTeamNames(allMatches);
      
      // Sort in memory after fetching
      enrichedMatches.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
      return enrichedMatches;
    });
  }

  // Get Live Matches (includes both regular and tournament matches)
  Stream<List<MatchModel>> getLiveMatches() {
    return _firebaseService.matchesCollection
        .where('status', isEqualTo: 'Live')
        .snapshots()
        .asyncMap((snapshot) async {
      final regularMatches = snapshot.docs
          .map((doc) =>
              MatchModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      final results = await Future.wait([
        _getTournamentMatchesByStatus('Live'),
      ]);
      final tournamentMatches = results[0] as List<MatchModel>;
      final allMatches = [...regularMatches, ...tournamentMatches];
      
      // Enrich with team names
      final enrichedMatches = await _enrichMatchesWithTeamNames(allMatches);
      return enrichedMatches;
    });
  }

  // Get Scheduled Matches (includes both regular and tournament matches)
  Stream<List<MatchModel>> getScheduledMatches() {
    return _firebaseService.matchesCollection
        .where('status', isEqualTo: 'Scheduled')
        .snapshots()
        .asyncMap((snapshot) async {
      final regularMatches = snapshot.docs
          .map((doc) =>
              MatchModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      final results = await Future.wait([
        _getTournamentMatchesByStatus('Scheduled'),
      ]);
      final tournamentMatches = results[0] as List<MatchModel>;
      final allMatches = [...regularMatches, ...tournamentMatches];
      
      // Enrich with team names
      final enrichedMatches = await _enrichMatchesWithTeamNames(allMatches);
      
      // Sort in memory after fetching
      enrichedMatches.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
      return enrichedMatches;
    });
  }

  // Update Match
  Future<void> updateMatch(MatchModel match) async {
    await _firebaseService.getMatchDoc(match.id).update(match.toMap());
  }

  // Update Match Score
  Future<void> updateMatchScore(
      String matchId, int team1Score, int team2Score) async {
    String? winnerId;
    String? loserId;

    final matchDoc = await _firebaseService.getMatchDoc(matchId).get();
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

    await _firebaseService.getMatchDoc(matchId).update({
      'team1Score': team1Score,
      'team2Score': team2Score,
      if (winnerId != null) 'winnerId': winnerId,
      if (loserId != null) 'loserId': loserId,
    });
  }

  // Update Match Status
  Future<void> updateMatchStatus(String matchId, String status) async {
    await _firebaseService.getMatchDoc(matchId).update({'status': status});
  }

  // Delete Match
  Future<void> deleteMatch(String matchId) async {
    await _firebaseService.getMatchDoc(matchId).delete();
  }

  // Get Matches by Sport
  Stream<List<MatchModel>> getMatchesBySport(String sport) {
    return _firebaseService.matchesCollection
        .where('sport', isEqualTo: sport)
        .snapshots()
        .asyncMap((snapshot) async {
      final matches = snapshot.docs
          .map((doc) =>
              MatchModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      
      // Enrich with team names
      final enrichedMatches = await _enrichMatchesWithTeamNames(matches);
      
      // Sort in memory after fetching
      enrichedMatches.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
      return enrichedMatches;
    });
  }

  // Create Multiple Matches (Batch)
  Future<void> createMatches(List<MatchModel> matches) async {
    final batch = _firebaseService.firestore.batch();
    
    for (var match in matches) {
      final docRef = _firebaseService.matchesCollection.doc();
      batch.set(docRef, match.toMap());
    }
    
    await batch.commit();
  }

  // Helper: Get all tournament matches
  Future<List<MatchModel>> _getTournamentMatchesSnapshot() async {
    final snapshot = await _firebaseService.tournamentMatchesCollection
        .get();
    final matches = snapshot.docs
        .map((doc) =>
            MatchModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
    // Sort in memory after fetching
    matches.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    return matches;
  }

  // Helper: Get tournament matches by status
  Future<List<MatchModel>> _getTournamentMatchesByStatus(String status) async {
    final snapshot = await _firebaseService.tournamentMatchesCollection
        .where('status', isEqualTo: status)
        .get();
    final matches = snapshot.docs
        .map((doc) =>
            MatchModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
    // Sort in memory after fetching
    matches.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    return matches;
  }

  // Helper: Enrich matches with team names from teams collection
  Future<List<MatchModel>> _enrichMatchesWithTeamNames(List<MatchModel> matches) async {
    final enrichedMatches = <MatchModel>[];
    
    for (var match in matches) {
      String team1Name = match.team1Name;
      String team2Name = match.team2Name;
      
      // If team names are empty, try to fetch them from the teams collection
      if (team1Name.isEmpty && match.team1Id.isNotEmpty) {
        try {
          final doc = await _firebaseService.getTeamDoc(match.team1Id).get();
          if (doc.exists) {
            team1Name = doc.get('name') ?? match.team1Id;
          }
        } catch (e) {
          team1Name = match.team1Id;
        }
      }
      
      if (team2Name.isEmpty && match.team2Id.isNotEmpty) {
        try {
          final doc = await _firebaseService.getTeamDoc(match.team2Id).get();
          if (doc.exists) {
            team2Name = doc.get('name') ?? match.team2Id;
          }
        } catch (e) {
          team2Name = match.team2Id;
        }
      }
      
      // Create a new match with the enriched names
      enrichedMatches.add(match.copyWith(
        team1Name: team1Name,
        team2Name: team2Name,
      ));
    }
    
    return enrichedMatches;
  }

  // Add Commentary to Match
  Future<void> addCommentary(String matchId, Commentary commentary) async {
    final matchDoc = await _firebaseService.getMatchDoc(matchId).get();
    if (!matchDoc.exists) return;

    final matchData = matchDoc.data() as Map<String, dynamic>;
    final commentaries = List<Map<String, dynamic>>.from(
      (matchData['commentaries'] as List?) ?? [],
    );

    commentaries.add(commentary.toMap());

    await _firebaseService.getMatchDoc(matchId).update({
      'commentaries': commentaries,
    });
  }

  // Update Player Stats
  Future<void> updatePlayerStats(String matchId, PlayerStat playerStat) async {
    final matchDoc = await _firebaseService.getMatchDoc(matchId).get();
    if (!matchDoc.exists) return;

    final matchData = matchDoc.data() as Map<String, dynamic>;
    final playerStatsList = List<Map<String, dynamic>>.from(
      (matchData['playerStats'] as List?) ?? [],
    );

    // Check if player already exists, if yes update, else add
    final existingIndex = playerStatsList.indexWhere(
      (ps) => ps['playerName'] == playerStat.playerName,
    );

    if (existingIndex != -1) {
      playerStatsList[existingIndex] = playerStat.toMap();
    } else {
      playerStatsList.add(playerStat.toMap());
    }

    await _firebaseService.getMatchDoc(matchId).update({
      'playerStats': playerStatsList,
    });
  }

  // Get Player Stats for Match
  Future<List<PlayerStat>> getPlayerStats(String matchId) async {
    final matchDoc = await _firebaseService.getMatchDoc(matchId).get();
    if (!matchDoc.exists) return [];

    final matchData = matchDoc.data() as Map<String, dynamic>;
    final playerStatsData = matchData['playerStats'] as List? ?? [];

    return playerStatsData
        .asMap()
        .entries
        .map((e) => PlayerStat.fromMap(e.key.toString(), e.value as Map<String, dynamic>))
        .toList();
  }

  // Get Commentaries for Match
  Future<List<Commentary>> getCommentaries(String matchId) async {
    final matchDoc = await _firebaseService.getMatchDoc(matchId).get();
    if (!matchDoc.exists) return [];

    final matchData = matchDoc.data() as Map<String, dynamic>;
    final commentariesData = matchData['commentaries'] as List? ?? [];

    return commentariesData
        .asMap()
        .entries
        .map((e) => Commentary.fromMap(e.key.toString(), e.value as Map<String, dynamic>))
        .toList();
  }
}
