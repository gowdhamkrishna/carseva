import '../models/availability_prediction.dart';
import '../repositories/market_repository.dart';

class PredictAvailability {
  final MarketRepository repository;

  PredictAvailability(this.repository);

  Future<AvailabilityPrediction> call({
    required String carModel,
    required String area,
    required String city,
    String? pincode,
  }) {
    return repository.predictAvailability(
      carModel: carModel,
      area: area,
      city: city,
      pincode: pincode,
    );
  }
}


