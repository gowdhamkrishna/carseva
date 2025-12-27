import 'package:carseva/features/diagnostics/domain/entities/diagnostic_entity.dart';
import 'package:equatable/equatable.dart';

abstract class DiagnosticState extends Equatable {
  const DiagnosticState();

  @override
  List<Object?> get props => [];
}

class DiagnosticInitial extends DiagnosticState {}

class DiagnosticAnalyzing extends DiagnosticState {}

class DiagnosticAnalyzed extends DiagnosticState {
  final DiagnosticEntity diagnostic;

  const DiagnosticAnalyzed(this.diagnostic);

  @override
  List<Object?> get props => [diagnostic];
}

class DiagnosticHistoryLoading extends DiagnosticState {}

class DiagnosticHistoryLoaded extends DiagnosticState {
  final List<DiagnosticEntity> history;

  const DiagnosticHistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}

class DiagnosticError extends DiagnosticState {
  final String message;

  const DiagnosticError(this.message);

  @override
  List<Object?> get props => [message];
}
