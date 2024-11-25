part of 'crossword_bloc.dart';

@immutable
sealed class CrosswordState {}

final class CrosswordInitial extends CrosswordState {}

final class CrosswordLoaded extends CrosswordState {
  final List<List<CrosswordCell>> crosswordData;
  final int? selectedRow;
  final int? selectedCol;
  final List<List<int>> highlightedCells;
  final bool isHorizontal;
  final String? definition;

  CrosswordLoaded({
    required this.crosswordData,
    this.selectedRow,
    this.selectedCol,
    this.highlightedCells = const [],
    this.isHorizontal = true, // Di default orizzontale
    this.definition
  });

  CrosswordLoaded copyWith({
    List<List<CrosswordCell>>? crosswordData,
    int? selectedRow,
    int? selectedCol,
    List<List<int>>? highlightedCells,
    bool? isHorizontal,
    String? definition
  }) {
    return CrosswordLoaded(
      crosswordData: crosswordData ?? this.crosswordData,
      selectedRow: selectedRow ?? this.selectedRow,
      selectedCol: selectedCol ?? this.selectedCol,
      highlightedCells: highlightedCells ?? this.highlightedCells,
      isHorizontal: isHorizontal ?? this.isHorizontal,
      definition: definition ?? this.definition
    );
  }
}
