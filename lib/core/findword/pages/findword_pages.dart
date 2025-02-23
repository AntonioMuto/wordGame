import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:word_game/core/ads/bloc/ads_bloc.dart';
import 'package:word_game/core/crossword/pages/keyboard.dart';
import 'package:word_game/core/findword/bloc/findword_bloc.dart';
import 'package:word_game/data_models/FindWordCell.dart';

class FindWordPage extends StatelessWidget {
  final int level;
  const FindWordPage({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => FindwordBloc()..add(FetchFindWordData()),
        ),
        BlocProvider(
          create: (_) => AdsBloc()..add(LoadBannerAdEvent()),
        ),
      ],
      child: BlocListener<FindwordBloc, FindwordState>(
        listener: (context, state) {
          if (state is FindwordLoaded && state.completed) {
            _showCompletionDialog(context);
          }
          if (state is FindwordLoaded && !state.completed && state.failed) {
            state.maxRow < 6 ? _showFailedDialog(context, false) : _showFailedDialog(context, true);
          }
        },
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if(!didPop){
              _showExitConfirmationDialog(context);
            }
          },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Trova la Parola Level $level',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
              const SizedBox(height: 20),
              _buildFindWordGrid(context, screenWidth),
              const Spacer(),
              _buildBannerAd(context),
              BlocBuilder<FindwordBloc, FindwordState>(
                      builder: (context, state) {
                        if (state is FindwordLoaded) {
                                return Keyboard(
                                  onlyNumbers: false,
                                  onKeyTap: (letter) {
                                    if (letter == 'delete') {
                                      context.read<FindwordBloc>().add(RemoveLetterEvent());
                                    } else if (letter == 'clean') {
                                      context.read<FindwordBloc>().add(ResetWordEvent());
                                    } else {
                                      context.read<FindwordBloc>().add(InsertLetterEvent(letter));
                                    }
                                  },
                                );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
              _buildButtons(context),
            ],
          ),
      ),
        ),
      ),
    ));
  }

  Widget _buildFindWordGrid(BuildContext context, double screenWidth) {
    return BlocBuilder<FindwordBloc, FindwordState>(
        builder: (context, state) {
          if (state is FindwordLoaded) {
            final cols = state.solution.length;
            final rows = state.maxRow;
            final cellSize = screenWidth / (cols + 1);
            final crosswordHeight = cellSize * (rows + 1);

            return Container(
              height: crosswordHeight,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0,
                ),
                itemCount: rows * cols,
                itemBuilder: (context, index) {
                  final int row = index ~/ cols;
                  final int col = index % cols;
                  final Findwordcell cell = state.currentWord[row][col];
                  final bool isSelected = (state.selectedRow != -1 && state.selectedCol != -1 && state.selectedRow == row && state.selectedCol == col);
                  return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 200),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child:  _buildFindwordCell(context, cell, row, col, state, isSelected)
                        ),
                      ));
                    }
                  )
            );
          }
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        },
      );
  }

  Widget _buildFindwordCell(BuildContext context, Findwordcell cell, int row, int col, FindwordLoaded state, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if(state.currentRow == row){
          context.read<FindwordBloc>().add(ChangeSelectedCellEvent(row, col));
        }
      },
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _setColorByType(cell, isSelected),
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(
              color: const Color.fromARGB(255, 88, 88, 88),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
                  cell.letter ?? '',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
          ) ),
    );
  }

  _setColorByType(Findwordcell cell, bool isSelected) {
    switch (cell.type) {
      case 'X':
        return isSelected ? Colors.grey[500]: Colors.grey[700];
      case 'O':
        return Colors.green[600];
      case '%':
        return Colors.amber[400];
      default:
        return isSelected ? Colors.grey[500]: Colors.grey[700];
    }
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

  void _showFailedDialog(BuildContext context, bool endGame) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return Container(
        alignment: Alignment.center,
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Intensità del blur
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
                        Icon(Icons.cancel, color: Colors.red.shade400, size: 32),
                        const SizedBox(width: 8),
                        const Text(
                          'Peccato !!',
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
                    Text(
                      !endGame 
                        ? 'Non sei riuscito a completare il livello, vuoi continuare la partita?' 
                        : 'Non sei riuscito a completare il livello, ritenta!',
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Pulsanti
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Pulsante "Continua" verde
                        !endGame ? ElevatedButton(
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
                            if (!endGame) {
                              final adBloc = context.read<AdsBloc>();
                              adBloc.add(LoadRewardedAdEvent());

                              late StreamSubscription<AdsState> subscription;

                              subscription = adBloc.stream.listen((adState) {
                                if (adState is RewardedAdLoaded) {
                                  adBloc.add(ShowRewardedAdEvent());
                                } else if (adState is RewardedAdClosed) {
                                  Navigator.of(dialogContext).pop(); 
                                  context.read<FindwordBloc>().add(ContinueLevelEvent());
                                  subscription.cancel();
                                } else if (adState is RewardedAdFailed) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to load ad: ${adState.error}')),
                                  );
                                  Navigator.of(dialogContext).pop();
                                  Navigator.of(context).pop();
                                  subscription.cancel();
                                }
                              });
                            }
                          },
                          child: const Text('Continua'),
                        ) : const SizedBox.shrink(),
                        const SizedBox(width: 10),
                        // Pulsante "Chiudi" in rosso
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
                      color: const Color.fromARGB(255, 80, 80, 80)
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

  Widget _buildButtons(BuildContext context) {
    return BlocBuilder<FindwordBloc, FindwordState>(
      builder: (context, state) {
        if (state is FindwordInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is FindwordLoaded) {
          if(!state.completed){
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // ElevatedButton(
                //   onPressed: () {
                //     // context.read<FindwordBloc>().add(RemoveLastLetterEvent());
                //   },
                //   child: const Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text('CANCELLA  ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                //       Icon(Icons.reply_sharp, color: Colors.amber, size: 24),
                //     ],
                //   )
                // ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<FindwordBloc>().add(SubmitWordEvent());
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('INVIA  ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                        Icon(Icons.send, color: Colors.amber, size: 24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const SizedBox.shrink();
          }
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}