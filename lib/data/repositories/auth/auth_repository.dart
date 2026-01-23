import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_constants.dart';
import '../../models/auth/user_model.dart';
import '../../services/firebase/firebase_service.dart';
import '../../services/firebase/local_storage_service.dart';

class AuthRepository {
  final FirebaseService _firebaseService;
  final LocalStorageService _localStorageService;

  AuthRepository({
    required FirebaseService firebaseService,
    required LocalStorageService localStorageService,
  })  : _firebaseService = firebaseService,
        _localStorageService = localStorageService;

  // Auth State Stream
  Stream<User?> get authStateChanges => _firebaseService.authStateChanges;

  // Current User
  User? get currentUser => _firebaseService.currentUser;
  String? get currentUserId => _firebaseService.currentUserId;
  bool get isAuthenticated => _firebaseService.isAuthenticated;

  // Sign In
  Future<UserModel> signIn(String email, String password, bool rememberMe) async {
    try {
      final userCredential = await _firebaseService.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      final userDoc = await _firebaseService.getUserDoc(uid).get();

      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      final userData = UserModel.fromMap(uid, userDoc.data() as Map<String, dynamic>);

      // Save credentials if remember me is checked
      if (rememberMe) {
        await _localStorageService.setRememberMe(true);
        await _localStorageService.saveCredentials(email, password);
      } else {
        await _localStorageService.setRememberMe(false);
        await _localStorageService.clearCredentials();
      }

      // Save user session
      await _localStorageService.saveUserSession(uid, userData.role);

      return userData;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign Up
  Future<UserModel> signUp(String name, String email, String password, String role) async {
    try {
      final userCredential = await _firebaseService.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      final userData = UserModel(
        uid: uid,
        name: name,
        email: email,
        role: role,
        createdAt: DateTime.now(),
      );

      await _firebaseService.getUserDoc(uid).set(userData.toMap());
      await _localStorageService.saveUserSession(uid, role);

      return userData;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _firebaseService.auth.signOut();
    await _localStorageService.clearUserSession();
  }

  // Get User Data
  Future<UserModel> getUserData(String uid) async {
    try {
      final userDoc = await _firebaseService.getUserDoc(uid).get();

      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      return UserModel.fromMap(uid, userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseService.auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Check Auth State
  Future<UserModel?> checkAuthState() async {
    try {
      final user = _firebaseService.currentUser;
      if (user == null) return null;

      return await getUserData(user.uid);
    } catch (e) {
      return null;
    }
  }

  // Get Saved Credentials
  Map<String, String?> getSavedCredentials() {
    return {
      'email': _localStorageService.getSavedEmail(),
      'password': _localStorageService.getSavedPassword(),
    };
  }

  bool getRememberMe() {
    return _localStorageService.getRememberMe();
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}
