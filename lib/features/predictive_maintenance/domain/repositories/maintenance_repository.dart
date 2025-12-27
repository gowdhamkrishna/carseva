import 'package:carseva/features/predictive_maintenance/domain/entities/maintenance_prediction_entity.dart';
import 'package:carseva/features/predictive_maintenance/domain/entities/health_score_entity.dart';
import 'package:carseva/features/predictive_maintenance/domain/entities/service_record.dart';

abstract class MaintenanceRepository {
  /// Predict upcoming maintenance needs using AI
  Future<List<MaintenancePredictionEntity>> predictMaintenance({
    required String carId,
    Map<String, dynamic>? carContext,
    List<ServiceRecord>? serviceHistory,
  });

  /// Calculate health score for a car
  Future<HealthScoreEntity> calculateHealthScore({
    required String carId,
    Map<String, dynamic>? carContext,
    List<ServiceRecord>? serviceHistory,
  });

  /// Get maintenance timeline
  Future<List<MaintenancePredictionEntity>> getMaintenanceTimeline({
    required String carId,
    int monthsAhead = 6,
  });

  /// Get service history
  Future<List<ServiceRecord>> getServiceHistory({
    required String carId,
    int limit = 20,
  });

  /// Add service record
  Future<void> addServiceRecord(ServiceRecord record);

  /// Update service record
  Future<void> updateServiceRecord(ServiceRecord record);

  /// Delete service record
  Future<void> deleteServiceRecord(String recordId);

  /// Get health score history
  Future<List<HealthScoreEntity>> getHealthScoreHistory({
    required String carId,
    int limit = 30,
  });
}
