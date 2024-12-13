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

class SubmitWordEvent extends FindwordEvent {}

class ChangeSelectedCellEvent extends FindwordEvent {
  final int row;
  final int col;

  ChangeSelectedCellEvent(this.row, this.col);
}

class ContinueLevelEvent extends FindwordEvent {}
class RemoveCompletedEvent extends FindwordEvent {}