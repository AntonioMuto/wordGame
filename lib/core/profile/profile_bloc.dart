import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<FetchProfileData>(_onFetchProfileData);
  }

  Future<void> _onFetchProfileData(FetchProfileData event, Emitter<ProfileState> emit) async {
    print("ADWDIOAWDOAWIDINW");
    emit(ProfileInitial());
    try {
      final url = Uri.parse('https://raw.githubusercontent.com/AntonioMuto/wordGame/refs/heads/main/profile_data.json');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print(response.body);
        emit(ProfileLoaded(
          username: jsonData['username'],
          token: jsonData['token']
        ));
      } else {
        throw Exception('Errore nella risposta del server: ${response.statusCode}');
      }
    } catch (e) {
      emit(ProfileError('Errore nel caricamento dei dati: $e'));
      print(e);
    }
  
  }
}
