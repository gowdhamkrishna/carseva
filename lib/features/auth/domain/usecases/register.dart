import 'package:carseva/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterUseCase {
  final AuthRepository repo;

  RegisterUseCase(this.repo);

  Future<User?> call(String email, String password) {
    return repo.register(email, password);
  }
}
