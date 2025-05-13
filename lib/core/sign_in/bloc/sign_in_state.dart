part of 'sign_in_bloc.dart';

@immutable
sealed class SignInState {}

final class SignInInitial extends SignInState {}


class SignInLoading extends SignInState {}

class SignInSuccess extends SignInState {
  String? username;
  String token;
  int coins;

  SignInSuccess({
    required this.username,
    required this.token,
    required this.coins
  });

  SignInSuccess copyWith({
    String? username,
    String? token,
    int? coins
  }) {
    return SignInSuccess(
      username: username ?? this.username,
      token: token ?? this.token,
      coins: coins ?? this.coins
    );
  }
}

class SignInFailure extends SignInState {
  final String errorMessage;
  final bool? wrongPassword;
  final bool? userNotFound;

  SignInFailure({
    required this.errorMessage,
    this.wrongPassword,
    this.userNotFound,
  });
}