import 'package:carseva/features/predictive_maintenance/domain/entities/component_health.dart';

enum PriorityLevel {
  low,
  medium,
  high,
  critical;

  String get displayName {
    switch (this) {
      case PriorityLevel.low:
        return 'Low';
      case PriorityLevel.medium:
        return 'Medium';
      case PriorityLevel.high:
        return 'High';
      case PriorityLevel.critical:
        return 'Critical';
    }
  }
}

extension PriorityLevelExtension on PriorityLevel {
  String get color {
    switch (this) {
      case PriorityLevel.low:
        return '#4CAF50'; // Green
      case PriorityLevel.medium:
        return '#FF9800'; // Orange
      case PriorityLevel.high:
        return '#FF5722'; // Deep Orange
      case PriorityLevel.critical:
        return '#F44336'; // Red
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
  
  double get averageCost => (minCost + maxCost) / 2;
}

class MaintenancePredictionEntity {
  final String id;
  final String carId;
  final ComponentType component;
  final String maintenanceType; // e.g., "Oil Change", "Brake Pad Replacement"
  final DateTime? predictedDate;
  final int? predictedMileage;
  final double confidence; // 0.0 to 1.0
  final PriorityLevel priority;
  final CostEstimate costEstimate;
  final List<String> reasons;
  final bool isOverdue;
  final DateTime createdAt;

  const MaintenancePredictionEntity({
    required this.id,
    required this.carId,
    required this.component,
    required this.maintenanceType,
    this.predictedDate,
    this.predictedMileage,
    required this.confidence,
    required this.priority,
    required this.costEstimate,
    required this.reasons,
    this.isOverdue = false,
    required this.createdAt,
  });

  int? daysUntilDue() {
    if (predictedDate == null) return null;
    return predictedDate!.difference(DateTime.now()).inDays;
  }

  bool get isDueSoon {
    final days = daysUntilDue();
    return days != null && days <= 30 && days >= 0;
  }
}
