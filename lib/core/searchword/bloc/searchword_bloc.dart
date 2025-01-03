import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:word_game/data_models/FindWordCell.dart';
import 'package:word_game/data_models/SearchWordCell.dart';
import 'package:http/http.dart' as http;

part 'searchword_event.dart';
part 'searchword_state.dart';

class SearchwordBloc extends Bloc<SearchwordEvent, SearchwordState> {
  SearchwordBloc() : super(SearchwordInitial()) {
    on<FetchSearchWordData>(_onFetchSearchWordData);
  }

  void _onFetchSearchWordData(FetchSearchWordData event, Emitter<SearchwordState> emit) async {
    emit(SearchwordInitial());
    try {
      final url = Uri.parse('https://raw.githubusercontent.com/AntonioMuto/wordGame/refs/heads/main/searchword.json');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

      }
    } catch (e) {
      emit(SearchWordError('Errore nel caricamento dei dati: $e'));
      print(e);
    }
  }
}
