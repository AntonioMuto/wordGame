part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class FetchProfileData extends ProfileEvent {}

class EvaluateLoginData extends ProfileEvent {
  String? username;
  String? token;
  int coins;

  EvaluateLoginData(this.username, this.token, this.coins);
}

class DecreaseTokenEvent extends ProfileEvent {
  final int coins;

  DecreaseTokenEvent(this.coins);
}

class IncreaseTokenEvent extends ProfileEvent {
  final int coins;

  IncreaseTokenEvent(this.coins);
}
