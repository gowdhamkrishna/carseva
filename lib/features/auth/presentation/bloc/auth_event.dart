import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  LoginEvent({required this.email, required this.password});
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  RegisterEvent({required this.email, required this.password});
}

class GoogleLoginEvent extends AuthEvent {}
class CheckAuthStatusEvent extends AuthEvent {}
