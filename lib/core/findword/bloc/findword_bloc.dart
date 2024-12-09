import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:word_game/data_models/FindWordCell.dart';

part 'findword_event.dart';
part 'findword_state.dart';

class FindwordBloc extends Bloc<FindwordEvent, FindwordState> {
  FindwordBloc() : super(FindwordInitial()) {
    on<FetchFindWordData>(_onFetchFindWordData);
    on<InsertLetterEvent>(_onInsertLetter);
    on<RemoveLetterEvent>(_onRemoveLetter);
    on<ResetWordEvent>(_onResetWord);
  }

  Future<void> _onFetchFindWordData(FetchFindWordData event, Emitter<FindwordState> emit) async {
    emit(FindwordInitial());
    try {
      final url = Uri.parse('https://raw.githubusercontent.com/AntonioMuto/wordGame/refs/heads/main/findword.json');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        final List<String> correctWords = (jsonData['solution'] as List<dynamic>).map((e) => e as String).toList();

        final List<List<Findwordcell>> initialCurrentWord = List.generate(
            5, 
            (index) => List.generate(correctWords.length, (_) => Findwordcell(type: "X", letter: ""))
          );
        emit(FindwordLoaded(
          solution: correctWords,
          currentWord: initialCurrentWord,
          selectedCol: 0,
          selectedRow: 0,
          currentRow: 0
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

  Future<void> _onInsertLetter(InsertLetterEvent event, Emitter<FindwordState> emit) async {
    if (state is FindwordLoaded) {
      final currentState = state as FindwordLoaded;
      var newCurrentWord = List<List<Findwordcell>>.from(currentState.currentWord!);

      newCurrentWord[currentState.selectedRow!][currentState.selectedCol!].letter = event.letter;
      
      var newSelectedCol = currentState.selectedCol;
      var newSelectedRow = currentState.selectedRow;
      var newCurrentRow = currentState.currentRow;

      if(newSelectedCol != null && currentState.currentWord[currentState.currentRow].length - 1 > currentState.selectedCol!) {
        newSelectedCol = currentState.selectedCol! + 1;
      }
      if(newSelectedCol != null && newSelectedCol >= currentState.currentWord[currentState.currentRow].length - 1) {
        newSelectedCol = -1;
        newSelectedRow = -1;
      }

      emit(currentState.copyWith(currentWord: newCurrentWord, selectedCol: newSelectedCol, selectedRow: newSelectedRow, currentRow: newCurrentRow));
    }
  }

  Future<void> _onRemoveLetter(RemoveLetterEvent event, Emitter<FindwordState> emit) async {
    if (state is FindwordLoaded) {
      final currentState = state as FindwordLoaded;
      var newCurrentWord = List<List<Findwordcell>>.from(currentState.currentWord!);

      newCurrentWord[currentState.selectedRow!][currentState.selectedCol!].letter = '';
      
      var newSelectedCol = currentState.selectedCol;
      var newSelectedRow = currentState.selectedRow;
      var newCurrentRow = currentState.currentRow;

      if(newSelectedCol != null && currentState.selectedCol! > 0) {
        newSelectedCol = currentState.selectedCol! - 1;
      }
      if(newSelectedCol != null && newSelectedCol <= 0) {
        newSelectedCol = 0;
        newSelectedRow = 0;
      }

      emit(currentState.copyWith(currentWord: newCurrentWord, selectedCol: newSelectedCol, selectedRow: newSelectedRow, currentRow: newCurrentRow));
    }
  }

  Future<void> _onResetWord(ResetWordEvent event, Emitter<FindwordState> emit) async {
    if (state is FindwordLoaded) {
      final currentState = state as FindwordLoaded;
      var newCurrentWord = List<List<Findwordcell>>.from(currentState.currentWord!);
    
      var newSelectedCol = currentState.selectedCol;
      var newSelectedRow = currentState.selectedRow;
      
      for(var i = 0; i < newCurrentWord[currentState.currentRow].length; i++) {
        newCurrentWord[currentState.currentRow][i].letter = '';
      }
      
      newSelectedCol = 0;
      newSelectedRow = 0;

      emit(currentState.copyWith(currentWord: newCurrentWord, selectedCol: newSelectedCol, selectedRow: newSelectedRow));
    }
  }
}
