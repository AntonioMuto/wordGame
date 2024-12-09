import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

part 'findword_event.dart';
part 'findword_state.dart';

class FindwordBloc extends Bloc<FindwordEvent, FindwordState> {
  FindwordBloc() : super(FindwordInitial()) {
    on<FetchFindWordData>(_onFetchFindWordData);
  }

  Future<void> _onFetchFindWordData(FetchFindWordData event, Emitter<FindwordState> emit) async {
    emit(FindwordInitial());
    try {
      final url = Uri.parse('https://raw.githubusercontent.com/AntonioMuto/wordGame/refs/heads/main/findword.json');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        final List<String> correctWords = (jsonData['solution'] as List<dynamic>).map((e) => e as String).toList();

        final List<String> initialCurrentWord = List.generate(correctWords.length, (index) => "");

        emit(FindwordLoaded(
          solution: correctWords,
          currentWord: initialCurrentWord,
        ));
        print('FindwordLoaded emitted: $correctWords');
      } else {
        throw Exception('Errore nella risposta del server: ${response.statusCode}');
      }
    } catch (e) {
      emit(FindwordError('Errore nel caricamento dei dati: $e'));
      print(e);
    }
  }

}
