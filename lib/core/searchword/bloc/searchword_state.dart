part of 'searchword_bloc.dart';

@immutable
sealed class SearchwordState {}

final class SearchwordInitial extends SearchwordState {}

final class SearchwordLoaded extends SearchwordState {
  List<String>? solutions;
  List<List<SearchWordCell>>? currentWord;
  bool completed;
  int? maxRow;
  int? maxCol;

  SearchwordLoaded({this.solutions, this.currentWord, this.completed = false, this.maxRow, this.maxCol});

  SearchwordLoaded copyWith({
      List<String>? solutions,
      List<List<SearchWordCell>>? currentWord,
      bool? completed,
      int? currentRow,
      int? maxRow,
      int? maxCol
    }) {
      return SearchwordLoaded(
        solutions: solutions ?? this.solutions,
        currentWord: currentWord ?? this.currentWord,
        completed: completed ?? this.completed,
        maxRow: maxRow ?? this.maxRow,
        maxCol: maxCol ?? this.maxCol
      );
    }
}

class SearchWordError extends SearchwordState {
    final String message;

    SearchWordError(this.message);
}

