import '../models/car_model.dart';
import '../repositories/market_repository.dart';

class GetTrendingCars {
  final MarketRepository repository;

  GetTrendingCars(this.repository);

  Future<List<CarModel>> call({
    CarType? type,
    FuelType? fuelType,
    double? minBudget,
    double? maxBudget,
  }) {
    return repository.getTrendingCars(
      type: type,
      fuelType: fuelType,
      minBudget: minBudget,
      maxBudget: maxBudget,
    );
  }
}


