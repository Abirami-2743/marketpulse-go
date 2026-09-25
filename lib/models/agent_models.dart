/// Response shape from POST /agent/ask -> {"answer": "...", "status": "success"}
/// IMPORTANT: the backend returns a plain text answer, not structured
/// risk/trend/confidence fields. The UI renders this as a text card.
class AgentAnswer {
  final String answer;
  final String status;

  AgentAnswer({required this.answer, required this.status});

  factory AgentAnswer.fromJson(Map<String, dynamic> json) {
    return AgentAnswer(
      answer: json["answer"] ?? "",
      status: json["status"] ?? "unknown",
    );
  }
}

/// A single message bubble in the agent chat UI (local state only,
/// not persisted to backend).
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, required this.time});
}
