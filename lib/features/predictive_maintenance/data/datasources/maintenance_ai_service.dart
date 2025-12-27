import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:carseva/features/predictive_maintenance/domain/entities/maintenance_prediction_entity.dart';
import 'package:carseva/features/predictive_maintenance/domain/entities/health_score_entity.dart';
import 'package:carseva/features/predictive_maintenance/domain/entities/component_health.dart';
import 'package:carseva/features/predictive_maintenance/domain/entities/service_record.dart';
import 'dart:convert';

class MaintenanceAIService {
  final GenerativeModel model;

  MaintenanceAIService(this.model);

  Future<List<MaintenancePredictionEntity>> predictMaintenance({
    required String carId,
    required Map<String, dynamic> carContext,
    List<ServiceRecord>? serviceHistory,
  }) async {
    final prompt = _buildMaintenancePrompt(
      carContext: carContext,
      serviceHistory: serviceHistory,
    );

    try {
      print('🔮 Sending maintenance prediction request to AI...');
      
      // Add timeout to prevent infinite waiting
      final response = await model.generateContent([Content.text(prompt)])
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timed out. Please check your internet connection and try again.');
        },
      );
      
      final responseText = response.text;
      
      print('✅ Maintenance AI Response received: ${responseText?.substring(0, 100)}...');
      
      if (responseText == null || responseText.isEmpty) {
        print('❌ Empty response from maintenance AI');
        throw Exception('Empty response from AI. Please try again.');
      }
      
      final jsonResponse = _extractJson(responseText);
      
      if (jsonResponse.isEmpty) {
        print('❌ Failed to extract JSON from maintenance response');
        print('Response text: $responseText');
        throw Exception('Failed to parse AI response. Please try again.');
      }
      
      print('✅ Maintenance JSON parsed successfully');
      return _parseMaintenancePredictions(carId, jsonResponse);
    } catch (e, stackTrace) {
      print('❌ Error in predictMaintenance: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  Future<HealthScoreEntity> calculateHealthScore({
    required String carId,
    required Map<String, dynamic> carContext,
    List<ServiceRecord>? serviceHistory,
  }) async {
    final prompt = _buildHealthScorePrompt(
      carContext: carContext,
      serviceHistory: serviceHistory,
    );

    try {
      print('🏥 Sending health score request to AI...');
      
      // Add timeout to prevent infinite waiting
      final response = await model.generateContent([Content.text(prompt)])
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timed out. Please check your internet connection and try again.');
        },
      );
      
      final responseText = response.text;
      
      print('✅ Health AI Response received: ${responseText?.substring(0, 100)}...');
      
      if (responseText == null || responseText.isEmpty) {
        print('❌ Empty response from health AI');
        throw Exception('Empty response from AI. Please try again.');
      }
      
      final jsonResponse = _extractJson(responseText);
      
      if (jsonResponse.isEmpty) {
        print('❌ Failed to extract JSON from health response');
        print('Response text: $responseText');
        throw Exception('Failed to parse AI response. Please try again.');
      }
      
      print('✅ Health JSON parsed successfully');
      return _parseHealthScore(carId, jsonResponse);
    } catch (e, stackTrace) {
      print('❌ Error in calculateHealthScore: $e');
      print('Stack trace: $stackTrace');
      
      // Provide user-friendly error messages
      String errorMessage = 'Unable to evaluate health';
      if (e.toString().contains('timeout') || e.toString().contains('timed out')) {
        errorMessage = 'Request timed out. Please check your internet connection and try again.';
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your internet connection.';
      }
      
      // Return default health score with error info
      return HealthScoreEntity(
        carId: carId,
        overallScore: 0.0,
        components: {},
        lastUpdated: DateTime.now(),
        trends: [],
        recommendations: [
          errorMessage,
          'Check your internet connection',
          'Try the evaluation again',
          'If issue persists, schedule a professional inspection'
        ],
      );
    }
  }

  String _buildMaintenancePrompt({
    required Map<String, dynamic> carContext,
    List<ServiceRecord>? serviceHistory,
  }) {
    final serviceHistoryText = serviceHistory
            ?.map((s) => '- ${s.serviceDate.toString().split(' ')[0]}: ${s.serviceType} at ${s.mileageAtService}km (₹${s.cost})')
            .join('\n') ??
        'No service history available';

    return '''
You are a predictive maintenance AI for vehicles. Based on the following data, predict upcoming maintenance needs.

Vehicle Information:
- Make: ${carContext['make'] ?? 'Unknown'}
- Model: ${carContext['model'] ?? 'Unknown'}
- Year: ${carContext['year'] ?? 'Unknown'}
- Current Mileage: ${carContext['mileage'] ?? 'Unknown'} km
- Average Monthly Mileage: ${carContext['avgMonthlyMileage'] ?? 1000} km

Service History:
$serviceHistoryText

Please predict upcoming maintenance items for the next 6 months in JSON format:
{
  "predictions": [
    {
      "component": "engine",
      "maintenanceType": "Oil Change",
      "predictedMileage": 15000,
      "daysUntilDue": 30,
      "confidence": 0.9,
      "priority": "medium",
      "costEstimate": {
        "minCost": 2000,
        "maxCost": 4000
      },
      "reasons": ["Reason 1", "Reason 2"]
    }
  ]
}

Component types: engine, brakes, transmission, battery, tires, fluids, suspension, cooling, electrical, exhaust
Priority levels: low, medium, high, critical
Provide realistic cost estimates in Indian Rupees (INR).
''';
  }

  String _buildHealthScorePrompt({
    required Map<String, dynamic> carContext,
    List<ServiceRecord>? serviceHistory,
  }) {
    // Extract health check answers if available
    final healthAnswers = carContext['healthCheckAnswers'] as Map<String, Map<String, dynamic>>?;
    String answersText = '';
    
    if (healthAnswers != null && healthAnswers.isNotEmpty) {
      answersText = '\nHealth Check Answers:\n';
      healthAnswers.forEach((key, value) {
        answersText += '- $key: ${value['value']}\n';
      });
    }

    return '''Analyze vehicle health and respond ONLY with valid JSON (no markdown):

Vehicle: ${carContext['make']} ${carContext['model']} ${carContext['year']} (${carContext['mileage']}km)
$answersText

Respond with this exact JSON structure:
{
  "overallScore": 75.5,
  "components": {
    "engine": {"score": 80.0, "status": "Good", "issues": []},
    "brakes": {"score": 65.0, "status": "Fair", "issues": ["Brake pads showing wear"]}
  },
  "recommendations": ["rec1", "rec2"]
}

Components: engine, brakes, transmission, battery, tires, fluids, suspension
Status: Excellent/Good/Fair/Poor/Critical
Scores: 0-100''';
  }

  Map<String, dynamic> _extractJson(String text) {
    // Remove markdown code blocks if present
    String cleanText = text.trim();
    
    // Remove ```json and ``` markers
    cleanText = cleanText.replaceAll(RegExp(r'```json\s*'), '');
    cleanText = cleanText.replaceAll(RegExp(r'```\s*$'), '');
    cleanText = cleanText.trim();
    
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleanText);
    if (jsonMatch != null) {
      try {
        return json.decode(jsonMatch.group(0)!);
      } catch (e) {
        print('❌ Maintenance JSON decode error: $e');
        return {};
      }
    }
    print('❌ No JSON found in maintenance response');
    return {};
  }

  List<MaintenancePredictionEntity> _parseMaintenancePredictions(
    String carId,
    Map<String, dynamic> json,
  ) {
    final predictions = json['predictions'] as List? ?? [];
    
    return predictions.map((p) {
      final predictedDate = p['daysUntilDue'] != null
          ? DateTime.now().add(Duration(days: p['daysUntilDue']))
          : null;

      return MaintenancePredictionEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        carId: carId,
        component: _parseComponentType(p['component']),
        maintenanceType: p['maintenanceType'] ?? 'Maintenance',
        predictedDate: predictedDate,
        predictedMileage: p['predictedMileage'],
        confidence: ((p['confidence'] ?? 0.7) as num).toDouble(),
        priority: _parsePriority(p['priority']),
        costEstimate: CostEstimate(
          minCost: ((p['costEstimate']?['minCost'] ?? 0) as num).toDouble(),
          maxCost: ((p['costEstimate']?['maxCost'] ?? 0) as num).toDouble(),
        ),
        reasons: List<String>.from(p['reasons'] ?? []),
        createdAt: DateTime.now(),
      );
    }).toList();
  }

  HealthScoreEntity _parseHealthScore(
    String carId,
    Map<String, dynamic> json,
  ) {
    final componentsMap = <ComponentType, ComponentHealth>{};
    final componentsJson = json['components'] as Map<String, dynamic>? ?? {};

    componentsJson.forEach((key, value) {
      final componentType = _parseComponentType(key);
      componentsMap[componentType] = ComponentHealth(
        component: componentType,
        healthScore: ((value['score'] ?? 70.0) as num).toDouble(),
        status: value['status'] ?? 'Good',
        issues: List<String>.from(value['issues'] ?? []),
        lastChecked: DateTime.now(),
      );
    });

    return HealthScoreEntity(
      carId: carId,
      overallScore: ((json['overallScore'] ?? 70.0) as num).toDouble(),
      components: componentsMap,
      lastUpdated: DateTime.now(),
      trends: [],
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }

  ComponentType _parseComponentType(String? type) {
    switch (type?.toLowerCase()) {
      case 'brakes':
        return ComponentType.brakes;
      case 'transmission':
        return ComponentType.transmission;
      case 'battery':
        return ComponentType.battery;
      case 'tires':
        return ComponentType.tires;
      case 'fluids':
        return ComponentType.fluids;
      case 'suspension':
        return ComponentType.suspension;
      case 'cooling':
        return ComponentType.cooling;
      case 'electrical':
        return ComponentType.electrical;
      case 'exhaust':
        return ComponentType.exhaust;
      default:
        return ComponentType.engine;
    }
  }

  PriorityLevel _parsePriority(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'low':
        return PriorityLevel.low;
      case 'high':
        return PriorityLevel.high;
      case 'critical':
        return PriorityLevel.critical;
      default:
        return PriorityLevel.medium;
    }
  }
}
