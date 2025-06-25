part of 'crossword_bloc.dart';

@immutable
sealed class CrosswordState {}

final class CrosswordInitial extends CrosswordState {}

final class CrosswordLoaded extends CrosswordState {
  final List<List<CrosswordCell>> crosswordData;
  final int? selectedRow;
  final int? selectedCol;
  final List<List<int>> highlightedCells;
  final List<List<int>> highlightedCellsSecondary;
  final bool isHorizontal;
  final String? definition;
  final bool completed;
  final bool hintedCorrectly;
  final int? level;

  CrosswordLoaded({
    required this.crosswordData,
    this.selectedRow,
    this.selectedCol,
    this.highlightedCells = const [],
    this.highlightedCellsSecondary = const [],
    this.isHorizontal = true, // Di default orizzontale
    this.definition,
    this.completed = false,
    this.hintedCorrectly = false,
    this.level
  });

  CrosswordLoaded copyWith({
    List<List<CrosswordCell>>? crosswordData,
    int? selectedRow,
    int? selectedCol,
    List<List<int>>? highlightedCells,
    List<List<int>>? highlightedCellsSecondary,
    bool? isHorizontal,
    String? definition,
    bool? completed,
    bool? hintedCorrectly,
    int? level
  }) {
    return CrosswordLoaded(
      crosswordData: crosswordData ?? this.crosswordData,
      selectedRow: selectedRow ?? this.selectedRow,
      selectedCol: selectedCol ?? this.selectedCol,
      highlightedCells: highlightedCells ?? this.highlightedCells,
      highlightedCellsSecondary: highlightedCellsSecondary ?? this.highlightedCellsSecondary,
      isHorizontal: isHorizontal ?? this.isHorizontal,
      definition: definition ?? this.definition,
      completed: completed ?? this.completed,
      hintedCorrectly: hintedCorrectly ?? this.hintedCorrectly,
      level: level ?? this.level
    );
  }
}
