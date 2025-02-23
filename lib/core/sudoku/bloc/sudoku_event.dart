part of 'sudoku_bloc.dart';

@immutable
sealed class SudokuEvent {}

class FetchSudokuData extends SudokuEvent {}

class SelectSudokuCell extends SudokuEvent {
  final int row;
  final int column;

  SelectSudokuCell({required this.row, required this.column});
}

class InsertLetterEvent extends SudokuEvent {
  final String letter;

  InsertLetterEvent({required this.letter});
}

class RemoveLetterEvent extends SudokuEvent {}