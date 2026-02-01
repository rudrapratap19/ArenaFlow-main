import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/team/team_model.dart';
import '../../models/team/player_model.dart';
import '../../services/firebase/firebase_service.dart';

class TeamRepository {
  final FirebaseService _firebaseService;

  TeamRepository({required FirebaseService firebaseService})
      : _firebaseService = firebaseService;

  // Create Team
  Future<String> createTeam(TeamModel team) async {
    final docRef = await _firebaseService.teamsCollection.add(team.toMap());
    return docRef.id;
  }

  // Get Team
  Future<TeamModel?> getTeam(String teamId) async {
    final doc = await _firebaseService.getTeamDoc(teamId).get();
    if (!doc.exists) return null;
    return TeamModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  // Get Teams by Sport - filtered by current user
  Stream<List<TeamModel>> getTeamsBySport(String sport) {
    final currentUserId = _firebaseService.currentUserId;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firebaseService.teamsCollection
        .where('createdBy', isEqualTo: currentUserId)
        .where('sport', isEqualTo: sport)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TeamModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get All Teams - filtered by current user
  Stream<List<TeamModel>> getAllTeams() {
    final currentUserId = _firebaseService.currentUserId;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firebaseService.teamsCollection
        .where('createdBy', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
          final teams = snapshot.docs
              .map((doc) => TeamModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();
          // Sort in memory
          teams.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return teams;
        });
  }

  // Update Team
  Future<void> updateTeam(TeamModel team) async {
    await _firebaseService.getTeamDoc(team.id).update(team.toMap());
  }

  // Delete Team
  Future<void> deleteTeam(String teamId) async {
    // Delete all players first
    final players = await _firebaseService.playersCollection
        .where('teamId', isEqualTo: teamId)
        .get();
    
    final batch = _firebaseService.firestore.batch();
    for (var doc in players.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_firebaseService.getTeamDoc(teamId));
    await batch.commit();
  }

  // Player Operations
  Future<String> addPlayer(PlayerModel player) async {
    final docRef = await _firebaseService.playersCollection.add(player.toMap());
    
    // Update team player count
    await _updateTeamPlayerCount(player.teamId);
    
    return docRef.id;
  }

  Future<PlayerModel?> getPlayer(String playerId) async {
    final doc = await _firebaseService.getPlayerDoc(playerId).get();
    if (!doc.exists) return null;
    return PlayerModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Stream<List<PlayerModel>> getTeamPlayers(String teamId) {
    final currentUserId = _firebaseService.currentUserId;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firebaseService.playersCollection
        .where('teamId', isEqualTo: teamId)
        .where('createdBy', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
          final players = snapshot.docs
              .map((doc) =>
                  PlayerModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();
          // Sort in memory
          players.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          return players;
        });
  }

  Future<void> updatePlayer(PlayerModel player) async {
    await _firebaseService.getPlayerDoc(player.id).update(player.toMap());
  }

  Future<void> deletePlayer(String playerId, String teamId) async {
    await _firebaseService.getPlayerDoc(playerId).delete();
    await _updateTeamPlayerCount(teamId);
  }

  Future<void> _updateTeamPlayerCount(String teamId) async {
    final players = await _firebaseService.playersCollection
        .where('teamId', isEqualTo: teamId)
        .get();
    
    await _firebaseService.getTeamDoc(teamId).update({
      'playerCount': players.docs.length,
    });
  }
}
