import 'package:carseva/features/predictive_maintenance/domain/entities/health_score_entity.dart';
import 'package:carseva/features/predictive_maintenance/domain/entities/maintenance_prediction_entity.dart';
import 'package:equatable/equatable.dart';

abstract class MaintenanceState extends Equatable {
  const MaintenanceState();

  @override
  List<Object?> get props => [];
}

class MaintenanceInitial extends MaintenanceState {}

class MaintenanceEvaluating extends MaintenanceState {}

class HealthScoreCalculated extends MaintenanceState {
  final HealthScoreEntity healthScore;
  final List<MaintenancePredictionEntity> predictions;

  const HealthScoreCalculated({
    required this.healthScore,
    required this.predictions,
  });

  @override
  List<Object?> get props => [healthScore, predictions];
}

class MaintenanceTimelineLoading extends MaintenanceState {}

class MaintenanceTimelineLoaded extends MaintenanceState {
  final List<MaintenancePredictionEntity> timeline;

  const MaintenanceTimelineLoaded(this.timeline);

  @override
  List<Object?> get props => [timeline];
}

class MaintenanceError extends MaintenanceState {
  final String message;

  const MaintenanceError(this.message);

  @override
  List<Object?> get props => [message];
}
