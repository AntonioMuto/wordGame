import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:word_game/core/ads/bloc/ads_bloc.dart';
import 'package:word_game/core/crossword/bloc/crossword_bloc.dart';
import 'package:word_game/core/crossword/pages/keyboard.dart';
import 'package:word_game/data_models/CrossWordCell.dart';

class CrosswordPage extends StatelessWidget {
  CrosswordPage({super.key, required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CrosswordBloc([])..add(FetchCrosswordData()), // Bloc del cruciverba
        ),
        BlocProvider(
          create: (_) => AdsBloc()..add(LoadBannerAdEvent()), // Bloc degli annunci
        ),
      ],

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
                      padding: const EdgeInsets.all(15.0),
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
                                borderRadius: BorderRadius.circular(5.0),
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
                                  borderRadius: BorderRadius.circular(5.0)
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
                                          fontWeight: FontWeight.bold,
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
                    return Column(
                      children: [
                        (state.definition != '' && state.definition != null) ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 1, ),
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.yellow
                            ),
                            child: Center(
                              child: Text(
                                state.definition ?? "",
                                style: TextStyle(
                                  fontSize: 18,
                              )),
                            )
                          ),
                        ) : Container(),
                      ],
                    );
                  }
                  return Text("");
                })),
                
            // Tastiera
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  // BlocBuilder<AdsBloc, AdsState>(
                  //   builder: (context, state) {
                  //     if (state is AdsLoading) {
                  //       return Center(child: CircularProgressIndicator());
                  //     } else if (state is BannerAdLoaded) {
                  //       // Mostra il banner ad
                  //       return Container(
                  //         height: state.bannerAd.size.height.toDouble(),
                  //         width: state.bannerAd.size.width.toDouble(),
                  //         child: AdWidget(ad: state.bannerAd), // Widget per mostrare il banner
                  //       );
                  //     } else if (state is BannerAdFailed) {
                  //       // Mostra un messaggio di errore se il caricamento fallisce
                  //       return Center(child: Text('Errore: ${state.error}'));
                  //     } else {
                  //       return SizedBox.shrink(); // Stato iniziale o inattivo
                  //     }
                  //   },
                  // ),
                  Keyboard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
