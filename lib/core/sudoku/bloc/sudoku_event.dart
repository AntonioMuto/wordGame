part of 'sudoku_bloc.dart';

@immutable
sealed class SudokuEvent {}

class FetchSudokuData extends SudokuEvent {}
