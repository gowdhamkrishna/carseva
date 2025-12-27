import 'package:flutter/material.dart';

/// Car model representing a vehicle in the market
class CarModel {
  final String id;
  final String name;
  final String brand;
  final CarType type;
  final FuelType fuelType;
  final double basePrice;
  final double? currentPrice;
  final String imageUrl;
  final double mileage; // km/l
  final double resaleValue; // percentage
  final int launchYear;
  final bool isNewLaunch;
  final MarketTrend trend;

  CarModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.type,
    required this.fuelType,
    required this.basePrice,
    this.currentPrice,
    required this.imageUrl,
    required this.mileage,
    required this.resaleValue,
    required this.launchYear,
    this.isNewLaunch = false,
    required this.trend,
  });

  double get priceChange => currentPrice != null 
      ? ((currentPrice! - basePrice) / basePrice) * 100 
      : 0.0;

  double get discountedPrice => currentPrice ?? basePrice;
}

enum CarType {
  hatchback,
  sedan,
  suv,
  ev,
}

enum FuelType {
  petrol,
  diesel,
  electric,
  hybrid,
  cng,
}

enum MarketTrend {
  highDemand,
  priceDrop,
  newLaunch,
  goodValue,
  stable,
}

extension CarTypeExtension on CarType {
  String get displayName {
    switch (this) {
      case CarType.hatchback:
        return 'Hatchback';
      case CarType.sedan:
        return 'Sedan';
      case CarType.suv:
        return 'SUV';
      case CarType.ev:
        return 'Electric Vehicle';
    }
  }

  String get icon {
    switch (this) {
      case CarType.hatchback:
        return '🚗';
      case CarType.sedan:
        return '🚙';
      case CarType.suv:
        return '🚘';
      case CarType.ev:
        return '⚡';
    }
  }
}

extension FuelTypeExtension on FuelType {
  String get displayName {
    switch (this) {
      case FuelType.petrol:
        return 'Petrol';
      case FuelType.diesel:
        return 'Diesel';
      case FuelType.electric:
        return 'Electric';
      case FuelType.hybrid:
        return 'Hybrid';
      case FuelType.cng:
        return 'CNG';
    }
  }
}

extension MarketTrendExtension on MarketTrend {
  String get displayName {
    switch (this) {
      case MarketTrend.highDemand:
        return 'High Demand';
      case MarketTrend.priceDrop:
        return 'Price Drop';
      case MarketTrend.newLaunch:
        return 'New Launch';
      case MarketTrend.goodValue:
        return 'Good Value';
      case MarketTrend.stable:
        return 'Stable';
    }
  }

  String get reason {
    switch (this) {
      case MarketTrend.highDemand:
        return 'High customer demand';
      case MarketTrend.priceDrop:
        return 'Recent price reduction';
      case MarketTrend.newLaunch:
        return 'Recently launched';
      case MarketTrend.goodValue:
        return 'Excellent mileage & resale value';
      case MarketTrend.stable:
        return 'Stable market position';
    }
  }

  Color get color {
    switch (this) {
      case MarketTrend.highDemand:
        return const Color(0xFFFF6584);
      case MarketTrend.priceDrop:
        return const Color(0xFF4CAF50);
      case MarketTrend.newLaunch:
        return const Color(0xFF6C63FF);
      case MarketTrend.goodValue:
        return const Color(0xFFFF9800);
      case MarketTrend.stable:
        return Colors.grey;
    }
  }
}


