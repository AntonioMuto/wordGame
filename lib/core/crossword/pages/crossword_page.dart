import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_game/core/crossword/bloc/crossword_bloc.dart';
import 'package:word_game/core/crossword/pages/keyboard.dart';

class CrosswordPage extends StatelessWidget {
  CrosswordPage({super.key, required this.level});
  final int level;

  final List<List<String>> crosswordData = [
    ["_", "X", "_", "_", "X", "_", "_", "X", "_"],
    ["_", "_", "_", "_", "X", "_", "_", "X", "_"],
    ["X", "_", "_", "_", "X", "_", "_", "X", "_"],
    ["_", "_", "_", "_", "X", "_", "_", "X", "_"],
    ["_", "X", "_", "_", "X", "_", "_", "X", "_"],
    ["_", "_", "_", "_", "X", "_", "_", "X", "_"],
    ["X", "_", "_", "_", "X", "_", "_", "X", "_"],
    ["_", "_", "_", "_", "X", "_", "_", "X", "_"],
    ["_", "X", "_", "_", "X", "_", "_", "X", "_"],
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CrosswordBloc(crosswordData),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Cruciverba $level'),
        ),
        body: Column(
          children: [
            // Cruciverba
            Expanded(
              flex: 3,
              child: BlocBuilder<CrosswordBloc, CrosswordState>(
                builder: (context, state) {
                  if (state is CrosswordLoaded) {
                    final rows = state.crosswordData.length;
                    final cols = state.crosswordData[0].length;

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                        ),
                        itemCount: rows * cols,
                        itemBuilder: (context, index) {
                          final int row = index ~/ cols;
                          final int col = index % cols;
                          final String cell = state.crosswordData[row][col];
                          final isSelected = state.selectedRow == row && state.selectedCol == col;
                          final isHighlighted = state.highlightedCells.any(
                                (cell) => cell[0] == row && cell[1] == col,
                              );

                          if (cell == "X") {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                border: Border.all(color: Colors.black, width: 1),
                              ),
                            );
                          } else {
                            return GestureDetector(
                              onTap: () {
                                context
                                    .read<CrosswordBloc>()
                                    .add(SelectCellEvent(row: row, col: col));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.yellow : isHighlighted ? Colors.grey : Colors.white,
                                  border: Border.all(color: Colors.black, width: 1),
                                ),
                                child: Center(
                                  child: Text(
                                    cell == "_" ? "" : cell,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            // Tastiera
            Expanded(
              flex: 1,
              child: Keyboard(),
            ),
          ],
        ),
      ),
    );
  }
}
