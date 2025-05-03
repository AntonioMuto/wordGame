import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:meta/meta.dart';

part 'ads_event.dart';
part 'ads_state.dart';

class AdsBloc extends Bloc<AdsEvent, AdsState> {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  Timer? _bannerRefreshTimer;
  RewardedInterstitialAd? _rewardedAd;

  AdsBloc() : super(AdsInitial()) {
    on<LoadBannerAdEvent>(_onLoadBannerAd);
    on<LoadInterstitialAdEvent>(_onLoadInterstitialAd);
    on<ShowInterstitialAdEvent>(_onShowInterstitialAd);
    on<LoadRewardedAdEvent>(_onLoadRewardedAd);
    on<ShowRewardedAdEvent>(_onShowRewardedAd);
    // Puoi aggiungere altri eventi qui come ShowAdEvent o LoadAdEvent (per interstitial o reward ads).
  }

  /// Logica per caricare un Banner Ad
  Future<void> _onLoadBannerAd(
      LoadBannerAdEvent event, Emitter<AdsState> emit) async {
    emit(AdsLoading());

    // Cancella eventuale timer precedente
    _bannerRefreshTimer?.cancel();

    // Dispose del banner attuale se esiste
    _bannerAd?.dispose();

    final completer = Completer<void>();

    final bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: 'ca-app-pub-6948080890496729/2835459661',
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _bannerAd = ad as BannerAd;
          emit(BannerAdLoaded(_bannerAd!));
          completer.complete();

          // Imposta il timer per ricaricare ogni 2 minuti
          _bannerRefreshTimer = Timer.periodic(const Duration(minutes: 2), (_) {
            add(LoadBannerAdEvent()); // Ri-trigger dell'evento
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load: $error');
          ad.dispose();
          emit(BannerAdFailed(error.toString()));
          completer.completeError(error);
        },
      ),
    );

    try {
      await bannerAd.load();
      await completer.future;
    } catch (e) {
      emit(BannerAdFailed(e.toString()));
    }
  }

  Future<void> _onLoadInterstitialAd(
      LoadInterstitialAdEvent event, Emitter<AdsState> emit) async {
    emit(AdsLoading());

    final completer = Completer<void>();

    InterstitialAd.load(
      adUnitId:
          'ca-app-pub-6948080890496729/8313751704', // Il tuo Interstitial Ad Unit ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          emit(InterstitialAdLoaded());

          // Configurazione dei listener per l'Interstitial
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdWillDismissFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              print("emit InterstitialAdClosed()");
              emit(InterstitialAdClosed());
              completer.complete();
            },
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              print("emit InterstitialAdClosed()");
              emit(InterstitialAdClosed());
              completer.complete();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              print("emit InterstitialAdClosed()");
              emit(InterstitialAdClosed());
              completer.completeError(error);
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          print("AD FLAILED TO LOAD: $error");
          emit(InterstitialAdFailed(error.toString()));
          completer.completeError(error);
        },
      ),
    );

    try {
      await completer.future;
    } catch (e) {
      emit(InterstitialAdFailed(e.toString()));
    }
  }

  /// Logica per mostrare un Interstitial Ad
  Future<void> _onShowInterstitialAd(
      ShowInterstitialAdEvent event, Emitter<AdsState> emit) async {
    if (_interstitialAd != null) {
      try {
        await _interstitialAd!.show();
      } catch (e) {
        emit(InterstitialAdFailed(e.toString()));
      }
    } else {
      emit(InterstitialAdFailed('Interstitial ad not ready'));
    }
  }

  Future<void> _onLoadRewardedAd(
      LoadRewardedAdEvent event, Emitter<AdsState> emit) async {
    final completer = Completer<void>();

    RewardedInterstitialAd.load(
      adUnitId:
          'ca-app-pub-6948080890496729/8313751704', // Il tuo Rewarded Ad Unit ID
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          emit(RewardedAdLoaded());

          // Configura il callback per il rewarded ad
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              emit(RewardedAdClosed());
              completer.complete();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewardedAd = null;
              completer.complete();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          emit(RewardedAdFailed(error.toString()));
          completer.completeError(error);
        },
      ),
    );

    try {
      await completer.future;
    } catch (e) {
      emit(RewardedAdFailed(e.toString()));
    }
  }

  /// Logica per mostrare il Rewarded Ad
  Future<void> _onShowRewardedAd(
      ShowRewardedAdEvent event, Emitter<AdsState> emit) async {
    if (_rewardedAd != null) {
      try {
        await _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
          // Esegui l'azione per premiare l'utente, ad esempio aggiungi ricompense
        });
      } catch (e) {
        emit(RewardedAdFailed(e.toString()));
      }
    } else {
      emit(RewardedAdFailed('Rewarded ad not ready'));
    }
  }

  /// Libera il banner ad quando non è più necessario
  @override
  Future<void> close() {
    _bannerRefreshTimer?.cancel();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    return super.close();
  }
}
