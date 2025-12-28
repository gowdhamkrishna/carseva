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
    try {
      print('💬 Chat AI Request:');
      print('   User Query: $userQuery');
      print('   History Length: ${conversationHistory.length}');
      
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

      print('   Total contents: ${contents.length}');
      print('   Sending request to Gemini...');

      // Generate response with timeout and retry
      final response = await _generateWithRetry(contents);

      final responseText = response.text;
      
      if (responseText == null || responseText.isEmpty) {
        print('❌ Empty response from Chat AI');
        throw Exception('Empty response from AI. Please try again.');
      }

      print('✅ Chat AI Response received:');
      print('   Length: ${responseText.length} characters');
      print('   Preview: ${responseText.substring(0, responseText.length > 100 ? 100 : responseText.length)}...');

      return responseText;
    } catch (e, stackTrace) {
      print('❌ Error in Chat AI generateText: $e');
      print('Stack trace: $stackTrace');
      
      // Provide user-friendly error messages
      String errorMessage = 'Unable to get response';
      if (e.toString().contains('429') || e.toString().contains('quota')) {
        errorMessage = 'I am receiving too many requests. Please wait a moment and try again.';
      } else if (e.toString().contains('timeout') || e.toString().contains('timed out')) {
        errorMessage = 'Request timed out. Please check your internet connection and try again.';
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('API key')) {
        errorMessage = 'API configuration error. Please contact support.';
      }
      
      return 'Sorry, I encountered an error: $errorMessage\n\nPlease try again or rephrase your question.';
    }
  }

  Future<GenerateContentResponse> _generateWithRetry(List<Content> contents, {int retries = 3}) async {
    for (int i = 0; i < retries; i++) {
      try {
        return await client.textModel.generateContent(contents)
            .timeout(const Duration(seconds: 30));
      } catch (e) {
        // Check if it's a quota/rate limit error (429)
        bool isRateLimit = e.toString().contains('429') || 
                          e.toString().contains('quota') || 
                          e.toString().contains('limit');
        
        if (isRateLimit && i < retries - 1) {
          int delay = (i + 1) * 2; // 2s, 4s, 6s...
          print('⚠️ Rate limit hit. Retrying in $delay seconds... (Attempt ${i + 1}/$retries)');
          await Future.delayed(Duration(seconds: delay));
          continue;
        }
        rethrow;
      }
    }
    throw Exception('Failed after $retries attempts');
  }
}
