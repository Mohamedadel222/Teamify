import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  TokenStorage(this._secureStorage, this._prefs);

  static const _tokenKey = "auth_token";
  static const _refreshTokenKey = "refresh_token";
  static const _onboardingKey = "onboarding_seen";
  static const _roleKey = "user_role";

  // --- Access Token ---

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  // --- Refresh Token ---

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  // --- Save both tokens at once ---

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: _tokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  // --- Clear all auth tokens ---

  Future<void> clearAll() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  // --- App Settings (SharedPreferences) ---

  Future<void> saveOnboardingSeen() async {
    await _prefs.setBool(_onboardingKey, true);
  }

  bool isOnboardingSeen() {
    return _prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> saveUserRole(String role) async {
    await _prefs.setString(_roleKey, role);
  }

  String? getUserRole() {
    return _prefs.getString(_roleKey);
  }

  Future<void> resetFlow() async {
    await _secureStorage.deleteAll();
    await _prefs.clear();
  }
}