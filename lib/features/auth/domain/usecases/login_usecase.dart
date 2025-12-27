import '../repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginUseCase {
  final AuthRepository repo;

  LoginUseCase(this.repo);

  Future<User?> call(String email, String password) {
    return repo.login(email, password);
  }
}
