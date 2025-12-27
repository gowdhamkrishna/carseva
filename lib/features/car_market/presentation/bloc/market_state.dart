import 'package:equatable/equatable.dart';
import '../../domain/models/car_model.dart';
import '../../domain/models/availability_prediction.dart';

abstract class MarketState extends Equatable {
  const MarketState();

  @override
  List<Object?> get props => [];
}

class MarketInitial extends MarketState {}

class MarketLoading extends MarketState {}

class MarketError extends MarketState {
  final String message;

  const MarketError(this.message);

  @override
  List<Object?> get props => [message];
}

class TrendingCarsLoaded extends MarketState {
  final List<CarModel> cars;

  const TrendingCarsLoaded(this.cars);

  @override
  List<Object?> get props => [cars];
}

class MarketInsightsLoaded extends MarketState {
  final String insights;

  const MarketInsightsLoaded(this.insights);

  @override
  List<Object?> get props => [insights];
}

class AvailabilityPredicted extends MarketState {
  final AvailabilityPrediction prediction;

  const AvailabilityPredicted(this.prediction);

  @override
  List<Object?> get props => [prediction];
}

class PricePredictionLoaded extends MarketState {
  final Map<String, dynamic> prediction;

  const PricePredictionLoaded(this.prediction);

  @override
  List<Object?> get props => [prediction];
}


