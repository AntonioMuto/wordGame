import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

part 'anagram_event.dart';
part 'anagram_state.dart';

class AnagramBloc extends Bloc<AnagramEvent, AnagramState> {
  AnagramBloc() : super(AnagramLoaded(anagram: [], solution: [], currentWord: [])) {
    on<FetchAnagramData>(_onFetchAnagramData);
  }


  Future<void> _onFetchAnagramData(FetchAnagramData event, Emitter<AnagramState> emit) async {
    emit(AnagramInitial());

    try {
      final url = Uri.parse('https://raw.githubusercontent.com/AntonioMuto/wordGame/refs/heads/main/anagram.json');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        final anagramData = _parseAnagramData(jsonData);

        emit(AnagramLoaded(anagram: anagramData, solution: [], currentWord: []));
      } else {
        throw Exception('Errore nella risposta del server: ${response.statusCode}');
      }
    } catch (e) {
      emit(AnagramError('Errore nel caricamento dei dati: $e'));
      print(e);
    }
  }

  List<String> _parseAnagramData(Map<String, dynamic> json) {
    final anagramList = json['anagram'] as List<dynamic>?;

    if (anagramList == null) return [];

    return anagramList.cast<String>();
  }
}
