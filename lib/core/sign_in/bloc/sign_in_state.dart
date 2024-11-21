part of 'sign_in_bloc.dart';

@immutable
sealed class SignInState {}

final class SignInInitial extends SignInState {}


class SignInLoading extends SignInState {}

class SignInSuccess extends SignInState {}

class SignInFailure extends SignInState {
  final String errorMessage;

  SignInFailure(this.errorMessage);
}