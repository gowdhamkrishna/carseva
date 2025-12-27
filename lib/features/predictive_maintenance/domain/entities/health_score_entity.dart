import 'package:carseva/features/predictive_maintenance/domain/entities/component_health.dart';

class HealthTrend {
  final DateTime date;
  final double score;
  final ComponentType? component; // null for overall health

  const HealthTrend({
    required this.date,
    required this.score,
    this.component,
  });
}

class HealthScoreEntity {
  final String carId;
  final double overallScore; // 0.0 to 100.0
  final Map<ComponentType, ComponentHealth> components;
  final DateTime lastUpdated;
  final List<HealthTrend> trends;
  final List<String> recommendations;

  const HealthScoreEntity({
    required this.carId,
    required this.overallScore,
    required this.components,
    required this.lastUpdated,
    required this.trends,
    required this.recommendations,
  });

  String get healthStatus {
    if (overallScore >= 80) return 'Excellent';
    if (overallScore >= 60) return 'Good';
    if (overallScore >= 40) return 'Fair';
    if (overallScore >= 20) return 'Poor';
    return 'Critical';
  }

  String get healthColor {
    if (overallScore >= 80) return '#4CAF50'; // Green
    if (overallScore >= 60) return '#8BC34A'; // Light Green
    if (overallScore >= 40) return '#FF9800'; // Orange
    if (overallScore >= 20) return '#FF5722'; // Deep Orange
    return '#F44336'; // Red
  }

  List<ComponentHealth> get criticalComponents {
    return components.values
        .where((c) => c.healthScore < 40)
        .toList()
      ..sort((a, b) => a.healthScore.compareTo(b.healthScore));
  }
}
