import 'package:carseva/features/diagnostics/domain/entities/diagnostic_entity.dart';
import 'package:carseva/features/diagnostics/domain/entities/symptom.dart';

abstract class DiagnosticRepository {
  /// Analyze symptoms using AI and return diagnosis
  Future<DiagnosticEntity> analyzeSymptoms({
    required String userId,
    required String carId,
    required List<Symptom> symptoms,
    Map<String, dynamic>? carContext,
    String? photoUrl,
    String? voiceTranscript,
  });

  /// Get diagnostic history for a user
  Future<List<DiagnosticEntity>> getDiagnosticHistory({
    required String userId,
    String? carId,
    int limit = 10,
  });

  /// Get a specific diagnostic by ID
  Future<DiagnosticEntity?> getDiagnosticById(String diagnosticId);

  /// Save a diagnostic record
  Future<void> saveDiagnostic(DiagnosticEntity diagnostic);

  /// Delete a diagnostic record
  Future<void> deleteDiagnostic(String diagnosticId);
}
