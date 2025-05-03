part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class FetchProfileData extends ProfileEvent {}

class DecreaseTokenEvent extends ProfileEvent {
  final int token;

  DecreaseTokenEvent(this.token);
}

class IncreaseTokenEvent extends ProfileEvent {
  final int token;

  IncreaseTokenEvent(this.token);
}
