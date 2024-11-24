part of 'crossword_bloc.dart';

@immutable
sealed class CrosswordState {}

final class CrosswordInitial extends CrosswordState {}

final class CrosswordLoaded extends CrosswordState {
  final List<List<String>> crosswordData;
  final int? selectedRow;
  final int? selectedCol;
  final List<List<int>> highlightedCells;
  final bool isHorizontal;

  CrosswordLoaded({
    required this.crosswordData,
    this.selectedRow,
    this.selectedCol,
    this.highlightedCells = const [],
    this.isHorizontal = true, // Di default orizzontale
  });

  CrosswordLoaded copyWith({
    List<List<String>>? crosswordData,
    int? selectedRow,
    int? selectedCol,
    List<List<int>>? highlightedCells,
    bool? isHorizontal,
  }) {
    return CrosswordLoaded(
      crosswordData: crosswordData ?? this.crosswordData,
      selectedRow: selectedRow ?? this.selectedRow,
      selectedCol: selectedCol ?? this.selectedCol,
      highlightedCells: highlightedCells ?? this.highlightedCells,
      isHorizontal: isHorizontal ?? this.isHorizontal,
    );
  }
}
