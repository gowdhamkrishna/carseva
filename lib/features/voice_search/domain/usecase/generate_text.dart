import 'package:carseva/features/voice_search/domain/models/conversation_message.dart';
import 'package:carseva/features/voice_search/domain/repositories/gemini_text_response.dart';

class GenerateText {
  final AiRepository repository;

  GenerateText(this.repository);

  /// Generate AI response with conversation history
  /// 
  /// [userQuery] - Current user's question/request
  /// [conversationHistory] - Previous conversation messages (last 3-5 turns)
  Future<String> call(
    String userQuery,
    List<ConversationMessage> conversationHistory,
  ) {
    return repository.generateText(userQuery, conversationHistory);
  }
}
