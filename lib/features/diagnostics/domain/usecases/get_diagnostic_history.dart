import 'package:carseva/features/diagnostics/domain/entities/diagnostic_entity.dart';
import 'package:carseva/features/diagnostics/domain/repositories/diagnostic_repository.dart';

class GetDiagnosticHistory {
  final DiagnosticRepository repository;

  GetDiagnosticHistory(this.repository);

  Future<List<DiagnosticEntity>> call({
    required String userId,
    String? carId,
    int limit = 10,
  }) async {
    return await repository.getDiagnosticHistory(
      userId: userId,
      carId: carId,
      limit: limit,
    );
  }
}
