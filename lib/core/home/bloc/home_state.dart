part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

class HomeError extends HomeState {}

class HomeLoaded extends HomeState {
  final List<GameSection> sections;

  HomeLoaded(this.sections);
}
