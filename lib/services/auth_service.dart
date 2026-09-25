import 'package:dio/dio.dart';
import '../models/auth_models.dart';
import 'api_client.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  final Dio _dio = ApiClient.instance;

  Future<RegisterResult> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post("/auth/register", data: {
        "username": username,
        "email": email,
        "password": password,
      });
      return RegisterResult.fromJson(res.data);
    } on DioException catch (e) {
      throw AuthException(_extractError(e, "Registration failed"));
    }
  }

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post("/auth/login", data: {
        "email": email,
        "password": password,
      });
      return LoginResult.fromJson(res.data);
    } on DioException catch (e) {
      throw AuthException(_extractError(e, "Login failed"));
    }
  }

  String _extractError(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data["detail"] != null) {
      return data["detail"].toString();
    }
    return fallback;
  }
}
