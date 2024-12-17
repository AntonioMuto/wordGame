import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              _showExitConfirmationDialog(context);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Sudoku Level $level',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              centerTitle: true,
              backgroundColor: Colors.blueGrey[900],
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
                  BlocBuilder<SudokuBloc, SudokuState>(
                      builder: (context, state) {
                        if (state is SudokuLoaded) {
                          return Keyboard(
                              onlyNumbers: true,
                              onKeyTap: (letter) {
                                  context
                                      .read<SudokuBloc>().add(InsertLetterEvent(letter: letter));
                              });
                        }
                        else {
                          return const SizedBox.shrink();
                        }
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCrosswordGrid(BuildContext context, double screenWidth) {
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
              padding: const EdgeInsets.all(12.3),
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
                    return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 200),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                              child: _buildCrosswordCell(
                                  context, row, col, state)),
                        ));
                  }));
        }
        return const Center(
            child: CircularProgressIndicator(color: Colors.white));
      },
    );
  }

  Widget _buildCrosswordCell(
      BuildContext context, int row, int col, SudokuLoaded state) {
    final isSelected = state.selectedRow == row && state.selectedCol == col;
    final cell = state.sudokuData[row][col];

    // Calcola i bordi spessi per separare i blocchi 3x3
    final bool isTopBorder = row % 3 == 0;
    final bool isLeftBorder = col % 3 == 0;
    final bool isBottomBorder =
        (row == 8 || row == 5 || row == 2); // Ultima riga
    final bool isRightBorder =
        (col == 8 || col == 5 || col == 2); // Ultima colonna

    return GestureDetector(
      onTap: () => context
          .read<SudokuBloc>()
          .add(SelectSudokuCell(row: row, column: col)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(255, 238, 238, 238)
              : Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.black,
              width: isTopBorder ? 2.3 : 1.0,
            ),
            left: BorderSide(
              color: Colors.black,
              width: isLeftBorder ? 2.3 : 1.0,
            ),
            bottom: BorderSide(
              color: Colors.black,
              width: isBottomBorder ? 2.3 : 1.0,
            ),
            right: BorderSide(
              color: Colors.black,
              width: isRightBorder ? 2.3 : 1.0,
            ),
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Center(
          child: Text(
            cell.value.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: cell.isHint
                  ? const Color.fromARGB(255, 109, 109, 109)
                  : Colors.black,
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
        return AlertDialog(
          backgroundColor: Colors.blueGrey[800], // Sfondo scuro
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Bordi arrotondati
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
              ), // Icona di completamento
              SizedBox(width: 9.0),
              Text('Complimenti!',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Hai completato il livello. Vuoi raddoppiare le ricompense?',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center, // Pulsanti centrati
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Colore verde per "Watch Ad"
                foregroundColor: Colors.white, // Testo bianco
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
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
                          content: Text('Failed to load ad: ${adState.error}')),
                    );
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pop();
                    subscription.cancel();
                  }
                });
              },
              child: const Text('Raddoppia'),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, // Testo bianco
              ),
              child: const Text('Chiudi'),
            ),
          ],
        );
      },
    );
  }

  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[800], // Sfondo scuro
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Bordi arrotondati
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.red), // Icona di avvertimento
              SizedBox(width: 8.0),
              Text(
                'Conferma Uscita',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Sei sicuro di voler uscire dal livello corrente?',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center, // Pulsanti centrati
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, // Colore rosso per "No"
                foregroundColor: Colors.white, // Testo bianco
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Chiudi il dialog
              },
              child: const Text('No'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Colore verde per "Sì"
                foregroundColor: Colors.white, // Testo bianco
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Chiudi il dialog
                Navigator.of(context).pop(); // Torna indietro
              },
              child: const Text('Sì'),
            ),
          ],
        );
      },
    );
  }
}
