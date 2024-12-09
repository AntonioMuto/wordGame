part of 'findword_bloc.dart';

@immutable
sealed class FindwordEvent {}

class FetchFindWordData extends FindwordEvent {}

class RemoveLetterEvent extends FindwordEvent {}

class InsertLetterEvent extends FindwordEvent {
  final String letter;

  InsertLetterEvent(this.letter);
}

class ResetWordEvent extends FindwordEvent {}

class SelectCellEvent extends FindwordEvent {}