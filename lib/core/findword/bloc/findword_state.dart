part of 'findword_bloc.dart';

@immutable
sealed class FindwordState {}

class FindwordInitial extends FindwordState {}

class FindwordLoaded extends FindwordState {
  final List<String> solution;
  final List<List<Findwordcell>> currentWord;
  bool completed;
  int currentRow;
  int? selectedRow;
  int? selectedCol;
  int maxRow;

  FindwordLoaded({required this.solution, required this.currentWord, this.completed = false, this.currentRow = 0, this.selectedRow, this.selectedCol, this.maxRow = 5});
 
  FindwordLoaded copyWith({
      List<String>? solution,
      List<List<Findwordcell>>? currentWord,
      bool? completed,
      int? currentRow,
      int? selectedRow,
      int? selectedCol,
      int? maxRow
    }) {
      return FindwordLoaded(
        solution: solution ?? this.solution,
        currentWord: currentWord ?? this.currentWord,
        completed: completed ?? this.completed,
        currentRow: currentRow  ?? this.currentRow,
        selectedRow: selectedRow ?? this.selectedRow,
        selectedCol: selectedCol ?? this.selectedCol,
        maxRow: maxRow ?? this.maxRow
      );
    }
}

class FindwordError extends FindwordState {
  final String message;

  FindwordError(this.message);
}


