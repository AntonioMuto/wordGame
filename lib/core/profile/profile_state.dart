part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  String? username;
  int token;

  ProfileLoaded({
    required this.username,
    required this.token
  });

  ProfileLoaded copyWith({
    String? username,
    int? token
  }) {
    return ProfileLoaded(
      username: username ?? this.username,
      token: token ?? this.token
    );
  }

}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}
