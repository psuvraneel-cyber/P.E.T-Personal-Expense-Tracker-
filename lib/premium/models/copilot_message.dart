class CopilotMessage {
  final String role; // user, assistant
  final String content;
  final DateTime createdAt;

  CopilotMessage({
    required this.role,
    required this.content,
    required this.createdAt,
  });
}
