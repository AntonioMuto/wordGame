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

  // Variabile locale per gestire lo stato del dialog
  final ValueNotifier<bool> _isDialogOpen = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BlocBuilder<AdsBloc, AdsState>(
              builder: (context, state) {
                return BlocBuilder<CrosswordBloc, CrosswordState>(
                  builder: (context, state) {
                    if (state is CrosswordLoaded) {
                      if (state.crosswordData.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final rows = state.crosswordData.length;
                      final cols = state.crosswordData[0].length;

                      // Altezza dinamica basata sulla larghezza dello schermo e sul numero di righe
                      final cellSize = screenWidth / cols;
                      final crosswordHeight = cellSize * rows;

                      // Mostra il modale di completamento se il livello è completato
                      if (state.completed && !_isDialogOpen.value) {
                        _isDialogOpen.value = true; // Aggiorna il flag locale
                        Future.delayed(Duration.zero, () {
                          _showCompletionDialog(context);
                        });
                      }

                      return Container(
                        height: crosswordHeight,
                        padding: const EdgeInsets.all(15.0),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
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
                            final hasRef = cell.rif != null;

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
                                            ? const Color.fromARGB(255, 194, 194, 194)
                                            : Colors.white,
                                    border: Border.all(color: Colors.black, width: 1),
                                    borderRadius: BorderRadius.circular(5.0),
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
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is CrosswordError) {
                      return Center(child: Text('Errore: ${state.message}'));
                    } else {
                      return Container();
                    }
                  },
                );
              },
            ),

            // Container giallo per la definizione
            BlocBuilder<CrosswordBloc, CrosswordState>(
              builder: (context, state) {
                if (state is CrosswordLoaded && state.definition != null && state.definition != '') {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.yellow,
                      ),
                      child: Center(
                        child: Text(
                          "${state.definition}",
                          style: const TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox(height: 45);
              },
            ),

            // Keyboard
            BlocBuilder<CrosswordBloc, CrosswordState>(
              builder: (context, state) {
                if (state is CrosswordLoaded) {
                  return Keyboard();
                }
                return const SizedBox();
              },
            ),

            // Banner Ads
            BlocBuilder<CrosswordBloc, CrosswordState>(
              builder: (context, crosswordState) {
                if (crosswordState is CrosswordLoaded) {
                  return BlocBuilder<AdsBloc, AdsState>(
                    builder: (context, adsState) {
                      if (adsState is AdsLoading) {
                        return Center(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            child: const CircularProgressIndicator(),
                          ),
                        );
                      } else if (adsState is BannerAdLoaded) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          height: adsState.bannerAd.size.height.toDouble(),
                          width: adsState.bannerAd.size.width.toDouble(),
                          child: AdWidget(ad: adsState.bannerAd),
                        );
                      } else if (adsState is BannerAdFailed) {
                        return Center(child: Text('Errore: ${adsState.error}'));
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Congratulazioni!'),
          content: const Text('Hai completato il livello. Vuoi guardare una pubblicità?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _isDialogOpen.value = false; // Chiudi il dialog e aggiorna il flag
              },
              child: const Text('Chiudi'),
            ),
            TextButton(
              onPressed: () {
                context.read<AdsBloc>().add(LoadRewardedAdEvent());
                Navigator.of(dialogContext).pop();
                _isDialogOpen.value = false; // Chiudi il dialog e aggiorna il flag
              },
              child: const Text('Guarda Pubblicità'),
            ),
          ],
        );
      },
    );
  }
}
