import 'package:carseva/features/diagnostics/domain/entities/severity_level.dart';

enum UrgencyLevel {
  canWait,
  scheduleSoon,
  urgent,
  critical;

  String get displayName {
    switch (this) {
      case UrgencyLevel.canWait:
        return 'Can Wait';
      case UrgencyLevel.scheduleSoon:
        return 'Schedule Soon';
      case UrgencyLevel.urgent:
        return 'Urgent';
      case UrgencyLevel.critical:
        return 'Critical';
    }
  }
}

enum DiyFeasibility {
  easy,
  moderate,
  difficult,
  professionalOnly;

  String get displayName {
    switch (this) {
      case DiyFeasibility.easy:
        return 'Easy DIY';
      case DiyFeasibility.moderate:
        return 'Moderate DIY';
      case DiyFeasibility.difficult:
        return 'Difficult DIY';
      case DiyFeasibility.professionalOnly:
        return 'Professional Only';
    }
  }
}

class CostEstimate {
  final double minCost;
  final double maxCost;
  final String currency;

  const CostEstimate({
    required this.minCost,
    required this.maxCost,
    this.currency = 'INR',
  });

  String get displayRange => '₹${minCost.toStringAsFixed(0)} - ₹${maxCost.toStringAsFixed(0)}';
}

class PossibleCause {
  final String description;
  final double probability; // 0.0 to 1.0
  final List<String> symptoms;
  final CostEstimate? repairCost;

  const PossibleCause({
    required this.description,
    required this.probability,
    required this.symptoms,
    this.repairCost,
  });
}

class DiagnosisResult {
  final String primaryDiagnosis;
  final double confidence; // 0.0 to 1.0
  final List<PossibleCause> possibleCauses;
  final SeverityLevel severity;
  final UrgencyLevel urgency;
  final DiyFeasibility diyFeasibility;
  final CostEstimate? estimatedCost;
  final List<String> immediateActions;
  final List<String> recommendedActions;
  final String? diyGuideUrl;
  final Map<String, dynamic>? aiRawResponse;

  const DiagnosisResult({
    required this.primaryDiagnosis,
    required this.confidence,
    required this.possibleCauses,
    required this.severity,
    required this.urgency,
    required this.diyFeasibility,
    this.estimatedCost,
    required this.immediateActions,
    required this.recommendedActions,
    this.diyGuideUrl,
    this.aiRawResponse,
  });
}
