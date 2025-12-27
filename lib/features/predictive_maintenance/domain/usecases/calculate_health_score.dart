import 'package:carseva/features/predictive_maintenance/domain/entities/health_score_entity.dart';
import 'package:carseva/features/predictive_maintenance/domain/entities/service_record.dart';
import 'package:carseva/features/predictive_maintenance/domain/repositories/maintenance_repository.dart';

class CalculateHealthScore {
  final MaintenanceRepository repository;

  CalculateHealthScore(this.repository);

  Future<HealthScoreEntity> call({
    required String carId,
    Map<String, dynamic>? carContext,
    List<ServiceRecord>? serviceHistory,
  }) async {
    return await repository.calculateHealthScore(
      carId: carId,
      carContext: carContext,
      serviceHistory: serviceHistory,
    );
  }
}
