import 'package:carseva/features/predictive_maintenance/domain/entities/health_score_entity.dart';
import 'package:carseva/features/predictive_maintenance/domain/entities/maintenance_prediction_entity.dart';
import 'package:equatable/equatable.dart';

abstract class MaintenanceEvent extends Equatable {
  const MaintenanceEvent();

  @override
  List<Object?> get props => [];
}

class EvaluateHealthEvent extends MaintenanceEvent {
  final String carId;
  final Map<String, dynamic> carContext;
  final Map<String, Map<String, dynamic>> answers;

  const EvaluateHealthEvent({
    required this.carId,
    required this.carContext,
    required this.answers,
  });

  @override
  List<Object?> get props => [carId, carContext, answers];
}

class LoadMaintenanceTimelineEvent extends MaintenanceEvent {
  final String carId;

  const LoadMaintenanceTimelineEvent(this.carId);

  @override
  List<Object?> get props => [carId];
}
