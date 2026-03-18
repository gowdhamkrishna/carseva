import 'package:carseva/core/api/ai_client.dart';
import 'package:carseva/core/utils/json_extractor.dart';
import 'dart:convert';

class VehicleInsightsAIService {
  final _aiClient = UnifiedAIClient();

  VehicleInsightsAIService();

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
      final responseText = await _aiClient.generateContent(prompt, systemInstruction: 'Provide personalized vehicle insights and respond ONLY with valid JSON.');
      print('✅ Vehicle insights received');
      
      if (responseText == null || responseText.isEmpty) {
        throw Exception('Empty response from AI');
      }
      
      final jsonResponse = JsonExtractor.extractObject(responseText);
      
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
