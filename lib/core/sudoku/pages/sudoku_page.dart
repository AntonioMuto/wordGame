import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:word_game/core/ads/bloc/ads_bloc.dart';
import 'package:word_game/core/crossword/pages/keyboard.dart';
import 'package:word_game/core/sudoku/bloc/sudoku_bloc.dart';

class SudokuPage extends StatelessWidget {
  final int level;
  const SudokuPage({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SudokuBloc()..add(FetchSudokuData()),
        ),
        BlocProvider(
          create: (_) => AdsBloc()..add(LoadBannerAdEvent()),
        ),
      ],
      child: BlocListener<SudokuBloc, SudokuState>(
        listener: (context, state) {
          if (state is SudokuLoaded && state.completed) {
            _showCompletionDialog(context);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Sudoku Level $level',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.blueGrey[900],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black87, Colors.blueGrey.shade800],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSudokuGrid(context, screenWidth),
                Column(
                  children: [
                    _buildBannerAd(context),
                    BlocBuilder<SudokuBloc, SudokuState>(
                      builder: (context, state) {
                        if (state is SudokuLoaded) {
                          return Keyboard(
                            onlyNumbers: true,
                            onKeyTap: (letter) {
                              if (letter == 'delete') {
                                context.read<SudokuBloc>().add(RemoveLetterEvent());
                              } else {
                                context.read<SudokuBloc>().add(InsertLetterEvent(letter: letter));
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
              ],
            ),
          ),
        ),
      ),
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

  Widget _buildSudokuGrid(BuildContext context, double screenWidth) {
    return BlocBuilder<SudokuBloc, SudokuState>(
      builder: (context, state) {
        if (state is SudokuLoaded) {
          if (state.sudokuData.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          const rows = 9;
          const cols = 9;
          final cellSize = screenWidth / cols;
          final crosswordHeight = cellSize * rows;

          return Container(
            height: crosswordHeight,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 59, 59, 59).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(137, 59, 59, 59),
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
                return Container(
                  child: AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 200),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _buildSudokuCell(context, row, col, state),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const Center(child: CircularProgressIndicator(color: Colors.white));
      },
    );
  }

  Widget _buildSudokuCell(BuildContext context, int row, int col, SudokuLoaded state) {
    final isSelected = state.selectedRow == row && state.selectedCol == col;
    final cell = state.sudokuData[row][col];

    final bool isTopBorder = row % 3 == 0;
    final bool isLeftBorder = col % 3 == 0;
    final bool isBottomBorder = row == 8 || row == 5 || row == 2;
    final bool isRightBorder = col == 8 || col == 5 || col == 2;

    return GestureDetector(
      onTap: () {
        if (cell.isHint) return;
        context.read<SudokuBloc>().add(SelectSudokuCell(row: row, column: col));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(255, 102, 102, 102) : const Color.fromARGB(255, 72, 72, 72),
          border: Border(
            top: BorderSide(
              color: Colors.black,
              width: isTopBorder ? 3.0 : 1.0,
            ),
            left: BorderSide(
              color: Colors.black,
              width: isLeftBorder ? 3.0 : 1.0,
            ),
            bottom: BorderSide(
              color: Colors.black,
              width: isBottomBorder ? 3.0 : 1.0,
            ),
            right: BorderSide(
              color: Colors.black,
              width: isRightBorder ? 3.0 : 1.0,
            ),
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Center(
          child: Text(
            cell.value.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: cell.isHint ? const Color.fromARGB(255, 10, 10, 10) : const Color.fromARGB(255, 253, 252, 251),
            ),
          ),
        ),
      ),
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

}
