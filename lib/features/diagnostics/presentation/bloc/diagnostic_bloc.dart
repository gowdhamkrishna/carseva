import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carseva/features/diagnostics/domain/usecases/analyze_symptoms.dart';
import 'package:carseva/features/diagnostics/domain/usecases/get_diagnostic_history.dart';
import 'package:carseva/features/diagnostics/domain/entities/symptom.dart';
import 'package:carseva/features/diagnostics/presentation/bloc/diagnostic_event.dart';
import 'package:carseva/features/diagnostics/presentation/bloc/diagnostic_state.dart';

class DiagnosticBloc extends Bloc<DiagnosticEvent, DiagnosticState> {
  final AnalyzeSymptoms analyzeSymptoms;
  final GetDiagnosticHistory getDiagnosticHistory;

  DiagnosticBloc({
    required this.analyzeSymptoms,
    required this.getDiagnosticHistory,
  }) : super(DiagnosticInitial()) {
    on<AnalyzeSymptomsEvent>(_onAnalyzeSymptoms);
    on<LoadDiagnosticHistoryEvent>(_onLoadHistory);
  }

  Future<void> _onAnalyzeSymptoms(
    AnalyzeSymptomsEvent event,
    Emitter<DiagnosticState> emit,
  ) async {
    emit(DiagnosticAnalyzing());

    try {
      // Convert selected symptoms to Symptom entities
      final symptoms = event.selectedSymptoms.map((symptomText) {
        return Symptom(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          category: _categorizeSymptom(symptomText),
          description: symptomText,
          reportedAt: DateTime.now(),
        );
      }).toList();

      final diagnostic = await analyzeSymptoms(
        userId: event.userId,
        carId: event.carId,
        symptoms: symptoms,
        carContext: event.carContext,
        voiceTranscript: event.additionalDetails,
      );

      emit(DiagnosticAnalyzed(diagnostic));
    } catch (e) {
      emit(DiagnosticError('Failed to analyze symptoms: ${e.toString()}'));
    }
  }

  Future<void> _onLoadHistory(
    LoadDiagnosticHistoryEvent event,
    Emitter<DiagnosticState> emit,
  ) async {
    emit(DiagnosticHistoryLoading());

    try {
      final history = await getDiagnosticHistory(
        userId: event.userId,
        carId: event.carId,
      );

      emit(DiagnosticHistoryLoaded(history));
    } catch (e) {
      emit(DiagnosticError('Failed to load history: ${e.toString()}'));
    }
  }

  SymptomCategory _categorizeSymptom(String symptomText) {
    final lower = symptomText.toLowerCase();
    
    if (lower.contains('noise') || lower.contains('sound') || lower.contains('grinding') || 
        lower.contains('squealing') || lower.contains('knocking')) {
      return SymptomCategory.sounds;
    } else if (lower.contains('smell') || lower.contains('odor') || lower.contains('burning')) {
      return SymptomCategory.smells;
    } else if (lower.contains('smoke') || lower.contains('leak') || lower.contains('light') ||
               lower.contains('warning')) {
      return SymptomCategory.visual;
    } else if (lower.contains('acceleration') || lower.contains('power') || lower.contains('stall') ||
               lower.contains('fuel')) {
      return SymptomCategory.performance;
    } else if (lower.contains('steering') || lower.contains('pull') || lower.contains('vibration')) {
      return SymptomCategory.handling;
    } else if (lower.contains('battery') || lower.contains('electrical') || lower.contains('lights')) {
      return SymptomCategory.electrical;
    }
    
    return SymptomCategory.performance;
  }
}
