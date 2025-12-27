import '../models/car_model.dart';
import '../repositories/market_repository.dart';

class GetMarketInsights {
  final MarketRepository repository;

  GetMarketInsights(this.repository);

  Future<String> call({
    CarType? type,
    String? city,
  }) {
    return repository.getMarketInsights(type: type, city: city);
  }
}


