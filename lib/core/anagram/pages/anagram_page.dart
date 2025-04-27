import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:word_game/core/ads/bloc/ads_bloc.dart';
import 'package:word_game/core/anagram/bloc/anagram_bloc.dart';
import 'package:word_game/core/timer/pages/timer.dart';

class AnagramPage extends StatelessWidget {
  final int level;

  const AnagramPage({Key? key, required this.level}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AnagramBloc()..add(FetchAnagramData())),
          BlocProvider(create: (_) => AdsBloc()..add(LoadBannerAdEvent())),
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
              if (!didPop) {
                _showExitConfirmationDialog(context);
              }
            },
            child: Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: Theme.of(context).primaryColorDark),
                  onPressed: () => _showExitConfirmationDialog(context),
                ),
                title: Text(
                  'Anagramma - Livello $level',
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 22,
                  ),
                ),
                centerTitle: true,
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
                child: SafeArea(
                  child: BlocBuilder<AnagramBloc, AnagramState>(
                      builder: (context, state) {
                    var started = false;
                    if (state is AnagramLoaded && state.started) {
                      started = state.started;
                    }
                    return Column(
                      children: [
                        const SizedBox(height: 50),
                        _buildCurrentWordGrid(context),
                        if (started) ...[
                          const SizedBox(height: 60),
                          _buildHistoryGrid(context),
                          const SizedBox(height: 20),
                          Expanded(child: _buildLetterGrid(context)),
                          _buildControlButtons(context),
                          const SizedBox(height: 15),
                        ],
                        if (!started) ...[
                          const Spacer(),
                          _modernButton(
                            context,
                            icon: Icons.play_arrow,
                            text: 'START',
                            color: Colors
                                .green, // Puoi scegliere un colore più caldo per "Cancella"
                            onPressed: () {
                              context
                                  .read<AnagramBloc>()
                                  .add(StartGameEvent());
                            },
                          ),
                          const Spacer(),
                        ],
                        _buildBannerAd(context),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ));
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
          final isError =
              state.currentWord.where((letter) => letter != '').length ==
                      state.solution.length &&
                  !isCompleted;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 1),
            // decoration: BoxDecoration(
            //   color: Theme.of(context).primaryColor,
            //   borderRadius: BorderRadius.circular(16),
            //   border: Border.all(
            //     color: isCompleted
            //         ? Colors.greenAccent
            //         : isError
            //             ? Colors.redAccent
            //             : Colors.grey,
            //     width: 2,
            //   ),
            //   boxShadow: [
            //     BoxShadow(
            //       color: isCompleted
            //           ? const Color.fromARGB(255, 99, 194, 102).withOpacity(0.18)
            //           : Colors.black.withOpacity(0.10),
            //       blurRadius: 12,
            //       offset: const Offset(0, 6),
            //     ),
            //   ],
            // ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(solutionLength, (index) {
                final letter = state.currentWord.isNotEmpty
                    ? state.currentWord[index]
                    : '';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        letter.toUpperCase(),
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: isCompleted
                              ? Colors.greenAccent
                              : isError
                                  ? Colors.redAccent
                                  : Theme.of(context).primaryColorDark,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              blurRadius: 5,
                              color: Theme.of(context).primaryColor,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width:
                            MediaQuery.of(context).size.width / solutionLength -
                                12,
                        height: 2,
                        color: isCompleted
                            ? Colors.greenAccent
                            : isError
                                ? Colors.redAccent
                                : Theme.of(context).primaryColorDark,
                      ),
                    ],
                  ),
                );
              }),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHistoryGrid(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const TimerCircle(
            duration: Duration(seconds: 12),
          ),
          const SizedBox(height: 12),
          Text(
            'Tempo rimanente'.toUpperCase(),
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSlotColor(bool isCompleted, String letter, bool isError) {
    if (isCompleted) return Colors.green[500]!;
    if (isError) return Colors.red[400]!;
    if (letter.isEmpty) return Colors.white.withOpacity(0.13);
    return Colors.blueAccent.withOpacity(0.85);
  }

  Widget _buildLetterGrid(BuildContext context) {
    return BlocBuilder<AnagramBloc, AnagramState>(
      builder: (context, state) {
        if (state is AnagramInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AnagramLoaded) {
          final letters = state.anagram;
          return Center(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: List.generate(letters.length, (index) {
                final letter = letters[index];
                final isLetterUsed = state.usedLetters.keys.contains(index);

                return GestureDetector(
                  onTap: isLetterUsed
                      ? null
                      : () {
                          context
                              .read<AnagramBloc>()
                              .add(AddLetterEvent(letter, index));
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isLetterUsed
                          ? Colors.grey[400]
                          : Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isLetterUsed ? Colors.grey : Colors.blueAccent,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(isLetterUsed ? 0.07 : 0.18),
                          blurRadius: isLetterUsed ? 2 : 8,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      letter.toUpperCase(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isLetterUsed
                            ? Colors.white70
                            : Colors.blueGrey[900],
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildControlButtons(BuildContext context) {
    return BlocBuilder<AnagramBloc, AnagramState>(
      builder: (context, state) {
        if (state is AnagramLoaded && !state.completed) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _modernButton(
                context,
                icon: Icons.reply,
                text: 'Cancella',
                color: Colors
                    .red, // Puoi scegliere un colore più caldo per "Cancella"
                onPressed: () {
                  context.read<AnagramBloc>().add(RemoveLastLetterEvent());
                },
              ),
              _modernButton(
                context,
                icon: Icons.help_center,
                text: 'Aiuto',
                color: Colors
                    .orange, // Puoi scegliere un colore più caldo per "Cancella"
                onPressed: () {
                  context.read<AnagramBloc>().add(RemoveLastLetterEvent());
                },
              ),
              _modernButton(
                context,
                icon: Icons.refresh,
                text: 'Ricomincia',
                color: Colors.blue, // Un blu fresco per "Ricomincia"
                onPressed: () {
                  context.read<AnagramBloc>().add(ResetWordAnagramEvent());
                },
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _modernButton(BuildContext context,
      {required IconData icon,
      required String text,
      required Color color,
      required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.92),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
        shadowColor: color.withOpacity(0.3),
      ),
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 22),
      label: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
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

  Widget _buildBannerAd(BuildContext context) {
    return BlocBuilder<AdsBloc, AdsState>(
      builder: (context, adsState) {
        if (adsState is BannerAdLoaded) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
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
