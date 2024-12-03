part of 'anagram_bloc.dart';

@immutable
abstract class AnagramState {}

class AnagramInitial extends AnagramState {}

class AnagramLoaded extends AnagramState {
  final List<String> anagram;
  final List<String> solution;
  final List<String> currentWord;
  final List<String> usedLetters;

  AnagramLoaded({
    required this.anagram,
    required this.solution,
    required this.currentWord,
    required this.usedLetters,
  });

  AnagramLoaded copyWith({
    List<String>? anagram,
    List<String>? solution,
    List<String>? currentWord,
    List<String>? usedLetters,
  }) {
    return AnagramLoaded(
      anagram: anagram ?? this.anagram,
      solution: solution ?? this.solution,
      currentWord: currentWord ?? this.currentWord,
      usedLetters: usedLetters ?? this.usedLetters,
    );
  }
}


class AnagramError extends AnagramState {
  final String message;

  AnagramError(this.message);
}
