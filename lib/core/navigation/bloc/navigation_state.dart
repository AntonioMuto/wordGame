part of 'navigation_bloc.dart';

@immutable
sealed class NavigationState {}

final class NavigationInitial extends NavigationState {}

class NavigationChangedState extends NavigationState {
  final int selectedIndex;
  NavigationChangedState(this.selectedIndex);
}