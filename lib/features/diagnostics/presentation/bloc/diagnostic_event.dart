import 'package:carseva/features/diagnostics/domain/entities/diagnostic_entity.dart';
import 'package:equatable/equatable.dart';

abstract class DiagnosticEvent extends Equatable {
  const DiagnosticEvent();

  @override
  List<Object?> get props => [];
}

class AnalyzeSymptomsEvent extends DiagnosticEvent {
  final String userId;
  final String carId;
  final List<String> selectedSymptoms;
  final String? additionalDetails;
  final Map<String, dynamic> carContext;

  const AnalyzeSymptomsEvent({
    required this.userId,
    required this.carId,
    required this.selectedSymptoms,
    this.additionalDetails,
    required this.carContext,
  });

  @override
  List<Object?> get props => [userId, carId, selectedSymptoms, additionalDetails, carContext];
}

class LoadDiagnosticHistoryEvent extends DiagnosticEvent {
  final String userId;
  final String? carId;

  const LoadDiagnosticHistoryEvent({
    required this.userId,
    this.carId,
  });

  @override
  List<Object?> get props => [userId, carId];
}
