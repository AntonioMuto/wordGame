part of 'anagram_bloc.dart';

@immutable
abstract class AnagramState {}

class AnagramInitial extends AnagramState {}

class AnagramLoaded extends AnagramState {
  final List<String> anagram;
  final List<String> solution;
  final List<String> currentWord;
  final Map<int, String> usedLetters;
  final bool completed;

  AnagramLoaded({
    required this.anagram,
    required this.solution,
    required this.currentWord,
    required this.usedLetters,
    this.completed = false,
  });

  AnagramLoaded copyWith({
    List<String>? anagram,
    List<String>? solution,
    List<String>? currentWord,
    Map<int, String>? usedLetters,
    bool? completed
  }) {
    return AnagramLoaded(
      anagram: anagram ?? this.anagram,
      solution: solution ?? this.solution,
      currentWord: currentWord ?? this.currentWord,
      usedLetters: usedLetters ?? this.usedLetters,
      completed: completed ?? this.completed
    );
  }
}


class AnagramError extends AnagramState {
  final String message;

  AnagramError(this.message);
}
