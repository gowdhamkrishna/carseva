import 'package:carseva/features/diagnostics/domain/entities/diagnostic_entity.dart';
import 'package:carseva/features/diagnostics/domain/entities/symptom.dart';
import 'package:carseva/features/diagnostics/domain/repositories/diagnostic_repository.dart';
import 'package:carseva/features/diagnostics/data/datasources/diagnostic_ai_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carseva/features/diagnostics/domain/entities/severity_level.dart';

class DiagnosticRepositoryImpl implements DiagnosticRepository {
  final DiagnosticAIService aiService;
  final FirebaseFirestore firestore;

  DiagnosticRepositoryImpl({
    required this.aiService,
    required this.firestore,
  });

  @override
  Future<DiagnosticEntity> analyzeSymptoms({
    required String userId,
    required String carId,
    required List<Symptom> symptoms,
    Map<String, dynamic>? carContext,
    String? photoUrl,
    String? voiceTranscript,
  }) async {
    // Generate AI diagnosis
    final diagnosisResult = await aiService.analyzeSymptoms(
      symptoms: symptoms,
      carContext: carContext ?? {},
      voiceTranscript: voiceTranscript,
    );

    // Create diagnostic entity
    final diagnostic = DiagnosticEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      carId: carId,
      timestamp: DateTime.now(),
      symptoms: symptoms,
      result: diagnosisResult,
      severity: diagnosisResult.severity,
      photoUrl: photoUrl,
      voiceTranscript: voiceTranscript,
      carContext: carContext,
    );

    // Save to Firestore (non-blocking, don't wait for it)
    saveDiagnostic(diagnostic).catchError((error) {
      print('⚠️ Failed to save diagnostic to Firestore: $error');
      print('💡 Tip: Create Firestore database to enable history saving');
    });

    return diagnostic;
  }

  @override
  Future<List<DiagnosticEntity>> getDiagnosticHistory({
    required String userId,
    String? carId,
    int limit = 10,
  }) async {
    try {
      Query query = firestore
          .collection('diagnostics')
          .doc(userId)
          .collection('records')
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (carId != null) {
        query = query.where('carId', isEqualTo: carId);
      }

      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _diagnosticFromMap(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<DiagnosticEntity?> getDiagnosticById(String diagnosticId) async {
    // Implementation for getting specific diagnostic
    return null;
  }

  @override
  Future<void> saveDiagnostic(DiagnosticEntity diagnostic) async {
    try {
      await firestore
          .collection('diagnostics')
          .doc(diagnostic.userId)
          .collection('records')
          .doc(diagnostic.id)
          .set(_diagnosticToMap(diagnostic));
    } catch (e) {
      // Handle error
    }
  }

  @override
  Future<void> deleteDiagnostic(String diagnosticId) async {
    // Implementation for deleting diagnostic
  }

  Map<String, dynamic> _diagnosticToMap(DiagnosticEntity diagnostic) {
    return {
      'id': diagnostic.id,
      'userId': diagnostic.userId,
      'carId': diagnostic.carId,
      'timestamp': diagnostic.timestamp.toIso8601String(),
      'symptoms': diagnostic.symptoms.map((s) => {
        'id': s.id,
        'category': s.category.name,
        'description': s.description,
        'location': s.location,
        'reportedAt': s.reportedAt.toIso8601String(),
      }).toList(),
      'severity': diagnostic.severity?.name,
      'photoUrl': diagnostic.photoUrl,
      'voiceTranscript': diagnostic.voiceTranscript,
      'carContext': diagnostic.carContext,
      'result': diagnostic.result != null ? {
        'primaryDiagnosis': diagnostic.result!.primaryDiagnosis,
        'confidence': diagnostic.result!.confidence,
        'severity': diagnostic.result!.severity.name,
        'urgency': diagnostic.result!.urgency.name,
      } : null,
    };
  }

  DiagnosticEntity _diagnosticFromMap(Map<String, dynamic> map) {
    return DiagnosticEntity(
      id: map['id'],
      userId: map['userId'],
      carId: map['carId'],
      timestamp: DateTime.parse(map['timestamp']),
      symptoms: (map['symptoms'] as List).map((s) => Symptom(
        id: s['id'],
        category: SymptomCategory.values.firstWhere(
          (c) => c.name == s['category'],
          orElse: () => SymptomCategory.sounds,
        ),
        description: s['description'],
        location: s['location'],
        reportedAt: DateTime.parse(s['reportedAt']),
      )).toList(),
      severity: map['severity'] != null
          ? SeverityLevel.values.firstWhere(
              (s) => s.name == map['severity'],
              orElse: () => SeverityLevel.medium,
            )
          : null,
      photoUrl: map['photoUrl'],
      voiceTranscript: map['voiceTranscript'],
      carContext: map['carContext'],
    );
  }
}
