import '../models/availability_prediction.dart';
import '../models/car_model.dart';

/// Repository interface for car market data
abstract class MarketRepository {
  /// Get trending cars based on filters
  Future<List<CarModel>> getTrendingCars({
    CarType? type,
    FuelType? fuelType,
    double? minBudget,
    double? maxBudget,
  });

  /// Get market insights and analysis
  Future<String> getMarketInsights({
    CarType? type,
    String? city,
  });

  /// Predict car availability in a specific area
  Future<AvailabilityPrediction> predictAvailability({
    required String carModel,
    required String area,
    required String city,
    String? pincode,
  });

  /// Get price prediction for a car model
  Future<Map<String, dynamic>> getPricePrediction({
    required String carModel,
    required String city,
  });
}


