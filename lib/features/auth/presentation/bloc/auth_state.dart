import 'package:equatable/equatable.dart';
import 'package:carseva/core/auth/local_user.dart';

abstract class AuthBlocState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthBlocState {}

class AuthLoadingState extends AuthBlocState {}

class AuthSuccessState extends AuthBlocState {
  final LocalUser user;

  AuthSuccessState(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthFailureState extends AuthBlocState {
  final String message;

  AuthFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
