import 'package:equatable/equatable.dart';
import '../../domain/models/car_model.dart';

abstract class MarketEvent extends Equatable {
  const MarketEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrendingCarsEvent extends MarketEvent {
  final CarType? type;
  final FuelType? fuelType;
  final double? minBudget;
  final double? maxBudget;

  const LoadTrendingCarsEvent({
    this.type,
    this.fuelType,
    this.minBudget,
    this.maxBudget,
  });

  @override
  List<Object?> get props => [type, fuelType, minBudget, maxBudget];
}

class LoadMarketInsightsEvent extends MarketEvent {
  final CarType? type;
  final String? city;

  const LoadMarketInsightsEvent({this.type, this.city});

  @override
  List<Object?> get props => [type, city];
}

class PredictAvailabilityEvent extends MarketEvent {
  final String carModel;
  final String area;
  final String city;
  final String? pincode;

  const PredictAvailabilityEvent({
    required this.carModel,
    required this.area,
    required this.city,
    this.pincode,
  });

  @override
  List<Object?> get props => [carModel, area, city, pincode];
}

class LoadPricePredictionEvent extends MarketEvent {
  final String carModel;
  final String city;

  const LoadPricePredictionEvent({
    required this.carModel,
    required this.city,
  });

  @override
  List<Object?> get props => [carModel, city];
}


