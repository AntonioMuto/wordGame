import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_game/core/crossword/bloc/crossword_bloc.dart';
import 'package:word_game/core/crossword/pages/keyboard.dart';
import 'package:word_game/data_models/CrossWordCell.dart';

class CrosswordPage extends StatelessWidget {
  CrosswordPage({super.key, required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CrosswordBloc([])..add(FetchCrosswordData()), // Fetch dei dati
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
                    if(state.crosswordData.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
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
                          final CrosswordCell cell = state.crosswordData[row][col];
                          final isSelected = state.selectedRow == row && state.selectedCol == col;
                          final isHighlighted = state.highlightedCells.any(
                                (highlighted) => highlighted[0] == row && highlighted[1] == col,
                              );
                          final hasRef = cell.rif != null ? true : false;

                          if (cell.type == "X") {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                border: Border.all(color: Colors.black, width: 1),
                              ),
                            );
                          } else {
                            return GestureDetector(
                              onTap: () {
                                context.read<CrosswordBloc>().add(SelectCellEvent(row: row, col: col));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.yellow
                                      : isHighlighted
                                          ? Colors.grey
                                          : Colors.white,
                                  border: Border.all(color: Colors.black, width: 1),
                                ),
                                child: Stack(
                                  children: [
                                    // Se hasRef è true, mostra il numerino in alto a sinistra
                                    if (hasRef)
                                      Positioned(
                                        top: 4, // Distanza dal bordo superiore
                                        left: 4, // Distanza dal bordo sinistro
                                        child: Container(
                                          padding: const EdgeInsets.all(4), // Spazio attorno al numerino
                                          color: Colors.transparent, // Colore di sfondo per visibilità
                                          child: Text(
                                            cell.rif ?? '', // Questo è il numerino che vuoi visualizzare
                                            style: const TextStyle(
                                              fontSize: 12, // Dimensione del numerino
                                              fontWeight: FontWeight.bold, // Grassetto per il numerino
                                              color: Colors.black, // Colore del numerino
                                            ),
                                          ),
                                        ),
                                      ),
                                    // Contenuto principale (testo)
                                    Center(
                                      child: Text(
                                        cell.value?.isEmpty == true ? "" : cell.value!,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: cell.isCorrect == true ? Colors.green[800] : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  } else if (state is CrosswordInitial) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is CrosswordError) {
                    return Center(child: Text('Errore: ${state.message}'));
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: BlocBuilder<CrosswordBloc, CrosswordState>(
                builder: (context, state) {
                  if (state is CrosswordLoaded) {
                    return Text(state.definition ?? '');
                  }
                  return Text("");
                })),
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
