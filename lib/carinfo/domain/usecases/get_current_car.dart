import 'package:carseva/carinfo/domain/entities/car_entity.dart';
import 'package:carseva/carinfo/domain/repositories/repo_car_firebase.dart';

class GetCurrentCar {
  final UserCarRepository repository;

  GetCurrentCar(this.repository);

  Future<UserCarEntity?> call(String userId) {
    return repository.getCurrentCar(userId);
  }
}
