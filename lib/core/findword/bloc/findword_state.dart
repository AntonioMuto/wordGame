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

  FindwordLoaded({required this.solution, required this.currentWord, this.completed = false, this.currentRow = 0, this.selectedRow, this.selectedCol});
 
  FindwordLoaded copyWith({
      List<String>? solution,
      List<List<Findwordcell>>? currentWord,
      bool? completed,
      int? currentRow,
      int? selectedRow,
      int? selectedCol
    }) {
      return FindwordLoaded(
        solution: solution ?? this.solution,
        currentWord: currentWord ?? this.currentWord,
        completed: completed ?? this.completed,
        currentRow: currentRow  ?? this.currentRow,
        selectedRow: selectedRow ?? this.selectedRow,
        selectedCol: selectedCol ?? this.selectedCol
      );
    }
}

class FindwordError extends FindwordState {
  final String message;

  FindwordError(this.message);
}


