import 'package:carseva/features/auth/domain/usecases/google_login.dart';
import 'package:carseva/features/auth/presentation/bloc/auth_event.dart';
import 'package:carseva/features/auth/presentation/bloc/auth_state.dart';
import 'package:carseva/features/auth/data/repositories/auth_implement.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carseva/features/auth/domain/usecases/login_usecase.dart';
import 'package:carseva/features/auth/domain/usecases/register.dart';

class AuthBloc extends Bloc<AuthEvent, AuthBlocState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GoogleLoginUseCase googleLoginUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.googleLoginUseCase,
  }) : super(AuthInitialState()) {
    on<LoginEvent>((event, emit) async {
      emit(AuthLoadingState());
      final user = await loginUseCase(event.email, event.password);
      emit(
        user != null
            ? AuthSuccessState(user)
            : AuthFailureState("Login failed"),
      );
    });
    on<CheckAuthStatusEvent>((event, emit) async {
      final user = await AuthRepositoryImpl.getCurrentUser();

      if (user != null) {
        emit(AuthSuccessState(user));
      } else {
        emit(AuthInitialState());
      }
    });

    on<RegisterEvent>((event, emit) async {
      emit(AuthLoadingState());
      final user = await registerUseCase(event.email, event.password);
      emit(
        user != null
            ? AuthSuccessState(user)
            : AuthFailureState("Register failed"),
      );
    });
    on<GoogleLoginEvent>((event, emit) async {
      emit(AuthLoadingState());
      try {
        final user = await googleLoginUseCase();
        if (user != null) {
          emit(AuthSuccessState(user));
        } else {
          emit(AuthFailureState("Google login is not available in offline mode"));
        }
      } catch (e) {
        emit(AuthFailureState(e.toString()));
      }
    });
  }
}
