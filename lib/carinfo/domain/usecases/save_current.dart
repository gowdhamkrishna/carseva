import 'package:carseva/carinfo/domain/entities/car_entity.dart';
import 'package:carseva/carinfo/domain/repositories/repo_car_firebase.dart';

class SaveCurrentCar {
  final UserCarRepository repository;

  SaveCurrentCar(this.repository);

  Future<void> call({
    required String userId,
    required UserCarEntity car,
  }) {
    return repository.saveCurrentCar(
      userId: userId,
      car: car,
    );
  }
}
