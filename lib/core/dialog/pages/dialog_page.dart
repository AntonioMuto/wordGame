import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../ads/bloc/ads_bloc.dart';
import '../../timer/bloc/timer_bloc.dart';
import '../bloc/dialog_bloc.dart';

class DialogManager extends StatelessWidget {
  final String dialogId;
  final DialogType type;
  final Widget child;

  const DialogManager({
    super.key,
    required this.dialogId,
    required this.type,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<DialogBloc, DialogState>(
      listenWhen: (prev, curr) =>
          (curr is DialogVisible) ||
          (curr is DialogHidden && prev is DialogVisible),
      listener: (context, state) async {
        if (state is DialogHidden) {
          // Chiudi il dialog attuale se presente
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        }
        if (state is DialogVisible) {
          // Aspetta che il dialog precedente sia chiuso
          await Future.delayed(Duration.zero);
          _showDialogByType(context, state.type);
        }
      },
      child: child,
    );
  }

  void _showDialogByType(BuildContext context, DialogType type) {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (type) {
        case DialogType.completion:
          _showCompletionDialog(context);
          break;
        case DialogType.timeout:
          _showTimeoutDialog(context);
          break;
        case DialogType.exitConfirmation:
          _showExitConfirmationDialog(context);
          break;
      }
    });
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

  void _showTimeoutDialog(BuildContext context) {
    print(context);
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
                    Icon(Icons.timer_outlined, color: Colors.red, size: 40),
                    const SizedBox(height: 16),
                    const Text(
                      'Tempo scaduto!',
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
                              backgroundColor: Colors.amber.shade700,
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
                                if (adState is RewardedAdLoaded) {
                                  adBloc.add(ShowRewardedAdEvent());
                                } else if (adState is RewardedAdClosed) {
                                  Navigator.of(dialogContext).pop();
                                  context
                                      .read<TimerBloc>()
                                      .add(const TimerRestart(30000));
                                } else if (adState is RewardedAdFailed) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Errore caricamento annuncio: ${adState.error}'),
                                    ),
                                  );
                                  Navigator.of(dialogContext).pop();
                                  subscription.cancel();
                                }
                              });
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text('+ 30s'),
                              ],
                            ),
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
