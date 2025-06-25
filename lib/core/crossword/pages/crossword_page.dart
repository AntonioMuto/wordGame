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
import 'package:word_game/core/profile/profile_bloc.dart';
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
          create: (_) => CrosswordBloc([])..add(FetchCrosswordData(level: level)),
        ),
        BlocProvider(
          create: (_) => AdsBloc()..add(LoadBannerAdEvent()),
        ),
      ],
      child: BlocListener<CrosswordBloc, CrosswordState>(
        listener: (context, state) {
          if (state is CrosswordLoaded && state.completed) {
            _showCompletionDialog(context);
            context.read<ProfileBloc>().add(IncreaseTokenEvent(5));
          }
          if (state is CrosswordLoaded && state.hintedCorrectly) {
            context.read<ProfileBloc>().add(DecreaseTokenEvent(10));
            context.read<CrosswordBloc>().add(ResetHintEvent());
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
                icon: Icon(Icons.arrow_back,
                    color:
                        Theme.of(context).primaryColorDark), // Freccia indietro
                onPressed: () {
                  // Mostra un dialog di conferma
                  _showExitConfirmationDialog(context);
                },
              ),
              actions: [
                BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, profileState) {
                    return BlocBuilder<CrosswordBloc, CrosswordState>(
                      builder: (context, crosswordState) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (profileState is ProfileLoaded) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.amber[700]!, width: 2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.monetization_on,
                                        color: Colors.amber[700], size: 20),
                                    SizedBox(width: 6),
                                    Text(
                                      profileState.coins.toString(),
                                      style: TextStyle(
                                        color: Colors.amber[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (crosswordState is CrosswordLoaded) ...[
                              IconButton(
                                icon: Icon(Icons.lightbulb,
                                    color: crosswordState
                                            .highlightedCells.isNotEmpty
                                        ? Colors.amber[400]
                                        : Colors.grey[400]),
                                onPressed: () {
                                  if (crosswordState.highlightedCells.isEmpty) {
                                    return;
                                  }
                                  context.read<CrosswordBloc>().add(ToggleHintEvent());
                                },
                              ),
                            ]
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
              backgroundColor: Theme.of(context).primaryColor,
              elevation: 4.0,
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor
                  ],
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
        return Padding(
          padding: EdgeInsets.only(
              top: (MediaQuery.of(context).size.height / 2) - 100),
          child: Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColorDark)),
        );
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
        // Fallback size (es: standard 320x50 per banner)
        const double bannerHeight = 50.0;
        const double bannerWidth = 320.0;

        if (adsState is BannerAdLoaded) {
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            height: adsState.bannerAd.size.height.toDouble(),
            width: adsState.bannerAd.size.width.toDouble(),
            color: Colors.transparent,
            child: AdWidget(ad: adsState.bannerAd),
          );
        }

        // Quando sta caricando o rinfrescando, mantiene lo spazio
        return const SizedBox.shrink();
      },
    );
  }

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade900.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events_rounded,
                        color: Colors.amber.shade300, size: 40),
                    const SizedBox(height: 16),
                    const Text(
                      'Livello completato!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Vuoi raddoppiare le ricompense guardando un annuncio?',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.white70),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Chiudi'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              final adBloc = context.read<AdsBloc>();
                              adBloc.add(LoadRewardedAdEvent());

                              late StreamSubscription<AdsState> subscription;

                              subscription = adBloc.stream.listen((adState) {
                                print(adState);
                                if (adState is RewardedAdLoaded) {
                                  adBloc.add(ShowRewardedAdEvent());
                                } else if (adState is RewardedAdClosed) {
                                  Navigator.of(dialogContext).pop();
                                  subscription.cancel();
                                } else if (adState is RewardedAdFailed) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Errore caricamento annuncio: ${adState.error}'),
                                    ),
                                  );
                                  Navigator.of(dialogContext).pop();
                                  subscription.cancel();
                                } else if (adState is RewardedAdCompleted) {
                                  context
                                      .read<ProfileBloc>()
                                      .add(IncreaseTokenEvent(5));
                                  Navigator.of(dialogContext).pop();
                                  subscription.cancel();
                                }
                              });
                            },
                            child: const Text('Raddoppia'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade900.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.orangeAccent.shade200, size: 40),
                    const SizedBox(height: 16),
                    const Text(
                      'Uscire dal livello?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Sei sicuro di voler abbandonare il livello attuale? I tuoi progressi potrebbero andare persi.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.white70),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            child: const Text('Annulla'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(dialogContext)
                                  .pop(); // Chiudi modale
                              Navigator.of(context)
                                  .pop(); // Esci dalla schermata
                            },
                            child: const Text('Esci'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
