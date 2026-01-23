import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Remember Me
  Future<void> setRememberMe(bool value) async {
    await _prefs?.setBool(AppConstants.keyRememberMe, value);
  }

  bool getRememberMe() {
    return _prefs?.getBool(AppConstants.keyRememberMe) ?? true;
  }

  // User Credentials
  Future<void> saveCredentials(String email, String password) async {
    await _prefs?.setString(AppConstants.keyUserEmail, email);
    await _prefs?.setString(AppConstants.keyUserPassword, password);
  }

  Future<void> clearCredentials() async {
    await _prefs?.remove(AppConstants.keyUserEmail);
    await _prefs?.remove(AppConstants.keyUserPassword);
  }

  String? getSavedEmail() {
    return _prefs?.getString(AppConstants.keyUserEmail);
  }

  String? getSavedPassword() {
    return _prefs?.getString(AppConstants.keyUserPassword);
  }

  // User Session
  Future<void> saveUserSession(String userId, String role) async {
    await _prefs?.setString(AppConstants.keyUserId, userId);
    await _prefs?.setString(AppConstants.keyUserRole, role);
  }

  Future<void> clearUserSession() async {
    await _prefs?.remove(AppConstants.keyUserId);
    await _prefs?.remove(AppConstants.keyUserRole);
  }

  String? getUserId() {
    return _prefs?.getString(AppConstants.keyUserId);
  }

  String? getUserRole() {
    return _prefs?.getString(AppConstants.keyUserRole);
  }

  // Clear All
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
