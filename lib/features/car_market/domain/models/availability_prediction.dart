import 'package:flutter/material.dart';

/// Type of location where car is available
enum LocationType {
  dealership,
  showroom,
  serviceCenter,
}

extension LocationTypeExtension on LocationType {
  String get displayName {
    switch (this) {
      case LocationType.dealership:
        return 'Dealership';
      case LocationType.showroom:
        return 'Showroom';
      case LocationType.serviceCenter:
        return 'Service Center';
    }
  }

  IconData get icon {
    switch (this) {
      case LocationType.dealership:
        return Icons.store;
      case LocationType.showroom:
        return Icons.storefront;
      case LocationType.serviceCenter:
        return Icons.build_circle;
    }
  }

  Color get color {
    switch (this) {
      case LocationType.dealership:
        return const Color(0xFF6C63FF);
      case LocationType.showroom:
        return const Color(0xFF4CAF50);
      case LocationType.serviceCenter:
        return const Color(0xFFFF9800);
    }
  }
}

/// Availability status at a location
enum StockStatus {
  inStock,
  limitedStock,
  preOrder,
  outOfStock,
}

extension StockStatusExtension on StockStatus {
  String get displayName {
    switch (this) {
      case StockStatus.inStock:
        return 'In Stock';
      case StockStatus.limitedStock:
        return 'Limited Stock';
      case StockStatus.preOrder:
        return 'Pre-order';
      case StockStatus.outOfStock:
        return 'Out of Stock';
    }
  }

  Color get color {
    switch (this) {
      case StockStatus.inStock:
        return const Color(0xFF4CAF50);
      case StockStatus.limitedStock:
        return const Color(0xFFFF9800);
      case StockStatus.preOrder:
        return const Color(0xFF6C63FF);
      case StockStatus.outOfStock:
        return const Color(0xFFFF6584);
    }
  }

  IconData get icon {
    switch (this) {
      case StockStatus.inStock:
        return Icons.check_circle;
      case StockStatus.limitedStock:
        return Icons.warning_amber;
      case StockStatus.preOrder:
        return Icons.schedule;
      case StockStatus.outOfStock:
        return Icons.cancel;
    }
  }
}

/// Specific location where car is available
class CarLocation {
  final String name;
  final String address;
  final LocationType type;
  final double distanceKm;
  final String? phoneNumber;
  final String? website;
  final StockStatus stockStatus;
  final String? operatingHours;
  final double? latitude;
  final double? longitude;

  const CarLocation({
    required this.name,
    required this.address,
    required this.type,
    required this.distanceKm,
    this.phoneNumber,
    this.website,
    required this.stockStatus,
    this.operatingHours,
    this.latitude,
    this.longitude,
  });

  String get distanceText {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toInt()} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }
}

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
  final List<CarLocation> availableLocations;

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
    this.availableLocations = const [],
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


