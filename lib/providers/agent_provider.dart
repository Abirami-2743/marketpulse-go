import 'package:flutter/foundation.dart';
import '../models/agent_models.dart';
import '../services/agent_service.dart';

class AgentProvider extends ChangeNotifier {
  final AgentService _agentService = AgentService();

  final List<ChatMessage> messages = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> sendQuestion(String question) async {
    if (question.trim().isEmpty) return;

    messages.add(ChatMessage(text: question, isUser: true, time: DateTime.now()));
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _agentService.ask(question.trim());
      messages.add(ChatMessage(text: result.answer, isUser: false, time: DateTime.now()));
    } catch (e) {
      errorMessage = e.toString();
      messages.add(ChatMessage(
        text: "Sorry, something went wrong: ${e.toString()}",
        isUser: false,
        time: DateTime.now(),
      ));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
