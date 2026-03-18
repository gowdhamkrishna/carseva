import 'package:carseva/core/api/ai_client.dart';
import 'package:carseva/features/voice_search/domain/models/conversation_message.dart';
import 'package:carseva/features/voice_search/domain/repositories/gemini_text_response.dart';

class AiRepositoryImpl implements AiRepository {
  final UnifiedAIClient _aiClient = UnifiedAIClient();
  final String? systemInstruction;

  AiRepositoryImpl([this.systemInstruction]);

  @override
  Future<String> generateText(
    String userQuery,
    List<ConversationMessage> conversationHistory,
  ) async {
    try {
      final messages = conversationHistory.map((m) => {
        'role': m.role,
        'content': m.content,
      }).toList();
      
      messages.add({'role': 'user', 'content': userQuery});

      return await _aiClient.generateChat(
        messages,
        systemInstruction: systemInstruction,
      );
    } catch (e) {
      print('❌ Error in Chat AI generateText: $e');
      return 'Sorry, I encountered an error. Please try again later.';
    }
  }
}
