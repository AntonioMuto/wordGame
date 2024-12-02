part of 'anagram_bloc.dart';

@immutable
sealed class AnagramState {}

final class AnagramInitial extends AnagramState {}

final class AnagramLoaded extends AnagramState {
  final List<String> anagram;
  final List<String> solution;
  final List<String> currentWord;

  AnagramLoaded({required this.anagram, required this.solution, required this.currentWord});
}

final class AnagramError extends AnagramState {
  final String message;

  AnagramError(this.message);
}