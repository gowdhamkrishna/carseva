import 'package:carseva/features/predictive_maintenance/domain/entities/maintenance_prediction_entity.dart';
import 'package:carseva/features/predictive_maintenance/domain/entities/health_score_entity.dart';
import 'package:carseva/features/predictive_maintenance/domain/entities/service_record.dart';
import 'package:carseva/features/predictive_maintenance/domain/repositories/maintenance_repository.dart';
import 'package:carseva/features/predictive_maintenance/data/datasources/maintenance_ai_service.dart';
import 'package:carseva/core/storage/local_storage_service.dart';

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  final MaintenanceAIService aiService;
  final LocalStorageService storage;

  MaintenanceRepositoryImpl({
    required this.aiService,
    required this.storage,
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

    // Save locally
    try {
      await storage.saveJson(
        'health_scores',
        carId,
        {
          'carId': carId,
          'overallScore': healthScore.overallScore,
          'lastUpdated': healthScore.lastUpdated.toIso8601String(),
          'recommendations': healthScore.recommendations,
        },
      );
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
    final serviceHistory = await getServiceHistory(carId: carId);
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
      final docs = await storage.queryCollection(
        'service_history/$carId/records',
        limit: limit,
      );

      return docs.map((data) {
        return ServiceRecord(
          id: data['id'] ?? '',
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
      await storage.saveJson(
        'service_history/${record.carId}/records',
        record.id,
        {
          'id': record.id,
          'serviceDate': record.serviceDate.toIso8601String(),
          'mileageAtService': record.mileageAtService,
          'serviceType': record.serviceType,
          'serviceCenter': record.serviceCenter,
          'cost': record.cost,
          'partsReplaced': record.partsReplaced,
          'notes': record.notes,
          'photoUrls': record.photoUrls,
          'mechanicRating': record.mechanicRating,
        },
      );
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
    return [];
  }
}
