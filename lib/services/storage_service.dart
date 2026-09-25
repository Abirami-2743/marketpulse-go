import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps flutter_secure_storage for storing the JWT returned by /auth/login.
class StorageService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = "auth_token";
  static const _userKey = "user_email";

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  static Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _userKey, value: email);
  }

  static Future<String?> getUserEmail() async {
    return _storage.read(key: _userKey);
  }

  static Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
