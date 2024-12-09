part of 'findword_bloc.dart';

@immutable
sealed class FindwordState {}

class FindwordInitial extends FindwordState {}

class FindwordLoaded extends FindwordState {
  final List<String> solution;
  final List<String> currentWord;
  final bool completed;

  FindwordLoaded({required this.solution, required this.currentWord, this.completed = false});
 
  FindwordLoaded copyWith({
      List<String>? solution,
      List<String>? currentWord,
      bool? completed
    }) {
      return FindwordLoaded(
        solution: solution ?? this.solution,
        currentWord: currentWord ?? this.currentWord,
        completed: completed ?? this.completed
      );
    }
}

class FindwordError extends FindwordState {
  final String message;

  FindwordError(this.message);
}


