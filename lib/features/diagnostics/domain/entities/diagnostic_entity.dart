import 'package:carseva/features/diagnostics/domain/entities/symptom.dart';
import 'package:carseva/features/diagnostics/domain/entities/diagnosis_result.dart';
import 'package:carseva/features/diagnostics/domain/entities/severity_level.dart';

class DiagnosticEntity {
  final String id;
  final String userId;
  final String carId;
  final DateTime timestamp;
  final List<Symptom> symptoms;
  final DiagnosisResult? result;
  final SeverityLevel? severity;
  final String? photoUrl;
  final String? voiceTranscript;
  final Map<String, dynamic>? carContext; // Make, model, year, mileage, etc.

  const DiagnosticEntity({
    required this.id,
    required this.userId,
    required this.carId,
    required this.timestamp,
    required this.symptoms,
    this.result,
    this.severity,
    this.photoUrl,
    this.voiceTranscript,
    this.carContext,
  });

  DiagnosticEntity copyWith({
    String? id,
    String? userId,
    String? carId,
    DateTime? timestamp,
    List<Symptom>? symptoms,
    DiagnosisResult? result,
    SeverityLevel? severity,
    String? photoUrl,
    String? voiceTranscript,
    Map<String, dynamic>? carContext,
  }) {
    return DiagnosticEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      carId: carId ?? this.carId,
      timestamp: timestamp ?? this.timestamp,
      symptoms: symptoms ?? this.symptoms,
      result: result ?? this.result,
      severity: severity ?? this.severity,
      photoUrl: photoUrl ?? this.photoUrl,
      voiceTranscript: voiceTranscript ?? this.voiceTranscript,
      carContext: carContext ?? this.carContext,
    );
  }
}
