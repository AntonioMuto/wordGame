part of 'ads_bloc.dart';

@immutable
sealed class AdsEvent {}

/// Evento per caricare un Banner Ad
final class LoadBannerAdEvent extends AdsEvent {}

class LoadInterstitialAdEvent extends AdsEvent {}
class ShowInterstitialAdEvent extends AdsEvent {}

class LoadRewardedAdEvent extends AdsEvent {}
class ShowRewardedAdEvent extends AdsEvent {}