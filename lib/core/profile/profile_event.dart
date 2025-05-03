part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class FetchProfileData extends ProfileEvent {}

class DecreaseTokenEvent extends ProfileEvent {
  final int token;

  DecreaseTokenEvent(this.token);
}
