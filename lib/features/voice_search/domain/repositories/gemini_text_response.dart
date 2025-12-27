import '../models/conversation_message.dart';

abstract class AiRepository {
  /// Generate text response using the current user query and conversation history
  /// 
  /// [userQuery] - The current user's question/request
  /// [conversationHistory] - Previous conversation messages (last 3-5 turns)
  /// 
  /// Returns the AI's response text
  Future<String> generateText(
    String userQuery,
    List<ConversationMessage> conversationHistory,
  );
}
