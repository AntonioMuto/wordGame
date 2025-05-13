part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  String? username;
  String token;
  int coins;

  ProfileLoaded({
    required this.username,
    required this.token,
    required this.coins
  });

  ProfileLoaded copyWith({
    String? username,
    String? token,
    int? coins
  }) {
    return ProfileLoaded(
      username: username ?? this.username,
      token: token ?? this.token,
      coins: coins ?? this.coins
    );
  }

}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}
