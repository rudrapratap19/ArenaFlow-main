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
        .orderBy('scheduledTime', descending: false)
        .snapshots()
        .map((snapshot) {
      final regularMatches = snapshot.docs
          .map((doc) =>
              MatchModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      return Future.wait([
        _getTournamentMatchesSnapshot(),
      ]).then((results) {
        final tournamentMatches = results[0] as List<MatchModel>;
        final allMatches = [...regularMatches, ...tournamentMatches];
        allMatches.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
        return allMatches;
      });
    }).asyncMap((future) => future);
  }

  // Get Live Matches (includes both regular and tournament matches)
  Stream<List<MatchModel>> getLiveMatches() {
    return _firebaseService.matchesCollection
        .where('status', isEqualTo: 'Live')
        .snapshots()
        .map((snapshot) {
      final regularMatches = snapshot.docs
          .map((doc) =>
              MatchModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      return Future.wait([
        _getTournamentMatchesByStatus('Live'),
      ]).then((results) {
        final tournamentMatches = results[0] as List<MatchModel>;
        return [...regularMatches, ...tournamentMatches];
      });
    }).asyncMap((future) => future);
  }

  // Get Scheduled Matches (includes both regular and tournament matches)
  Stream<List<MatchModel>> getScheduledMatches() {
    return _firebaseService.matchesCollection
        .where('status', isEqualTo: 'Scheduled')
        .orderBy('scheduledTime', descending: false)
        .snapshots()
        .map((snapshot) {
      final regularMatches = snapshot.docs
          .map((doc) =>
              MatchModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      return Future.wait([
        _getTournamentMatchesByStatus('Scheduled'),
      ]).then((results) {
        final tournamentMatches = results[0] as List<MatchModel>;
        final allMatches = [...regularMatches, ...tournamentMatches];
        allMatches.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
        return allMatches;
      });
    }).asyncMap((future) => future);
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
        .orderBy('scheduledTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                MatchModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
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
        .orderBy('scheduledTime', descending: false)
        .get();
    return snapshot.docs
        .map((doc) =>
            MatchModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Helper: Get tournament matches by status
  Future<List<MatchModel>> _getTournamentMatchesByStatus(String status) async {
    final snapshot = await _firebaseService.tournamentMatchesCollection
        .where('status', isEqualTo: status)
        .orderBy('scheduledTime', descending: false)
        .get();
    return snapshot.docs
        .map((doc) =>
            MatchModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }
}
