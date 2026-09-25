import 'package:dio/dio.dart';
import '../models/market_models.dart';
import 'api_client.dart';

class MarketServiceException implements Exception {
  final String message;
  MarketServiceException(this.message);
  @override
  String toString() => message;
}

class MarketService {
  final Dio _dio = ApiClient.instance;

  Future<List<PriceItem>> getCrypto() async {
    try {
      final res = await _dio.get("/market/crypto");
      final List<dynamic> data = res.data["crypto"] ?? [];
      return data.map((e) => PriceItem.fromJson(e)).toList();
    } on DioException catch (e) {
      throw MarketServiceException(_friendlyMessage(e));
    }
  }

  Future<List<PriceItem>> getStocks() async {
    try {
      final res = await _dio.get("/market/stocks");
      final List<dynamic> data = res.data["stocks"] ?? [];
      return data.map((e) => PriceItem.fromJson(e)).toList();
    } on DioException catch (e) {
      throw MarketServiceException(_friendlyMessage(e));
    }
  }

  String _friendlyMessage(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return "The server is taking too long to respond.";
    }
    if (e.type == DioExceptionType.connectionError) {
      return "No internet connection.";
    }
    if (e.response?.statusCode == 500) {
      return "The server ran into a problem. Please try again shortly.";
    }
    return "Couldn't load market data.";
  }
}