import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:carseva/features/diagnostics/domain/entities/symptom.dart';
import 'package:carseva/features/diagnostics/domain/entities/diagnosis_result.dart';
import 'package:carseva/features/diagnostics/domain/entities/severity_level.dart';
import 'dart:convert';
import 'dart:math';

class DiagnosticAIService {
  final GenerativeModel model;

  DiagnosticAIService(this.model);

  Future<DiagnosisResult> analyzeSymptoms({
    required List<Symptom> symptoms,
    required Map<String, dynamic> carContext,
    String? voiceTranscript,
  }) async {
    final prompt = _buildDiagnosticPrompt(
      symptoms: symptoms,
      carContext: carContext,
      voiceTranscript: voiceTranscript,
    );

    try {
      print('🔍 Sending diagnostic request to AI...');
      
      // Add timeout to prevent infinite waiting
      final response = await model.generateContent([Content.text(prompt)])
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timed out. Please check your internet connection and try again.');
        },
      );
      
      final responseText = response.text;
      
      print('✅ AI Response received: ${responseText?.substring(0, min(100, responseText.length))}...');
      
      if (responseText == null || responseText.isEmpty) {
        print('❌ Empty response from AI');
        throw Exception('Empty response from AI. Please try again.');
      }
      
      // Parse JSON response
      final jsonResponse = _extractJson(responseText);
      
      if (jsonResponse.isEmpty) {
        print('❌ Failed to extract JSON from response');
        print('Response text: $responseText');
        throw Exception('Failed to parse AI response. Please try again.');
      }
      
      print('✅ JSON parsed successfully');
      return _parseDiagnosisResult(jsonResponse);
    } catch (e, stackTrace) {
      print('❌ Error in analyzeSymptoms: $e');
      print('Stack trace: $stackTrace');
      
      // Provide user-friendly error messages
      String errorMessage = 'Unable to analyze symptoms';
      if (e.toString().contains('timeout') || e.toString().contains('timed out')) {
        errorMessage = 'Request timed out. Please check your internet connection and try again.';
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('Failed to parse')) {
        errorMessage = 'Error processing AI response. Please try again.';
      }
      
      // Fallback diagnosis with error info
      return DiagnosisResult(
        primaryDiagnosis: errorMessage,
        confidence: 0.0,
        possibleCauses: [],
        severity: SeverityLevel.medium,
        urgency: UrgencyLevel.scheduleSoon,
        diyFeasibility: DiyFeasibility.professionalOnly,
        immediateActions: [
          'Check your internet connection',
          'Try the diagnosis again',
          'If issue persists, consult a professional mechanic'
        ],
        recommendedActions: ['Ensure stable internet connection', 'Try again in a few moments'],
      );
    }
  }

  String _buildDiagnosticPrompt({
    required List<Symptom> symptoms,
    required Map<String, dynamic> carContext,
    String? voiceTranscript,
  }) {
    final symptomsText = symptoms
        .map((s) => '- ${s.description}')
        .join('\n');

    return '''Analyze these vehicle symptoms and respond ONLY with valid JSON (no markdown, no explanation):

Vehicle: ${carContext['make']} ${carContext['model']} ${carContext['year']} (${carContext['mileage']}km)

Symptoms:
$symptomsText
${voiceTranscript != null ? '\nDetails: $voiceTranscript' : ''}

Respond with this exact JSON structure:
{
  "primaryDiagnosis": "brief diagnosis",
  "confidence": 0.85,
  "possibleCauses": [
    {
      "description": "cause",
      "probability": 0.7,
      "symptoms": ["symptom1"],
      "repairCost": {"minCost": 5000, "maxCost": 15000}
    }
  ],
  "severity": "medium",
  "urgency": "scheduleSoon",
  "diyFeasibility": "moderate",
  "estimatedCost": {"minCost": 5000, "maxCost": 15000},
  "immediateActions": ["action1", "action2"],
  "recommendedActions": ["rec1", "rec2"]
}

Severity: low/medium/high/critical
Urgency: canWait/scheduleSoon/urgent/critical
DIY: easy/moderate/difficult/professionalOnly
Costs in INR.''';
  }

  Map<String, dynamic> _extractJson(String text) {
    // Remove markdown code blocks if present
    String cleanText = text.trim();
    
    // Remove ```json and ``` markers
    cleanText = cleanText.replaceAll(RegExp(r'```json\s*'), '');
    cleanText = cleanText.replaceAll(RegExp(r'```\s*$'), '');
    cleanText = cleanText.trim();
    
    // Try to find JSON in the response
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleanText);
    if (jsonMatch != null) {
      try {
        final jsonStr = jsonMatch.group(0)!;
        print('🔍 Extracted JSON: ${jsonStr.substring(0, min(100, jsonStr.length))}...');
        return json.decode(jsonStr);
      } catch (e) {
        print('❌ JSON decode error: $e');
        return {};
      }
    }
    print('❌ No JSON found in response');
    return {};
  }

  DiagnosisResult _parseDiagnosisResult(Map<String, dynamic> json) {
    return DiagnosisResult(
      primaryDiagnosis: json['primaryDiagnosis'] ?? 'Unknown issue',
      confidence: (json['confidence'] ?? 0.5).toDouble(),
      possibleCauses: (json['possibleCauses'] as List?)
              ?.map((c) => PossibleCause(
                    description: c['description'] ?? '',
                    probability: (c['probability'] ?? 0.5).toDouble(),
                    symptoms: List<String>.from(c['symptoms'] ?? []),
                    repairCost: c['repairCost'] != null
                        ? CostEstimate(
                            minCost: (c['repairCost']['minCost'] ?? 0).toDouble(),
                            maxCost: (c['repairCost']['maxCost'] ?? 0).toDouble(),
                          )
                        : null,
                  ))
              .toList() ??
          [],
      severity: _parseSeverity(json['severity']),
      urgency: _parseUrgency(json['urgency']),
      diyFeasibility: _parseDiyFeasibility(json['diyFeasibility']),
      estimatedCost: json['estimatedCost'] != null
          ? CostEstimate(
              minCost: (json['estimatedCost']['minCost'] ?? 0).toDouble(),
              maxCost: (json['estimatedCost']['maxCost'] ?? 0).toDouble(),
            )
          : null,
      immediateActions: List<String>.from(json['immediateActions'] ?? []),
      recommendedActions: List<String>.from(json['recommendedActions'] ?? []),
      diyGuideUrl: json['diyGuideUrl'],
      aiRawResponse: json,
    );
  }

  SeverityLevel _parseSeverity(String? severity) {
    switch (severity?.toLowerCase()) {
      case 'low':
        return SeverityLevel.low;
      case 'high':
        return SeverityLevel.high;
      case 'critical':
        return SeverityLevel.critical;
      default:
        return SeverityLevel.medium;
    }
  }

  UrgencyLevel _parseUrgency(String? urgency) {
    switch (urgency?.toLowerCase()) {
      case 'canwait':
      case 'can_wait':
        return UrgencyLevel.canWait;
      case 'urgent':
        return UrgencyLevel.urgent;
      case 'critical':
        return UrgencyLevel.critical;
      default:
        return UrgencyLevel.scheduleSoon;
    }
  }

  DiyFeasibility _parseDiyFeasibility(String? feasibility) {
    switch (feasibility?.toLowerCase()) {
      case 'easy':
        return DiyFeasibility.easy;
      case 'difficult':
        return DiyFeasibility.difficult;
      case 'professionalonly':
      case 'professional_only':
        return DiyFeasibility.professionalOnly;
      default:
        return DiyFeasibility.moderate;
    }
  }
}
