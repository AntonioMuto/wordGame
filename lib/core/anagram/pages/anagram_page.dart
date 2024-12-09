import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
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
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
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
                  child: const Icon(Icons.reply_sharp, color: Colors.amber, size: 24)
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<AnagramBloc>().add(ResetWordAnagramEvent());
                  },
                  child: const Icon(Icons.cleaning_services, color: Colors.amber, size: 24),
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
        return AlertDialog(
          backgroundColor: Colors.blueGrey[800], // Sfondo scuro
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Bordi arrotondati
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green,), // Icona di completamento
              SizedBox(width: 9.0),
              Text('Complimenti!',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                      SnackBar(content: Text('Failed to load ad: ${adState.error}')),
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
              Icon(Icons.warning_amber_rounded, color: Colors.red), // Icona di avvertimento
              SizedBox(width: 8.0),
              Text(
                'Conferma Uscita',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
