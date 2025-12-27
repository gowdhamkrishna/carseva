import 'package:flutter/material.dart';

/// Prediction for car availability in a specific area
class AvailabilityPrediction {
  final String carModelId;
  final String carName;
  final String area;
  final String city;
  final String? pincode;
  final DemandLevel demandLevel;
  final double availabilityLikelihood; // 0.0 to 1.0
  final int expectedWaitingPeriod; // in days
  final String? insights; // AI-generated insights

  AvailabilityPrediction({
    required this.carModelId,
    required this.carName,
    required this.area,
    required this.city,
    this.pincode,
    required this.demandLevel,
    required this.availabilityLikelihood,
    required this.expectedWaitingPeriod,
    this.insights,
  });

  String get availabilityStatus {
    if (availabilityLikelihood >= 0.7) return 'High Availability';
    if (availabilityLikelihood >= 0.4) return 'Moderate Availability';
    return 'Low Availability';
  }

  String get waitingPeriodText {
    if (expectedWaitingPeriod == 0) return 'Available immediately';
    if (expectedWaitingPeriod < 7) return '$expectedWaitingPeriod days';
    if (expectedWaitingPeriod < 30) return '${(expectedWaitingPeriod / 7).ceil()} weeks';
    return '${(expectedWaitingPeriod / 30).ceil()} months';
  }
}

enum DemandLevel {
  high,
  medium,
  low,
}

extension DemandLevelExtension on DemandLevel {
  String get displayName {
    switch (this) {
      case DemandLevel.high:
        return 'High Demand';
      case DemandLevel.medium:
        return 'Medium Demand';
      case DemandLevel.low:
        return 'Low Demand';
    }
  }

  Color get color {
    switch (this) {
      case DemandLevel.high:
        return const Color(0xFFFF6584);
      case DemandLevel.medium:
        return const Color(0xFFFF9800);
      case DemandLevel.low:
        return const Color(0xFF4CAF50);
    }
  }

  IconData get icon {
    switch (this) {
      case DemandLevel.high:
        return Icons.trending_up;
      case DemandLevel.medium:
        return Icons.trending_flat;
      case DemandLevel.low:
        return Icons.trending_down;
    }
  }
}


