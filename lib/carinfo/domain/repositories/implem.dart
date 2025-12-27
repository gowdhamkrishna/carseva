import 'package:carseva/carinfo/data/datasource/data_source.dart';
import 'package:carseva/carinfo/data/models/user_model.dart';
import 'package:carseva/carinfo/domain/entities/car_entity.dart';
import 'package:carseva/carinfo/domain/repositories/repo_car_firebase.dart';

class UserCarRepositoryImpl implements UserCarRepository {
  final UserCarRemoteDataSource remote;

  UserCarRepositoryImpl(this.remote);

  @override
  Future<void> saveCurrentCar({
    required String userId,
    required UserCarEntity car,
  }) async {
    final model = UserCarModel.fromEntity(car);
    await remote.saveCar(userId, model);
  }

  @override
  Future<UserCarEntity?> getCurrentCar(String userId) async {
    return await remote.getCar(userId);
  }
}
