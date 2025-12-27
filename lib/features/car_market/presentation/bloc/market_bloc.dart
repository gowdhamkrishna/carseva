import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_trending_cars.dart';
import '../../domain/usecases/get_market_insights.dart';
import '../../domain/usecases/predict_availability.dart';
import '../../domain/usecases/get_price_prediction.dart';
import 'market_event.dart';
import 'market_state.dart';

class MarketBloc extends Bloc<MarketEvent, MarketState> {
  final GetTrendingCars getTrendingCars;
  final GetMarketInsights getMarketInsights;
  final PredictAvailability predictAvailability;
  final GetPricePrediction getPricePrediction;

  MarketBloc({
    required this.getTrendingCars,
    required this.getMarketInsights,
    required this.predictAvailability,
    required this.getPricePrediction,
  }) : super(MarketInitial()) {
    on<LoadTrendingCarsEvent>(_onLoadTrendingCars);
    on<LoadMarketInsightsEvent>(_onLoadMarketInsights);
    on<PredictAvailabilityEvent>(_onPredictAvailability);
    on<LoadPricePredictionEvent>(_onLoadPricePrediction);
  }

  Future<void> _onLoadTrendingCars(
    LoadTrendingCarsEvent event,
    Emitter<MarketState> emit,
  ) async {
    emit(MarketLoading());
    try {
      final cars = await getTrendingCars.call(
        type: event.type,
        fuelType: event.fuelType,
        minBudget: event.minBudget,
        maxBudget: event.maxBudget,
      );
      emit(TrendingCarsLoaded(cars));
    } catch (e) {
      emit(MarketError(e.toString()));
    }
  }

  Future<void> _onLoadMarketInsights(
    LoadMarketInsightsEvent event,
    Emitter<MarketState> emit,
  ) async {
    emit(MarketLoading());
    try {
      final insights = await getMarketInsights.call(
        type: event.type,
        city: event.city,
      );
      emit(MarketInsightsLoaded(insights));
    } catch (e) {
      emit(MarketError(e.toString()));
    }
  }

  Future<void> _onPredictAvailability(
    PredictAvailabilityEvent event,
    Emitter<MarketState> emit,
  ) async {
    emit(MarketLoading());
    try {
      final prediction = await predictAvailability.call(
        carModel: event.carModel,
        area: event.area,
        city: event.city,
        pincode: event.pincode,
      );
      emit(AvailabilityPredicted(prediction));
    } catch (e) {
      emit(MarketError(e.toString()));
    }
  }

  Future<void> _onLoadPricePrediction(
    LoadPricePredictionEvent event,
    Emitter<MarketState> emit,
  ) async {
    emit(MarketLoading());
    try {
      final prediction = await getPricePrediction.call(
        carModel: event.carModel,
        city: event.city,
      );
      emit(PricePredictionLoaded(prediction));
    } catch (e) {
      emit(MarketError(e.toString()));
    }
  }
}

