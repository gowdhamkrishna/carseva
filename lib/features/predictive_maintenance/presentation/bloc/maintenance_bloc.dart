import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carseva/features/predictive_maintenance/domain/usecases/calculate_health_score.dart';
import 'package:carseva/features/predictive_maintenance/domain/usecases/predict_maintenance.dart';
import 'package:carseva/features/predictive_maintenance/domain/usecases/get_service_history.dart';
import 'package:carseva/features/predictive_maintenance/presentation/bloc/maintenance_event.dart';
import 'package:carseva/features/predictive_maintenance/presentation/bloc/maintenance_state.dart';

class MaintenanceBloc extends Bloc<MaintenanceEvent, MaintenanceState> {
  final CalculateHealthScore calculateHealthScore;
  final PredictMaintenance predictMaintenance;
  final GetServiceHistory getServiceHistory;

  MaintenanceBloc({
    required this.calculateHealthScore,
    required this.predictMaintenance,
    required this.getServiceHistory,
  }) : super(MaintenanceInitial()) {
    on<EvaluateHealthEvent>(_onEvaluateHealth);
    on<LoadMaintenanceTimelineEvent>(_onLoadTimeline);
  }

  Future<void> _onEvaluateHealth(
    EvaluateHealthEvent event,
    Emitter<MaintenanceState> emit,
  ) async {
    emit(MaintenanceEvaluating());

    try {
      // Get service history
      final serviceHistory = await getServiceHistory(carId: event.carId);

      // Enhance car context with questionnaire answers
      final enhancedContext = {
        ...event.carContext,
        'healthCheckAnswers': event.answers,
      };

      // Calculate health score using AI
      final healthScore = await calculateHealthScore(
        carId: event.carId,
        carContext: enhancedContext,
        serviceHistory: serviceHistory,
      );

      // Get maintenance predictions
      final predictions = await predictMaintenance(
        carId: event.carId,
        carContext: enhancedContext,
        serviceHistory: serviceHistory,
      );

      emit(HealthScoreCalculated(
        healthScore: healthScore,
        predictions: predictions,
      ));
    } catch (e) {
      emit(MaintenanceError('Failed to evaluate health: ${e.toString()}'));
    }
  }

  Future<void> _onLoadTimeline(
    LoadMaintenanceTimelineEvent event,
    Emitter<MaintenanceState> emit,
  ) async {
    emit(MaintenanceTimelineLoading());

    try {
      final serviceHistory = await getServiceHistory(carId: event.carId);
      
      final predictions = await predictMaintenance(
        carId: event.carId,
        serviceHistory: serviceHistory,
      );

      emit(MaintenanceTimelineLoaded(predictions));
    } catch (e) {
      emit(MaintenanceError('Failed to load timeline: ${e.toString()}'));
    }
  }
}
