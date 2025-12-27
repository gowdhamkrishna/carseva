import 'package:carseva/features/predictive_maintenance/domain/entities/maintenance_prediction_entity.dart';
import 'package:carseva/features/predictive_maintenance/domain/entities/service_record.dart';
import 'package:carseva/features/predictive_maintenance/domain/repositories/maintenance_repository.dart';

class PredictMaintenance {
  final MaintenanceRepository repository;

  PredictMaintenance(this.repository);

  Future<List<MaintenancePredictionEntity>> call({
    required String carId,
    Map<String, dynamic>? carContext,
    List<ServiceRecord>? serviceHistory,
  }) async {
    return await repository.predictMaintenance(
      carId: carId,
      carContext: carContext,
      serviceHistory: serviceHistory,
    );
  }
}
