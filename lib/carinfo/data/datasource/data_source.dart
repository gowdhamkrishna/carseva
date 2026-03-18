import 'package:carseva/carinfo/data/models/user_model.dart';
import 'package:carseva/core/storage/local_storage_service.dart';

class UserCarRemoteDataSource {
  final LocalStorageService storage;

  UserCarRemoteDataSource(this.storage);

  Future<void> saveCar(String userId, UserCarModel model) async {
    await storage.saveJson(
      'users/$userId/current_car',
      'active',
      model.toFirestore(),
    );
  }

  Future<UserCarModel?> getCar(String userId) async {
    final data = await storage.getJson(
      'users/$userId/current_car',
      'active',
    );

    if (data == null) return null;
    return UserCarModel.fromFirestore(data);
  }
}
