import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';


// Interface for AI operations to allow mocking
abstract class GenerativeAIClient {
  Future<GenerateContentResponse> generateContent(Iterable<Content> prompt);
}

// Concrete implementation using Google Generative AI
class GoogleGenerativeAIClient implements GenerativeAIClient {
  final GenerativeModel _model;
  
  GoogleGenerativeAIClient(this._model);
  
  @override
  Future<GenerateContentResponse> generateContent(Iterable<Content> prompt) {
    return _model.generateContent(prompt);
  }
}

class MarketAnalysisAIService {
  final GenerativeAIClient _client;

  MarketAnalysisAIService(this._client);

  Future<Map<String, dynamic>> getMarketTrends({
    required String segment, // 'new' or 'used'
    String? carMake,
    String? carModel,
  }) async {
    final prompt = _buildMarketPrompt(segment: segment, carMake: carMake, carModel: carModel);

    try {
      print('📊 Requesting market analysis from AI...');
      
      final response = await _client.generateContent([Content.text(prompt)])
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timed out');
        },
      );
      
      final responseText = response.text;
      print('✅ Market AI Response received');
      
      if (responseText == null || responseText.isEmpty) {
        throw Exception('Empty response from AI');
      }
      
      final jsonResponse = _extractJson(responseText);
      
      if (jsonResponse.isEmpty) {
        throw Exception('Failed to parse AI response');
      }
      
      print('✅ Market data parsed successfully');
      return jsonResponse;
    } catch (e) {
      print('❌ Error in market analysis: $e');
      throw Exception('Failed to fetch market data: $e');
    }
  }

  String _buildMarketPrompt({
    required String segment,
    String? carMake,
    String? carModel,
  }) {
    return '''Provide Indian car market trends for ${segment == 'new' ? 'NEW' : 'SECOND-HAND'} cars.

Respond ONLY with valid JSON (no markdown):
{
  "topCars": [
    {
      "name": "Maruti Suzuki Swift",
      "segment": "Hatchback",
      "sales": 22000,
      "avgPrice": 750000,
      "priceChange": 3.2
    }
  ],
  "priceTrend": {
    "months": ["Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
    "values": [100, 102, 104, 106, 108, 110]
  },
  "insights": [
    "SUVs showing strong demand",
    "Electric vehicles gaining market share"
  ]
}

Provide 6-8 top selling cars with realistic Indian market data.
${segment == 'new' ? 'Price changes should be positive (inflation)' : 'Price changes should be negative (depreciation)'}.
Sales in units/month, prices in INR.''';
  }

  Map<String, dynamic> _extractJson(String text) {
    String cleanText = text.trim();
    cleanText = cleanText.replaceAll(RegExp(r'```json\s*'), '');
    cleanText = cleanText.replaceAll(RegExp(r'```\s*$'), '');
    cleanText = cleanText.trim();
    
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleanText);
    if (jsonMatch != null) {
      try {
        return json.decode(jsonMatch.group(0)!);
      } catch (e) {
        print('❌ JSON decode error: $e');
        throw Exception('Failed to parse AI response');
      }
    }
    throw Exception('No valid JSON found in response');
  }
}
