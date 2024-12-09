import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_game/core/ads/bloc/ads_bloc.dart';
import 'package:word_game/core/findword/bloc/findword_bloc.dart';

class FindWordPage extends StatelessWidget {
  final int level;
  const FindWordPage({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
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
        body: const Placeholder()
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
}