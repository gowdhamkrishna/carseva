import '../repositories/auth_repository.dart';
import 'package:carseva/core/auth/local_user.dart';

class LoginUseCase {
  final AuthRepository repo;

  LoginUseCase(this.repo);

  Future<LocalUser?> call(String email, String password) {
    return repo.login(email, password);
  }
}
