part of 'ads_bloc.dart';

@immutable
sealed class AdsEvent {}

/// Evento per caricare un Banner Ad
final class LoadBannerAdEvent extends AdsEvent {}

