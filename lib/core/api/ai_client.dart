import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

enum AIProvider { gemini, cerebras }

abstract class AIClient {
  Future<String> generateContent(String prompt, {String? systemInstruction});
  Future<String> generateChat(List<Map<String, String>> messages, {String? systemInstruction});
}

class GeminiClient implements AIClient {
  final String apiKey;
  final String modelName;

  GeminiClient({required this.apiKey, this.modelName = 'gemini-2.5-flash-lite'});

  @override
  Future<String> generateContent(String prompt, {String? systemInstruction}) async {
    final model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      systemInstruction: systemInstruction != null ? Content.system(systemInstruction) : null,
    );

    final response = await model.generateContent([Content.text(prompt)]);
    return response.text ?? '';
  }

  @override
  Future<String> generateChat(List<Map<String, String>> messages, {String? systemInstruction}) async {
    final model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      systemInstruction: systemInstruction != null ? Content.system(systemInstruction) : null,
    );

    final history = messages.take(messages.length - 1).map((m) {
      if (m['role'] == 'user') return Content.text(m['content']!);
      if (m['role'] == 'assistant' || m['role'] == 'model') return Content.model([TextPart(m['content']!)]);
      return Content.text(m['content']!);
    }).toList();

    final chat = model.startChat(history: history);
    final lastMessage = messages.last['content']!;
    final response = await chat.sendMessage(Content.text(lastMessage));
    return response.text ?? '';
  }
}

class CerebrasClient implements AIClient {
  final String apiKey;
  final String modelName;

  CerebrasClient({required this.apiKey, this.modelName = 'llama3.1-8b'});

  @override
  Future<String> generateContent(String prompt, {String? systemInstruction}) async {
    return generateChat([{'role': 'user', 'content': prompt}], systemInstruction: systemInstruction);
  }

  @override
  Future<String> generateChat(List<Map<String, String>> messages, {String? systemInstruction}) async {
    final url = Uri.parse('https://api.cerebras.ai/v1/chat/completions');
    
    final formattedMessages = <Map<String, String>>[];
    if (systemInstruction != null) {
      formattedMessages.add({'role': 'system', 'content': systemInstruction});
    }
    
    for (var msg in messages) {
      formattedMessages.add({
        'role': msg['role'] == 'model' ? 'assistant' : msg['role']!,
        'content': msg['content']!,
      });
    }

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': modelName,
        'messages': formattedMessages,
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Cerebras API Error: ${response.statusCode} - ${response.body}');
    }

    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'] ?? '';
  }
}

class UnifiedAIClient {
  static final UnifiedAIClient _instance = UnifiedAIClient._internal();
  factory UnifiedAIClient() => _instance;
  UnifiedAIClient._internal();

  AIProvider _currentProvider = AIProvider.gemini;
  final Set<int> _expiredGeminiKeys = {};

  AIProvider get currentProvider => _currentProvider;

  Future<String> generateContent(String prompt, {String? systemInstruction}) async {
    return _execute((client) => client.generateContent(prompt, systemInstruction: systemInstruction));
  }

  Future<String> generateChat(List<Map<String, String>> messages, {String? systemInstruction}) async {
    return _execute((client) => client.generateChat(messages, systemInstruction: systemInstruction));
  }

  bool _isQuotaError(String errorStr) {
    final lower = errorStr.toLowerCase();
    return lower.contains('429') ||
        lower.contains('quota') ||
        lower.contains('exhausted') ||
        lower.contains('expired') ||
        lower.contains('rate');
  }

  Future<String> _execute(Future<String> Function(AIClient) action) async {
    // Try Gemini keys 1, 2, 3 in order
    final geminiKeys = [
      dotenv.env['GEMINI_API_KEY1'] ?? '',
      dotenv.env['GEMINI_API_KEY2'] ?? '',
      dotenv.env['GEMINI_API_KEY3'] ?? '',
    ];

    for (int i = 0; i < geminiKeys.length; i++) {
      final key = geminiKeys[i];
      if (key.isEmpty || _expiredGeminiKeys.contains(i)) continue;

      try {
        final client = GeminiClient(apiKey: key);
        final result = await action(client);
        _currentProvider = AIProvider.gemini;
        return result;
      } catch (e) {
        if (_isQuotaError(e.toString())) {
          print('⚠️ Gemini Key ${i + 1} quota exceeded. Trying next...');
          _expiredGeminiKeys.add(i);
        } else {
          rethrow;
        }
      }
    }

    // Fallback to Cerebras
    final cerebrasKey = dotenv.env['CEREBRAS_API_KEY'] ?? '';
    if (cerebrasKey.isNotEmpty) {
      try {
        final client = CerebrasClient(apiKey: cerebrasKey);
        final result = await action(client);
        _currentProvider = AIProvider.cerebras;
        return result;
      } catch (e) {
        print('❌ Cerebras API Error: $e');
        rethrow;
      }
    }

    throw Exception('No available AI providers. All API keys exhausted.');
  }

  void resetExpiry() {
    _expiredGeminiKeys.clear();
  }
}
