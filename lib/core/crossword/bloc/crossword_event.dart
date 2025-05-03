part of 'crossword_bloc.dart';

@immutable
sealed class CrosswordEvent {}

class SelectCellEvent extends CrosswordEvent {
  final int row;
  final int col;

  SelectCellEvent({required this.row, required this.col});
}

class InsertLetterEvent extends CrosswordEvent {
  final String letter;

  InsertLetterEvent({required this.letter});
}

class RemoveLetterEvent extends CrosswordEvent {

  RemoveLetterEvent();
}

class ResetWordEvent extends CrosswordEvent {

  ResetWordEvent();
}

class FetchCrosswordData extends CrosswordEvent {}

final class CrosswordError extends CrosswordState {
  final String message;

  CrosswordError(this.message);
}

class ToggleDialogEvent extends CrosswordEvent {
  final bool isDialogOpen;

  ToggleDialogEvent({required this.isDialogOpen});
}

class ToggleHintEvent extends CrosswordEvent {}

class ResetHintEvent extends CrosswordEvent {}
