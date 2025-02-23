import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:word_game/core/ads/bloc/ads_bloc.dart';
import 'package:word_game/core/anagram/bloc/anagram_bloc.dart';
import 'package:word_game/core/crossword/bloc/crossword_bloc.dart';
import 'package:word_game/core/crossword/pages/keyboard.dart';
import 'package:word_game/data_models/CrossWordCell.dart';

class CrosswordPage extends StatelessWidget {
  final int level;

  const CrosswordPage({Key? key, required this.level}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CrosswordBloc([])..add(FetchCrosswordData()),
        ),
        BlocProvider(
          create: (_) => AdsBloc()..add(LoadBannerAdEvent()),
        ),
      ],
      child: BlocListener<CrosswordBloc, CrosswordState>(
        listener: (context, state) {
          if (state is CrosswordLoaded && state.completed) {
            _showCompletionDialog(context);
          }
        },
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              _showExitConfirmationDialog(context);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: Colors.white), // Freccia indietro
                onPressed: () {
                  // Mostra un dialog di conferma
                  _showExitConfirmationDialog(context);
                },
              ),
              title: Text(
                'Crossword Level $level',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              centerTitle: true,
              backgroundColor: Colors.blueGrey[900],
              elevation: 4.0,
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade600],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCrosswordGrid(context, screenWidth),
                  _buildDefinitionContainer(context),
                  BlocBuilder<CrosswordBloc, CrosswordState>(
                      builder: (context, state) {
                    if (state is CrosswordLoaded) {
                      return Keyboard(
                        onlyNumbers: false,
                        onKeyTap: (letter) {
                          if (letter == 'delete') {
                            context
                                .read<CrosswordBloc>()
                                .add(RemoveLetterEvent());
                          } else if (letter == 'clean') {
                            context.read<CrosswordBloc>().add(ResetWordEvent());
                          } else {
                            context
                                .read<CrosswordBloc>()
                                .add(InsertLetterEvent(letter: letter));
                          }
                        },
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),
                  _buildBannerAd(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCrosswordGrid(BuildContext context, double screenWidth) {
    return BlocBuilder<CrosswordBloc, CrosswordState>(
      builder: (context, state) {
        if (state is CrosswordLoaded) {
          if (state.crosswordData.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final rows = state.crosswordData.length;
          final cols = state.crosswordData[0].length;
          final cellSize = screenWidth / cols;
          final crosswordHeight = cellSize * rows;

          return Container(
              height: crosswordHeight,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
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
                    return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 200),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                              child: _buildCrosswordCell(
                                  context, cell, row, col, state)),
                        ));
                  }));
        }
        return const Center(
            child: CircularProgressIndicator(color: Colors.white));
      },
    );
  }

  Widget _buildCrosswordCell(
    BuildContext context,
    CrosswordCell cell,
    int row,
    int col,
    CrosswordState state,
  ) {
    if (cell.type == "X") {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(5.0),
        ),
      );
    }

    final isSelected = state is CrosswordLoaded &&
        state.selectedRow == row &&
        state.selectedCol == col;

    final isHighlighted = state is CrosswordLoaded &&
        state.highlightedCells.any(
          (highlighted) => highlighted[0] == row && highlighted[1] == col,
        );

    return GestureDetector(
      onTap: () {
        context.read<CrosswordBloc>().add(SelectCellEvent(row: row, col: col));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.amber
              : isHighlighted
                  ? Colors.grey[400]
                  : Colors.white,
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(
            color: Colors.black,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            if (cell.rif != null)
              Positioned(
                top: 4,
                left: 4,
                child: Text(
                  cell.rif!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
            Center(
              child: Text(
                cell.value ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      cell.isCorrect == true ? Colors.green[700] : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefinitionContainer(BuildContext context) {
    return BlocBuilder<CrosswordBloc, CrosswordState>(
      builder: (context, state) {
        if (state is CrosswordLoaded &&
            state.definition != null &&
            state.definition!.isNotEmpty) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.yellow.shade700,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                state.definition!,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBannerAd(BuildContext context) {
    return BlocBuilder<AdsBloc, AdsState>(
      builder: (context, adsState) {
        if (adsState is BannerAdLoaded) {
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            height: adsState.bannerAd.size.height.toDouble(),
            width: adsState.bannerAd.size.width.toDouble(),
            child: AdWidget(ad: adsState.bannerAd),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showCompletionDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return Container(
        alignment: Alignment.center,
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(
                  sigmaX: 5, sigmaY: 5), // Intensità del blur
              child: Container(
                color: Colors.black.withOpacity(0.3), // Colore di overlay
              ),
            ),
            // Dialog personalizzato
            Dialog(
              backgroundColor: Colors.transparent, // Sfondo trasparente per il blur
              insetPadding: const EdgeInsets.all(20), // Margine intorno al dialog
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[900], // Colore di sfondo del dialog
                  borderRadius: BorderRadius.circular(20), // Bordi arrotondati
                  border: Border.all(
                    color: const Color.fromARGB(255, 119, 119, 119),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Adatta il contenuto
                  children: [
                    // Icona e titolo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.green.shade400, size: 32),
                        const SizedBox(width: 8),
                        const Text(
                          'Complimenti!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Messaggio
                    const Text(
                      'Hai completato il livello. Vuoi raddoppiare le ricompense?',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Pulsanti
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Pulsante "Raddoppia"
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.withOpacity(0.9),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                            shadowColor: Colors.green.withOpacity(0.5),
                          ),
                          onPressed: () {
                            final adBloc = context.read<AdsBloc>();
                            adBloc.add(LoadRewardedAdEvent());

                            late StreamSubscription<AdsState> subscription;

                            subscription = adBloc.stream.listen((adState) {
                              if (adState is RewardedAdLoaded) {
                                adBloc.add(ShowRewardedAdEvent());
                              } else if (adState is RewardedAdClosed) {
                                Navigator.of(dialogContext).pop();
                                Navigator.of(context).pop();
                                subscription.cancel();
                              } else if (adState is RewardedAdFailed) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Failed to load ad: ${adState.error}')),
                                );
                                Navigator.of(dialogContext).pop();
                                Navigator.of(context).pop();
                                subscription.cancel();
                              }
                            });
                          },
                          child: const Text('Raddoppia'),
                        ),
                        const SizedBox(width: 16),
                        // Pulsante "Chiudi" in rosso
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.withOpacity(0.9),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                            shadowColor: Colors.redAccent.withOpacity(0.5),
                          ),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Chiudi'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}


  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Container(
          alignment: Alignment.center,
          child: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: 5, sigmaY: 5), // Intensità del blur
                child: Container(
                  color: Colors.black.withOpacity(0.3), // Colore di overlay
                ),
              ),
              // Dialog personalizzato
              Dialog(
                backgroundColor:
                    Colors.transparent, // Sfondo trasparente per il blur
                insetPadding:
                    const EdgeInsets.all(20), // Margine intorno al dialog
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[900], // Colore di sfondo del dialog
                    borderRadius:
                        BorderRadius.circular(20), // Bordi arrotondati
                    border: Border.all(
                      color: const Color.fromARGB(255, 119, 119, 119)
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Adatta il contenuto
                    children: [
                      // Icona e titolo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.red.shade400, size: 32),
                          const SizedBox(width: 8),
                          const Text(
                            'Conferma Uscita',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Messaggio
                      const Text(
                        'Sei sicuro di voler uscire dal livello corrente?',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Pulsanti
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Pulsante "No"
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.redAccent.withOpacity(0.9),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                              shadowColor: Colors.redAccent.withOpacity(0.5),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(); // Chiudi il dialog
                            },
                            child: const Text('No'),
                          ),
                          const SizedBox(width: 16),
                          // Pulsante "Sì"
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.withOpacity(0.9),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                              shadowColor: Colors.green.withOpacity(0.5),
                            ),
                            onPressed: () {
                              Navigator.of(dialogContext).pop(); // Chiudi il dialog
                              Navigator.of(context).pop(); // Torna indietro
                            },
                            child: const Text('Sì'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
