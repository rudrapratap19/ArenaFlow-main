import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getters
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;
  bool get isAuthenticated => _auth.currentUser != null;

  // Auth Stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Collection References
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get teamsCollection => _firestore.collection('teams');
  CollectionReference get playersCollection => _firestore.collection('players');
  CollectionReference get matchesCollection => _firestore.collection('matches');
  CollectionReference get tournamentsCollection => _firestore.collection('tournaments');
  CollectionReference get tournamentMatchesCollection => 
      _firestore.collection('tournamentMatches');
  CollectionReference get performancesCollection => 
      _firestore.collection('performances');

  // Get document reference by ID
  DocumentReference getUserDoc(String uid) => usersCollection.doc(uid);
  DocumentReference getTeamDoc(String teamId) => teamsCollection.doc(teamId);
  DocumentReference getPlayerDoc(String playerId) => playersCollection.doc(playerId);
  DocumentReference getMatchDoc(String matchId) => matchesCollection.doc(matchId);
  DocumentReference getTournamentDoc(String tournamentId) => 
      tournamentsCollection.doc(tournamentId);
  DocumentReference getTournamentMatchDoc(String matchId) => 
      tournamentMatchesCollection.doc(matchId);
}
