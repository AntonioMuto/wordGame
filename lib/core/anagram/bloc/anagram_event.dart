part of 'anagram_bloc.dart';

@immutable
sealed class AnagramEvent {}

class FetchAnagramData extends AnagramEvent {}
