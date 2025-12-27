import 'package:carseva/features/predictive_maintenance/domain/entities/maintenance_prediction_entity.dart';
import 'package:carseva/features/predictive_maintenance/domain/entities/health_score_entity.dart';
import 'package:carseva/features/predictive_maintenance/domain/entities/service_record.dart';
import 'package:carseva/features/predictive_maintenance/domain/repositories/maintenance_repository.dart';
import 'package:carseva/features/predictive_maintenance/data/datasources/maintenance_ai_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  final MaintenanceAIService aiService;
  final FirebaseFirestore firestore;

  MaintenanceRepositoryImpl({
    required this.aiService,
    required this.firestore,
  });

  @override
  Future<List<MaintenancePredictionEntity>> predictMaintenance({
    required String carId,
    Map<String, dynamic>? carContext,
    List<ServiceRecord>? serviceHistory,
  }) async {
    return await aiService.predictMaintenance(
      carId: carId,
      carContext: carContext ?? {},
      serviceHistory: serviceHistory,
    );
  }

  @override
  Future<HealthScoreEntity> calculateHealthScore({
    required String carId,
    Map<String, dynamic>? carContext,
    List<ServiceRecord>? serviceHistory,
  }) async {
    final healthScore = await aiService.calculateHealthScore(
      carId: carId,
      carContext: carContext ?? {},
      serviceHistory: serviceHistory,
    );

    // Save to Firestore
    try {
      await firestore
          .collection('health_scores')
          .doc(carId)
          .set({
        'carId': carId,
        'overallScore': healthScore.overallScore,
        'lastUpdated': healthScore.lastUpdated.toIso8601String(),
        'recommendations': healthScore.recommendations,
      });
    } catch (e) {
      // Handle error
    }

    return healthScore;
  }

  @override
  Future<List<MaintenancePredictionEntity>> getMaintenanceTimeline({
    required String carId,
    int monthsAhead = 6,
  }) async {
    // Get service history
    final serviceHistory = await getServiceHistory(carId: carId);
    
    // Get predictions from AI
    return await predictMaintenance(
      carId: carId,
      serviceHistory: serviceHistory,
    );
  }

  @override
  Future<List<ServiceRecord>> getServiceHistory({
    required String carId,
    int limit = 20,
  }) async {
    try {
      final snapshot = await firestore
          .collection('service_history')
          .doc(carId)
          .collection('records')
          .orderBy('serviceDate', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ServiceRecord(
          id: doc.id,
          carId: carId,
          serviceDate: DateTime.parse(data['serviceDate']),
          mileageAtService: data['mileageAtService'],
          serviceType: data['serviceType'],
          serviceCenter: data['serviceCenter'],
          cost: (data['cost'] as num).toDouble(),
          partsReplaced: List<String>.from(data['partsReplaced'] ?? []),
          notes: data['notes'],
          photoUrls: data['photoUrls'] != null
              ? List<String>.from(data['photoUrls'])
              : null,
          mechanicRating: data['mechanicRating'],
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> addServiceRecord(ServiceRecord record) async {
    try {
      await firestore
          .collection('service_history')
          .doc(record.carId)
          .collection('records')
          .doc(record.id)
          .set({
        'serviceDate': record.serviceDate.toIso8601String(),
        'mileageAtService': record.mileageAtService,
        'serviceType': record.serviceType,
        'serviceCenter': record.serviceCenter,
        'cost': record.cost,
        'partsReplaced': record.partsReplaced,
        'notes': record.notes,
        'photoUrls': record.photoUrls,
        'mechanicRating': record.mechanicRating,
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Future<void> updateServiceRecord(ServiceRecord record) async {
    await addServiceRecord(record);
  }

  @override
  Future<void> deleteServiceRecord(String recordId) async {
    // Implementation for deleting service record
  }

  @override
  Future<List<HealthScoreEntity>> getHealthScoreHistory({
    required String carId,
    int limit = 30,
  }) async {
    // Implementation for getting health score history
    return [];
  }
}
