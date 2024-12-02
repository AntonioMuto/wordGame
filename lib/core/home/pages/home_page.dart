import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:word_game/core/ads/bloc/ads_bloc.dart';
import 'package:word_game/core/home/bloc/home_bloc.dart';
import 'package:word_game/core/home/pages/game_section_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeInitial) {
          return const Center(child: CircularProgressIndicator(color: Colors.white,)); // Loading
        } else if (state is HomeLoaded) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: state.sections.length,
                  itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: GameSectionCard(section: state.sections[index])
                      ),
                    ));
                  }
                ),
              ),
              _buildBannerAd(context)
            ],
          );
        } else if (state is HomeError) {
          return const Center(child: Text("Errore di caricamento"));
        } else {
          return const Center(child: Text("Stato sconosciuto"));
        }
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
