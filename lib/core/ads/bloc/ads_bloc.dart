import 'package:bloc/bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:meta/meta.dart';

part 'ads_event.dart';
part 'ads_state.dart';

class AdsBloc extends Bloc<AdsEvent, AdsState> {
  BannerAd? _bannerAd;

  AdsBloc() : super(AdsInitial()) {
    on<LoadBannerAdEvent>(_onLoadBannerAd);
    // Puoi aggiungere altri eventi qui come ShowAdEvent o LoadAdEvent (per interstitial o reward ads).
  }

  /// Logica per caricare un Banner Ad
  Future<void> _onLoadBannerAd(LoadBannerAdEvent event, Emitter<AdsState> emit) async {
    emit(AdsLoading()); // Stato di caricamento iniziale

    final bannerAd = BannerAd(
      size: AdSize.banner, // Specifica la dimensione del banner
      adUnitId: 'ca-app-pub-6948080890496729/2835459661', // Sostituisci con il tuo Banner Ad Unit ID
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _bannerAd = ad as BannerAd; // Salva il banner caricato
          emit(BannerAdLoaded(_bannerAd!)); // Stato di successo
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose(); // Libera le risorse in caso di errore
          emit(BannerAdFailed(error.toString())); // Stato di errore
        },
      ),
    );

    try {
      bannerAd.load(); // Avvia il caricamento del banner
    } catch (e) {
      emit(BannerAdFailed(e.toString())); // Gestisce errori inaspettati
    }
  }

  /// Libera il banner ad quando non è più necessario
  @override
  Future<void> close() {
    _bannerAd?.dispose();
    return super.close();
  }
}
