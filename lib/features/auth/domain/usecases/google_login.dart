import 'package:carseva/features/auth/domain/repositories/auth_repository.dart';
import 'package:carseva/core/auth/local_user.dart';

class GoogleLoginUseCase {
  final AuthRepository repo;

  GoogleLoginUseCase(this.repo);

  Future<LocalUser?> call() {
    return repo.googleLogin();
  }
}
