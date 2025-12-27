import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

class VehicleInsightsAIService {
  final GenerativeModel model;

  VehicleInsightsAIService(this.model);

  Future<Map<String, dynamic>> getVehicleInsights({
    required String make,
    required String model,
    required int year,
    required int mileage,
  }) async {
    final prompt = _buildInsightsPrompt(
      make: make,
      model: model,
      year: year,
      mileage: mileage,
    );

    try {
      print('🚗 Requesting vehicle insights from AI...');
      
      final response = await this.model.generateContent([Content.text(prompt)])
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timed out');
        },
      );
      
      final responseText = response.text;
      print('✅ Vehicle insights received');
      
      if (responseText == null || responseText.isEmpty) {
        throw Exception('Empty response from AI');
      }
      
      final jsonResponse = _extractJson(responseText);
      
      if (jsonResponse.isEmpty) {
        throw Exception('Failed to parse AI response');
      }
      
      print('✅ Insights parsed successfully');
      return jsonResponse;
    } catch (e) {
      print('❌ Error in vehicle insights: $e');
      return _getFallbackInsights(make, model, year, mileage);
    }
  }

  String _buildInsightsPrompt({
    required String make,
    required String model,
    required int year,
    required int mileage,
  }) {
    final age = DateTime.now().year - year;
    
    return '''Provide personalized insights for this vehicle:
- Make: $make
- Model: $model
- Year: $year (${age} years old)
- Mileage: $mileage km

Respond ONLY with valid JSON (no markdown):
{
  "overallHealth": "Good/Fair/Needs Attention",
  "healthScore": 75,
  "keyInsights": [
    "Your vehicle is ${age} years old, regular maintenance is crucial",
    "At $mileage km, consider checking brake pads"
  ],
  "upcomingMaintenance": [
    {
      "item": "Oil Change",
      "dueAt": ${mileage + 5000},
      "priority": "Medium",
      "estimatedCost": 3000
    }
  ],
  "tips": [
    "Check tire pressure monthly",
    "Use recommended fuel grade"
  ],
  "resaleValue": {
    "current": 450000,
    "trend": "Stable",
    "factors": ["Good mileage", "Popular model"]
  }
}

Provide realistic Indian market data. Costs in INR.''';
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
        return {};
      }
    }
    return {};
  }

  Map<String, dynamic> _getFallbackInsights(String make, String model, int year, int mileage) {
    final age = DateTime.now().year - year;
    return {
      'overallHealth': 'Good',
      'healthScore': 75,
      'keyInsights': [
        'Your $make $model is $age years old',
        'Current mileage: $mileage km',
        'Regular maintenance recommended'
      ],
      'upcomingMaintenance': [
        {
          'item': 'Oil Change',
          'dueAt': mileage + 5000,
          'priority': 'Medium',
          'estimatedCost': 3000
        }
      ],
      'tips': [
        'Check tire pressure regularly',
        'Use recommended fuel grade',
        'Schedule regular service'
      ],
      'resaleValue': {
        'current': 400000,
        'trend': 'Stable',
        'factors': ['Market conditions apply']
      }
    };
  }
}
