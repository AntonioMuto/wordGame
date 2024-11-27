part of 'ads_bloc.dart';

@immutable
sealed class AdsState {}

/// Stato iniziale
final class AdsInitial extends AdsState {}

/// Stato durante il caricamento dell'annuncio
final class AdsLoading extends AdsState {}

/// Stato quando l'annuncio è stato caricato con successo
final class AdsLoaded extends AdsState {}

/// Stato quando l'annuncio è stato mostrato
final class AdsShown extends AdsState {}

/// Stato quando l'annuncio fallisce il caricamento
final class AdsFailedToLoad extends AdsState {
  final String error;

  AdsFailedToLoad(this.error);
}

/// Stato quando l'annuncio è stato chiuso
final class AdsClosed extends AdsState {}

/// Stato quando il Banner Ad è stato caricato con successo
final class BannerAdLoaded extends AdsState {
  final BannerAd bannerAd; // Riferimento all'oggetto Banner Ad

  BannerAdLoaded(this.bannerAd);
}

/// Stato quando il caricamento del Banner Ad fallisce
final class BannerAdFailed extends AdsState {
  final String error;

  BannerAdFailed(this.error);
}

class InterstitialAdLoaded extends AdsState {}
class InterstitialAdFailed extends AdsState {
  final String error;
  InterstitialAdFailed(this.error);
}

class RewardedAdLoaded extends AdsState {}
class RewardedAdFailed extends AdsState {
  final String error;
  RewardedAdFailed(this.error);
}