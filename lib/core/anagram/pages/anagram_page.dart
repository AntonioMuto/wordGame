import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:word_game/controllers/playSounds_controller.dart';
import 'package:word_game/core/ads/bloc/ads_bloc.dart';
import 'package:word_game/core/anagram/bloc/anagram_bloc.dart';

class AnagramPage extends StatelessWidget {
  final int level;

  const AnagramPage({Key? key, required this.level}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AnagramBloc()..add(FetchAnagramData()),
        ),
        BlocProvider(
          create: (_) => AdsBloc()..add(LoadBannerAdEvent()),
        ),
      ],
      child: BlocListener<AnagramBloc, AnagramState>(
        listener: (context, state) {
          if (state is AnagramLoaded && state.completed) {
            _showCompletionDialog(context);
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
            'Anagram Level $level',
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
              _buildCurrentWordGrid(context),
              const Spacer(),
              _buildBannerAd(context),
              _buildLetterGrid(context),
              _buildControlButtons(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    )
    ) );
  }

  Widget _buildCurrentWordGrid(BuildContext context) {
    return BlocBuilder<AnagramBloc, AnagramState>(
      builder: (context, state) {
        if (state is AnagramInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AnagramLoaded) {
          final solutionLength = state.currentWord.isNotEmpty
              ? state.currentWord.length
              : state.anagram.length;
          final isCompleted = state.completed;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                const BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: solutionLength.clamp(1, 8), // Mantieni leggibile
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: solutionLength,
              itemBuilder: (context, index) {
                final letter = state.currentWord.length > index
                    ? state.currentWord[index]
                    : '';
                final isError = state.currentWord.where((letter) => letter != '').length == state.solution.length && !isCompleted;
                return GestureDetector(
                  onTap: () {
                    context.read<AnagramBloc>().add(RemoveElementEventByPosition(index, letter));
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _loadCurrentWordColor(isCompleted, letter, isError),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.black12, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      letter.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLetterGrid(BuildContext context) {
    return BlocBuilder<AnagramBloc, AnagramState>(
      builder: (context, state) {
        if (state is AnagramInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AnagramLoaded) {
          final letters = state.anagram;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                const BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: letters.length,
              itemBuilder: (context, index) {
                final letter = letters[index];
                final isLetterUsed = state.usedLetters.keys.contains(index);
                
                return GestureDetector(
                  onTap: isLetterUsed
                      ? null // Non permette di selezionare la lettera se già usata
                      : () {
                          context.read<AnagramBloc>().add(AddLetterEvent(letter,index));
                        },
                  child: _buildLetterTile(letter, isLetterUsed),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLetterTile(String letter, bool isLetterUsed) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isLetterUsed ? Colors.grey : Colors.blueGrey.shade100,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.blueGrey, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Text(
        letter.toUpperCase(),
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
}

  Widget _buildControlButtons(BuildContext context) {
    return BlocBuilder<AnagramBloc, AnagramState>(
      builder: (context, state) {
        if (state is AnagramInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AnagramLoaded) {
          if(!state.completed){
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.read<AnagramBloc>().add(RemoveLastLetterEvent());
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('CANCELLA  ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                      Icon(Icons.reply_sharp, color: Colors.amber, size: 24),
                    ],
                  )
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<AnagramBloc>().add(ResetWordAnagramEvent());
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('RICOMINCIA  ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                      Icon(Icons.cleaning_services, color: Colors.amber, size: 24),
                    ],
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

  _loadCurrentWordColor(bool isCompleted, String letter, bool isError) {
    if (isCompleted) {
      return Colors.green[700];
    } else {
      if(isError){
        return Colors.red[700];
      } else {
        if (letter.isEmpty) {
          return Colors.grey[400];
        } else {
          return Colors.blueGrey[200];
        }
      }
    }
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
}
