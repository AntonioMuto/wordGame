part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

class LoadLevelEvent extends HomeEvent {}

class LoadGameSectionsEvent extends HomeEvent {}
