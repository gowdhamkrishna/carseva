import 'package:carseva/features/auth/domain/repositories/auth_repository.dart';
import 'package:carseva/core/auth/local_user.dart';

class RegisterUseCase {
  final AuthRepository repo;

  RegisterUseCase(this.repo);

  Future<LocalUser?> call(String email, String password) {
    return repo.register(email, password);
  }
}
