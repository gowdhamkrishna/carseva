import 'package:carseva/core/api/ai_client.dart';
import 'package:carseva/core/utils/json_extractor.dart';
import 'dart:convert';

class MarketAnalysisAIService {
  final _aiClient = UnifiedAIClient();

  MarketAnalysisAIService();

  Future<Map<String, dynamic>> getMarketTrends({
    required String segment, // 'new' or 'used'
    String? carMake,
    String? carModel,
  }) async {
    final prompt = _buildMarketPrompt(segment: segment, carMake: carMake, carModel: carModel);

    try {
      final responseText = await _aiClient.generateContent(prompt, systemInstruction: 'Provide Indian car market trends and respond ONLY with valid JSON.');
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
    "values": [100.0, 105.5, 98.2, 112.4, 118.0, 125.2]
  },
  "insights": [
    "SUVs showing strong demand",
    "Electric vehicles gaining market share"
  ]
}

Provide 6-8 top selling cars with realistic Indian market data.
Include significant variance in the "values" array for price trends to show market fluctuations.
${segment == 'new' ? 'Price changes should be positive (inflation)' : 'Price changes should be negative (depreciation)'}.
Sales in units/month, prices in INR.''';
  }

  Map<String, dynamic> _extractJson(String text) {
    return JsonExtractor.extractObject(text);
  }
}
