/// Represents a message in the conversation history
class ConversationMessage {
  final String role; // 'user' or 'assistant'
  final String content;

  ConversationMessage({
    required this.role,
    required this.content,
  });

  /// Create a user message
  factory ConversationMessage.user(String content) {
    return ConversationMessage(role: 'user', content: content);
  }

  /// Create an assistant message
  factory ConversationMessage.assistant(String content) {
    return ConversationMessage(role: 'assistant', content: content);
  }

  @override
  String toString() => '$role: $content';
}


