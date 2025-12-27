import 'package:carseva/carinfo/domain/entities/car_entity.dart';

abstract class UserCarRepository {
  Future<void> saveCurrentCar({
    required String userId,
    required UserCarEntity car,
  });

  Future<UserCarEntity?> getCurrentCar(String userId);
}
