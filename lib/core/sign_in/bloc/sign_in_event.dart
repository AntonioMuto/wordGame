part of 'sign_in_bloc.dart';

@immutable
sealed class SignInEvent {}

class SignInSubmitted extends SignInEvent {
  final String username;
  final String password;

  SignInSubmitted(this.username, this.password);
}