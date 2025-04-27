part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class FetchProfileData extends ProfileEvent {}
