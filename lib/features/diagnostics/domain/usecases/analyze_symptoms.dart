import 'package:carseva/features/diagnostics/domain/entities/diagnostic_entity.dart';
import 'package:carseva/features/diagnostics/domain/entities/symptom.dart';
import 'package:carseva/features/diagnostics/domain/repositories/diagnostic_repository.dart';

class AnalyzeSymptoms {
  final DiagnosticRepository repository;

  AnalyzeSymptoms(this.repository);

  Future<DiagnosticEntity> call({
    required String userId,
    required String carId,
    required List<Symptom> symptoms,
    Map<String, dynamic>? carContext,
    String? photoUrl,
    String? voiceTranscript,
  }) async {
    return await repository.analyzeSymptoms(
      userId: userId,
      carId: carId,
      symptoms: symptoms,
      carContext: carContext,
      photoUrl: photoUrl,
      voiceTranscript: voiceTranscript,
    );
  }
}
