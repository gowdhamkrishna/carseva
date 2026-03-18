import 'package:carseva/core/auth/local_user.dart';

abstract class AuthRepository {
  Future<LocalUser?> register(String email, String password);
  Future<LocalUser?> login(String email, String password);
  Future<LocalUser?> googleLogin();
}
