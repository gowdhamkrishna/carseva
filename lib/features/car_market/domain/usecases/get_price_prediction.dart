import '../repositories/market_repository.dart';

class GetPricePrediction {
  final MarketRepository repository;

  GetPricePrediction(this.repository);

  Future<Map<String, dynamic>> call({
    required String carModel,
    required String city,
  }) {
    return repository.getPricePrediction(
      carModel: carModel,
      city: city,
    );
  }
}


