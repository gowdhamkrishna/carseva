import 'package:carseva/core/api/ai_client.dart';
import 'package:carseva/features/voice_search/domain/models/conversation_message.dart';
import 'package:carseva/features/voice_search/domain/repositories/gemini_text_response.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiRepositoryImpl implements AiRepository {
  final GeminiClient client;

  AiRepositoryImpl(this.client);

  @override
  Future<String> generateText(
    String userQuery,
    List<ConversationMessage> conversationHistory,
  ) async {
    // Build conversation content list from history
    final List<Content> contents = [];

    // Add conversation history (convert to Gemini Content format)
    for (final message in conversationHistory) {
      if (message.role == 'user') {
        // Content.text() creates a user message
        contents.add(Content.text(message.content));
      } else if (message.role == 'assistant') {
        // Content.model() creates a model message
        contents.add(Content.model([TextPart(message.content)]));
      }
    }

    // Add current user query (Content.text() creates user message)
    contents.add(Content.text(userQuery));

    // Generate response
    final response = await client.textModel.generateContent(contents);

    return response.text ?? "No response";
  }
}
