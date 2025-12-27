import 'package:carseva/features/predictive_maintenance/domain/entities/service_record.dart';
import 'package:carseva/features/predictive_maintenance/domain/repositories/maintenance_repository.dart';

class GetServiceHistory {
  final MaintenanceRepository repository;

  GetServiceHistory(this.repository);

  Future<List<ServiceRecord>> call({
    required String carId,
    int limit = 20,
  }) async {
    return await repository.getServiceHistory(
      carId: carId,
      limit: limit,
    );
  }
}
