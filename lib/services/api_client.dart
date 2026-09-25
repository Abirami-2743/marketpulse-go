import 'package:dio/dio.dart';
import 'storage_service.dart';

/// Central Dio client for talking to the MarketPulse FastAPI backend.
/// Base URL points at the deployed Render instance.
class ApiClient {
  static const String baseUrl = "https://marketpulse-uols.onrender.com";

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {"Content-Type": "application/json"},
    ),
  );

  static Dio get instance {
    // Attach the auth interceptor only once.
    if (_dio.interceptors.isEmpty) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final token = await StorageService.getToken();
            if (token != null && token.isNotEmpty) {
              options.headers["Authorization"] = "Bearer $token";
            }
            return handler.next(options);
          },
          onError: (DioException e, handler) {
            // Centralized place to log / transform errors later if needed.
            return handler.next(e);
          },
        ),
      );
    }
    return _dio;
  }
}
