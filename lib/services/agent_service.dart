import 'package:dio/dio.dart';
import '../models/agent_models.dart';
import 'api_client.dart';

class AgentServiceException implements Exception {
  final String message;
  AgentServiceException(this.message);
  @override
  String toString() => message;
}

class AgentService {
  final Dio _dio = ApiClient.instance;

  Future<AgentAnswer> ask(String question) async {
    try {
      final res = await _dio.post("/agent/ask", data: {"question": question});
      return AgentAnswer.fromJson(res.data);
    } on DioException catch (e) {
      final data = e.response?.data;
      final detail = (data is Map && data["detail"] != null)
          ? data["detail"].toString()
          : "Agent error. Please try again.";
      throw AgentServiceException(detail);
    }
  }
}
