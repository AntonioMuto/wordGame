import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:word_game/core/ads/bloc/ads_bloc.dart';
import 'package:word_game/core/crossword/pages/keyboard.dart';
import 'package:word_game/core/findword/bloc/findword_bloc.dart';
import 'package:word_game/core/searchword/bloc/searchword_bloc.dart';
import 'package:word_game/data_models/SearchWordCell.dart';

class SearchWord extends StatelessWidget {
  final int level;
  const SearchWord({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SearchwordBloc()..add(FetchSearchWordData()),
        ),
        BlocProvider(
          create: (_) => AdsBloc()..add(LoadBannerAdEvent()),
        ),
      ],
      child: BlocListener<SearchwordBloc, SearchwordState>(
        listener: (context, state) {
          if (state is SearchwordLoaded && state.completed) {
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
            'Cerca le Parole Level $level',
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
              _buildSearchWordGrid(context, screenWidth),
              const Spacer(),
              _buildBannerAd(context),
            ],
          ),
      ),
        ),
      ),
    ));
  }

  Widget _buildSearchWordGrid(BuildContext context, double screenWidth) {
    return BlocBuilder<SearchwordBloc, SearchwordState>(
        builder: (context, state) {
          if (state is SearchwordLoaded) {
            final cols = state.maxCol ?? 0;
            final rows = state.maxRow ?? 0;
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
                  final SearchWordCell cell = state.currentWord![row][col];
                  final bool isSelected = false;
                  // final bool isSelected = (state.selectedRow != -1 && state.selectedCol != -1 && state.selectedRow == row && state.selectedCol == col);
                  return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 200),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child:  _buildSearchwordCell(context, cell, row, col, state, isSelected)
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

  Widget _buildSearchwordCell(BuildContext context, SearchWordCell cell, int row, int col, SearchwordLoaded state, bool isSelected) {
    return GestureDetector(
      onTap: () {
        // if(state.currentRow == row){
        //   context.read<FindwordBloc>().add(ChangeSelectedCellEvent(row, col));
        // }
      },
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(5.0),
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


    void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
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
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
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
                foregroundColor: Colors.white,
              ),
              child: const Text('Chiudi'),
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

}