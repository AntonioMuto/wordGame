part of 'anagram_bloc.dart';

@immutable
abstract class AnagramEvent {}

class FetchAnagramData extends AnagramEvent {}

class AddLetterEvent extends AnagramEvent {
  final String letter;

  AddLetterEvent(this.letter);
}

class AddLetterAtPositionEvent extends AnagramEvent {
  final int position;
  final String letter;

  AddLetterAtPositionEvent(this.position, this.letter);
}

class RemoveLastLetterEvent extends AnagramEvent {}

class ResetWordAnagramEvent extends AnagramEvent {}
