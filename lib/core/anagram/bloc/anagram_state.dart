part of 'anagram_bloc.dart';

@immutable
abstract class AnagramState {}

class AnagramInitial extends AnagramState {}

class AnagramLoaded extends AnagramState {
  final List<String> anagram;
  final List<String> solution;
  final List<String> currentWord;
  final Map<int, String> usedLetters;
  int attempts = 0;
  final bool completed;
  final bool started;

  AnagramLoaded({
    required this.anagram,
    required this.solution,
    required this.currentWord,
    required this.usedLetters,
    this.attempts = 0,
    this.completed = false,
    this.started = false
  });

  AnagramLoaded copyWith({
    List<String>? anagram,
    List<String>? solution,
    List<String>? currentWord,
    Map<int, String>? usedLetters,
    int? attempts,
    bool? completed,
    bool? started
  }) {
    return AnagramLoaded(
      anagram: anagram ?? this.anagram,
      solution: solution ?? this.solution,
      currentWord: currentWord ?? this.currentWord,
      usedLetters: usedLetters ?? this.usedLetters,
      completed: completed ?? this.completed,
      attempts: attempts ?? this.attempts,
      started: started ?? this.started
    );
  }
}


class AnagramError extends AnagramState {
  final String message;

  AnagramError(this.message);
}
