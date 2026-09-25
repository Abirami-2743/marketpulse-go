import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus status = AuthStatus.unknown;
  bool isLoading = false;
  String? errorMessage;
  String? userEmail;

  Future<void> checkLoginStatus() async {
    final loggedIn = await StorageService.isLoggedIn();
    userEmail = await StorageService.getUserEmail();
    status = loggedIn ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await _authService.login(email: email, password: password);
      await StorageService.saveToken(result.token);
      await StorageService.saveUserEmail(email);
      userEmail = email;
      status = AuthStatus.authenticated;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e is DioException
          ? "Couldn't reach the server. Check your connection."
          : e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _authService.register(username: username, email: email, password: password);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e is DioException
          ? "Couldn't reach the server. Check your connection."
          : e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await StorageService.clear();
    status = AuthStatus.unauthenticated;
    userEmail = null;
    notifyListeners();
  }
}