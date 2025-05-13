import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<FetchProfileData>(_onFetchProfileData);
    on<EvaluateLoginData>(_onEvaluateProfileData);
    on<DecreaseTokenEvent>(_onDecreaseToken);
    on<IncreaseTokenEvent>(_onIncreaseToken);
  }

  Future<void> _onFetchProfileData(
      FetchProfileData event, Emitter<ProfileState> emit) async {
    emit(ProfileInitial());
    try {
      final url = Uri.parse(
          'https://raw.githubusercontent.com/AntonioMuto/wordGame/refs/heads/main/profile_data.json');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        emit(ProfileLoaded(
            username: jsonData['username'], token: jsonData['accessToken'], coins: jsonData['coins']));
      } else {
        throw Exception(
            'Errore nella risposta del server: ${response.statusCode}');
      }
    } catch (e) {
      emit(ProfileError('Errore nel caricamento dei dati: $e'));
      print(e);
    }
  }

  Future<void> _onDecreaseToken(
      DecreaseTokenEvent event, Emitter<ProfileState> emit) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(currentState.copyWith(coins: currentState.coins - event.coins));
    }
  }

  Future<void> _onIncreaseToken(
      IncreaseTokenEvent event, Emitter<ProfileState> emit) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(currentState.copyWith(coins: currentState.coins + event.coins));
    }
  }

  Future<void> _onEvaluateProfileData(
      EvaluateLoginData event, Emitter<ProfileState> emit) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(currentState.copyWith(username: event.username, token: event.token, coins: event.coins));
    }
  }
}
