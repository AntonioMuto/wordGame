part of 'navigation_bloc.dart';

@immutable
sealed class NavigationEvent {}

class NavigationChanged extends NavigationEvent {
  final int index;
  NavigationChanged(this.index);
}