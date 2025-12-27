import 'package:carseva/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoogleLoginUseCase {
  final AuthRepository repo;

  GoogleLoginUseCase(this.repo);

  Future<User?> call() {
    return repo.googleLogin();
  }
}
