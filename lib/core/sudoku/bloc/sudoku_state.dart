part of 'sudoku_bloc.dart';

@immutable
sealed class SudokuState {}

final class SudokuInitial extends SudokuState {}

final class SudokuLoaded extends SudokuState {
  List<List<Sudokucell>> sudokuData;
  final List<List<String>> sudokuSolution;
  final int? selectedRow;
  final int? selectedCol;
  final bool completed;

  SudokuLoaded({required this.sudokuData , required this.sudokuSolution, this.selectedRow = -1, this.selectedCol = -1, this.completed = false});

  SudokuLoaded copyWith({
    List<List<Sudokucell>>? sudokuData,
    List<List<String>>? sudokuSolution,
    int? selectedRow,
    int? selectedCol,
    bool? completed
  }) {
    return SudokuLoaded(
      sudokuData: sudokuData ?? this.sudokuData,
      sudokuSolution: sudokuSolution ?? this.sudokuSolution,
      selectedRow: selectedRow ?? this.selectedRow,
      selectedCol: selectedCol ?? this.selectedCol,
      completed: completed ?? this.completed
    );
  }
}

class  SudokuError extends SudokuState {
  final String message;

  SudokuError(this.message);
}
