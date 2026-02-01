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

  // Get All Matches (includes both regular and tournament matches) - filtered by current user
  Stream<List<MatchModel>> getAllMatches() {
    final currentUserId = _firebaseService.currentUserId;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firebaseService.matchesCollection
        .where('createdBy', isEqualTo: currentUserId)
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

  // Get All Matches for a specific admin
  Stream<List<MatchModel>> getAllMatchesByAdmin(String adminId) {
    if (adminId.isEmpty) {
      return Stream.value([]);
    }

    return _firebaseService.matchesCollection
        .where('createdBy', isEqualTo: adminId)
        .snapshots()
        .asyncMap((snapshot) async {
      final regularMatches = snapshot.docs
          .map((doc) =>
              MatchModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      final results = await Future.wait([
        _getTournamentMatchesSnapshotByAdmin(adminId),
      ]);
      final tournamentMatches = results[0] as List<MatchModel>;
      final allMatches = [...regularMatches, ...tournamentMatches];

      final enrichedMatches = await _enrichMatchesWithTeamNames(allMatches);
      enrichedMatches.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
      return enrichedMatches;
    });
  }

  // Get Live Matches (includes both regular and tournament matches) - filtered by current user
  Stream<List<MatchModel>> getLiveMatches() {
    final currentUserId = _firebaseService.currentUserId;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firebaseService.matchesCollection
        .where('createdBy', isEqualTo: currentUserId)
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

  // Get Live Matches for a specific admin
  Stream<List<MatchModel>> getLiveMatchesByAdmin(String adminId) {
    if (adminId.isEmpty) {
      return Stream.value([]);
    }

    return _firebaseService.matchesCollection
        .where('createdBy', isEqualTo: adminId)
        .where('status', isEqualTo: 'Live')
        .snapshots()
        .asyncMap((snapshot) async {
      final regularMatches = snapshot.docs
          .map((doc) =>
              MatchModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      final results = await Future.wait([
        _getTournamentMatchesByStatusAndAdmin('Live', adminId),
      ]);
      final tournamentMatches = results[0] as List<MatchModel>;
      final allMatches = [...regularMatches, ...tournamentMatches];

      final enrichedMatches = await _enrichMatchesWithTeamNames(allMatches);
      return enrichedMatches;
    });
  }

  // Get Scheduled Matches (includes both regular and tournament matches) - filtered by current user
  Stream<List<MatchModel>> getScheduledMatches() {
    final currentUserId = _firebaseService.currentUserId;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firebaseService.matchesCollection
        .where('createdBy', isEqualTo: currentUserId)
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

  // Get Scheduled Matches for a specific admin
  Stream<List<MatchModel>> getScheduledMatchesByAdmin(String adminId) {
    if (adminId.isEmpty) {
      return Stream.value([]);
    }

    return _firebaseService.matchesCollection
        .where('createdBy', isEqualTo: adminId)
        .where('status', isEqualTo: 'Scheduled')
        .snapshots()
        .asyncMap((snapshot) async {
      final regularMatches = snapshot.docs
          .map((doc) =>
              MatchModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      final results = await Future.wait([
        _getTournamentMatchesByStatusAndAdmin('Scheduled', adminId),
      ]);
      final tournamentMatches = results[0] as List<MatchModel>;
      final allMatches = [...regularMatches, ...tournamentMatches];

      final enrichedMatches = await _enrichMatchesWithTeamNames(allMatches);
      enrichedMatches.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
      return enrichedMatches;
    });
  }

  // Get Matches for a Specific Tournament
  Stream<List<MatchModel>> getTournamentMatches(String tournamentId) {
    return _firebaseService.tournamentMatchesCollection
        .where('tournamentId', isEqualTo: tournamentId)
        .snapshots()
        .asyncMap((snapshot) async {
      final matches = snapshot.docs
          .map((doc) =>
              MatchModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      
      final enrichedMatches = await _enrichMatchesWithTeamNames(matches);
      enrichedMatches.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
      return enrichedMatches;
    });
  }

  // Update Match
  Future<void> updateMatch(MatchModel match) async {
    print('[DEBUG] Updating match: ${match.id}');
    
    try {
      // Try regular matches collection first
      var matchDoc = await _firebaseService.getMatchDoc(match.id).get();
      DocumentReference docRef = _firebaseService.getMatchDoc(match.id);
      
      print('[DEBUG] Match exists in regular collection: ${matchDoc.exists}');
      
      // If not found, try tournament matches collection
      if (!matchDoc.exists) {
        matchDoc = await _firebaseService.getTournamentMatchDoc(match.id).get();
        docRef = _firebaseService.getTournamentMatchDoc(match.id);
        print('[DEBUG] Match exists in tournament collection: ${matchDoc.exists}');
      }
      
      if (!matchDoc.exists) {
        print('[DEBUG] Match not found in any collection');
        return;
      }

      await docRef.update(match.toMap());
      print('[DEBUG] Match updated successfully');
    } catch (e) {
      print('[ERROR] Failed to update match: $e');
      rethrow;
    }
  }

  // Update Match Score
  Future<void> updateMatchScore(
      String matchId, int team1Score, int team2Score) async {
    print('[DEBUG] Updating match score for matchId: $matchId');
    print('[DEBUG] Scores - Team1: $team1Score, Team2: $team2Score');
    
    try {
      String? winnerId;
      String? loserId;

      // Try regular matches collection first
      var matchDoc = await _firebaseService.getMatchDoc(matchId).get();
      DocumentReference docRef = _firebaseService.getMatchDoc(matchId);
      
      print('[DEBUG] Match exists in regular collection: ${matchDoc.exists}');
      
      // If not found, try tournament matches collection
      if (!matchDoc.exists) {
        matchDoc = await _firebaseService.getTournamentMatchDoc(matchId).get();
        docRef = _firebaseService.getTournamentMatchDoc(matchId);
        print('[DEBUG] Match exists in tournament collection: ${matchDoc.exists}');
      }
      
      if (!matchDoc.exists) {
        print('[DEBUG] Match not found in any collection');
        return;
      }

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

      await docRef.update({
        'team1Score': team1Score,
        'team2Score': team2Score,
        if (winnerId != null) 'winnerId': winnerId,
        if (loserId != null) 'loserId': loserId,
      });
      
      print('[DEBUG] Match score updated successfully');
    } catch (e) {
      print('[ERROR] Failed to update match score: $e');
      rethrow;
    }
  }

  // Update Match Status
  Future<void> updateMatchStatus(String matchId, String status) async {
    print('[DEBUG] Updating match status for matchId: $matchId to $status');
    
    try {
      // Try regular matches collection first
      var matchDoc = await _firebaseService.getMatchDoc(matchId).get();
      DocumentReference docRef = _firebaseService.getMatchDoc(matchId);
      
      print('[DEBUG] Match exists in regular collection: ${matchDoc.exists}');
      
      // If not found, try tournament matches collection
      if (!matchDoc.exists) {
        matchDoc = await _firebaseService.getTournamentMatchDoc(matchId).get();
        docRef = _firebaseService.getTournamentMatchDoc(matchId);
        print('[DEBUG] Match exists in tournament collection: ${matchDoc.exists}');
      }
      
      if (!matchDoc.exists) {
        print('[DEBUG] Match not found in any collection');
        return;
      }

      await docRef.update({'status': status});
      print('[DEBUG] Match status updated successfully');
    } catch (e) {
      print('[ERROR] Failed to update match status: $e');
      rethrow;
    }
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

  // Helper: Get all tournament matches - filtered by current user
  Future<List<MatchModel>> _getTournamentMatchesSnapshot() async {
    final currentUserId = _firebaseService.currentUserId;
    if (currentUserId == null) {
      return [];
    }

    final snapshot = await _firebaseService.tournamentMatchesCollection
        .where('createdBy', isEqualTo: currentUserId)
        .get();
    final matches = snapshot.docs
        .map((doc) =>
            MatchModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
    // Sort in memory after fetching
    matches.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    return matches;
  }

  // Helper: Get all tournament matches for a specific admin
  Future<List<MatchModel>> _getTournamentMatchesSnapshotByAdmin(String adminId) async {
    if (adminId.isEmpty) {
      return [];
    }

    final snapshot = await _firebaseService.tournamentMatchesCollection
        .where('createdBy', isEqualTo: adminId)
        .get();
    final matches = snapshot.docs
        .map((doc) =>
            MatchModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
    matches.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    return matches;
  }

  // Helper: Get tournament matches by status - filtered by current user
  Future<List<MatchModel>> _getTournamentMatchesByStatus(String status) async {
    final currentUserId = _firebaseService.currentUserId;
    if (currentUserId == null) {
      return [];
    }

    final snapshot = await _firebaseService.tournamentMatchesCollection
        .where('createdBy', isEqualTo: currentUserId)
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

  // Helper: Get tournament matches by status for a specific admin
  Future<List<MatchModel>> _getTournamentMatchesByStatusAndAdmin(
      String status, String adminId) async {
    if (adminId.isEmpty) {
      return [];
    }

    final snapshot = await _firebaseService.tournamentMatchesCollection
        .where('createdBy', isEqualTo: adminId)
        .where('status', isEqualTo: status)
        .get();
    final matches = snapshot.docs
        .map((doc) =>
            MatchModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
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
    print('[DEBUG] Adding commentary for matchId: $matchId');
    print('[DEBUG] Commentary: ${commentary.toMap()}');
    
    try {
      // Try regular matches collection first
      var matchDoc = await _firebaseService.getMatchDoc(matchId).get();
      DocumentReference docRef = _firebaseService.getMatchDoc(matchId);
      
      print('[DEBUG] Match exists in regular collection: ${matchDoc.exists}');
      
      // If not found, try tournament matches collection
      if (!matchDoc.exists) {
        matchDoc = await _firebaseService.getTournamentMatchDoc(matchId).get();
        docRef = _firebaseService.getTournamentMatchDoc(matchId);
        print('[DEBUG] Match exists in tournament collection: ${matchDoc.exists}');
      }
      
      if (!matchDoc.exists) {
        print('[DEBUG] Match not found in any collection');
        return;
      }

      final matchData = matchDoc.data() as Map<String, dynamic>;
      final commentaries = List<Map<String, dynamic>>.from(
        (matchData['commentaries'] as List?) ?? [],
      );

      print('[DEBUG] Current commentaries count: ${commentaries.length}');
      
      commentaries.add(commentary.toMap());

      print('[DEBUG] Updating document with ${commentaries.length} commentaries');
      
      await docRef.update({
        'commentaries': commentaries,
      });
      
      print('[DEBUG] Commentary added successfully');
    } catch (e) {
      print('[ERROR] Failed to add commentary: $e');
      rethrow;
    }
  }

  // Update Player Stats
  Future<void> updatePlayerStats(String matchId, PlayerStat playerStat) async {
    print('[DEBUG] Updating player stats for matchId: $matchId');
    print('[DEBUG] Player: ${playerStat.playerName}, Goals: ${playerStat.goals}');
    
    try {
      // Try regular matches collection first
      var matchDoc = await _firebaseService.getMatchDoc(matchId).get();
      DocumentReference docRef = _firebaseService.getMatchDoc(matchId);
      
      print('[DEBUG] Match exists in regular collection: ${matchDoc.exists}');
      
      // If not found, try tournament matches collection
      if (!matchDoc.exists) {
        matchDoc = await _firebaseService.getTournamentMatchDoc(matchId).get();
        docRef = _firebaseService.getTournamentMatchDoc(matchId);
        print('[DEBUG] Match exists in tournament collection: ${matchDoc.exists}');
      }
      
      if (!matchDoc.exists) {
        print('[DEBUG] Match not found in any collection');
        return;
      }

      final matchData = matchDoc.data() as Map<String, dynamic>;
      final playerStatsList = List<Map<String, dynamic>>.from(
        (matchData['playerStats'] as List?) ?? [],
      );

      print('[DEBUG] Current player stats count: ${playerStatsList.length}');
      
      // Check if player already exists, if yes update, else add
      final existingIndex = playerStatsList.indexWhere(
        (ps) => ps['playerName'] == playerStat.playerName,
      );

      if (existingIndex != -1) {
        print('[DEBUG] Updating existing player at index $existingIndex');
        playerStatsList[existingIndex] = playerStat.toMap();
      } else {
        print('[DEBUG] Adding new player to stats list');
        playerStatsList.add(playerStat.toMap());
      }

      print('[DEBUG] Updating document with ${playerStatsList.length} player stats');
      
      await docRef.update({
        'playerStats': playerStatsList,
      });
      
      print('[DEBUG] Player stats updated successfully');
    } catch (e) {
      print('[ERROR] Failed to update player stats: $e');
      rethrow;
    }
  }

  // Get Player Stats for Match
  Future<List<PlayerStat>> getPlayerStats(String matchId) async {
    // Try regular matches collection first
    var matchDoc = await _firebaseService.getMatchDoc(matchId).get();
    
    // If not found, try tournament matches collection
    if (!matchDoc.exists) {
      matchDoc = await _firebaseService.getTournamentMatchDoc(matchId).get();
    }
    
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
    // Try regular matches collection first
    var matchDoc = await _firebaseService.getMatchDoc(matchId).get();
    
    // If not found, try tournament matches collection
    if (!matchDoc.exists) {
      matchDoc = await _firebaseService.getTournamentMatchDoc(matchId).get();
    }
    
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
