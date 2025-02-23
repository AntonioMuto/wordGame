import 'dart:convert';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:word_game/controllers/playSounds_controller.dart';
import 'package:word_game/data_models/FindWordCell.dart';

part 'findword_event.dart';
part 'findword_state.dart';

class FindwordBloc extends Bloc<FindwordEvent, FindwordState> {
  FindwordBloc() : super(FindwordInitial()) {
    on<FetchFindWordData>(_onFetchFindWordData);
    on<InsertLetterEvent>(_onInsertLetter);
    on<RemoveLetterEvent>(_onRemoveLetter);
    on<ResetWordEvent>(_onResetWord);
    on<SubmitWordEvent>(_onSubmitWord);
    on<ChangeSelectedCellEvent>(_onSelectCell);
    on<ContinueLevelEvent>(_onContinueLevel);
    on<RemoveCompletedEvent>(_onRemoveCompleted);
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
            7, 
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
      if(newSelectedCol != null && newSelectedCol > currentState.currentWord[currentState.currentRow].length - 1) {
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
      print(" newSelectedCol: $newSelectedCol, newSelectedRow: $newSelectedRow, newCurrentRow: $newCurrentRow");
      if(newSelectedCol != null && newSelectedCol <= 0) {
        newSelectedCol = 0;
        newSelectedRow = currentState.currentRow;
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
      newSelectedRow = currentState.currentRow;

      emit(currentState.copyWith(currentWord: newCurrentWord, selectedCol: newSelectedCol, selectedRow: newSelectedRow));
    }
  }

   Future<void> _onSubmitWord(SubmitWordEvent event, Emitter<FindwordState> emit) async {
    if (state is FindwordLoaded) {
      final currentState = state as FindwordLoaded;
      var newCurrentWord = List<List<Findwordcell>>.from(currentState.currentWord!);

      // Controlla che tutte le lettere siano state inserite
      for (var i = 0; i < newCurrentWord[currentState.currentRow].length; i++) {
        if (newCurrentWord[currentState.currentRow][i].letter == '') {
          return;
        }
      }

      // Crea una mappa per contare le occorrenze nella soluzione
      var solutionLetterCounts = <String, int>{};
      for (var letter in currentState.solution) {
        solutionLetterCounts[letter] = (solutionLetterCounts[letter] ?? 0) + 1;
      }

      // Primo passaggio: assegna il tipo "O" per le lettere nella posizione corretta
      for (var i = 0; i < newCurrentWord[currentState.currentRow].length; i++) {
        var cell = newCurrentWord[currentState.currentRow][i];
        if (cell.letter == currentState.solution[i] && cell.type != "O") {
          cell.type = "O";
          solutionLetterCounts[cell.letter!] = solutionLetterCounts[cell.letter!]! - 1;
        }
      }

      // Secondo passaggio: assegna il tipo "%" o "X" per le lettere rimanenti
      for (var i = 0; i < newCurrentWord[currentState.currentRow].length; i++) {
        var cell = newCurrentWord[currentState.currentRow][i];
        if (cell.type != "O") {
          if (solutionLetterCounts[cell.letter!] != null && solutionLetterCounts[cell.letter!]! > 0) {
            cell.type = "%";
            solutionLetterCounts[cell.letter!] = solutionLetterCounts[cell.letter!]! - 1;
          } else {
            cell.type = "X";
          }
        }
      }

      // Verifica se la parola è stata completata correttamente
      if (newCurrentWord[currentState.currentRow].every((cell) => cell.type == "O")) {
        PlaysoundsController().playSoundCompletedLevel();
        emit(currentState.copyWith(currentWord: newCurrentWord, completed: true));
        return;
      }

      if(currentState.currentRow + 1 == currentState.maxRow) {
        PlaysoundsController().playSoundFailedLevel();
        emit(currentState.copyWith(currentWord: newCurrentWord, completed: false, failed: true));
        return;
      }
      // var selectedCol = 0;
      // for(var i = 0; i < newCurrentWord[currentState.currentRow].length; i++) {
      //   var wordCell = newCurrentWord[currentState.currentRow][i];
      //   if(wordCell.type == "O") {
      //     newCurrentWord[currentState.currentRow + 1][i].type = "O";
      //     newCurrentWord[currentState.currentRow + 1][i].letter = wordCell.letter;
      //   } else if((wordCell.type == "%" || wordCell.type == "X") && selectedCol == 0) {
      //       selectedCol = i;
      //   }
      // }
      if(newCurrentWord[currentState.currentRow].any((cell) => cell.type == "O" || cell.type == "%")) {
        PlaysoundsController().playSoundCorrectWord();
      }

      emit(currentState.copyWith(
        currentWord: newCurrentWord,
        selectedCol: 0,
        selectedRow: currentState.currentRow + 1,
        currentRow: currentState.currentRow + 1,
      ));
    }
  }

  Future<void> _onSelectCell(ChangeSelectedCellEvent event, Emitter<FindwordState> emit) async {
    if (state is FindwordLoaded) {
      final currentState = state as FindwordLoaded;
      emit(currentState.copyWith(selectedCol: event.col, selectedRow: event.row));
    }
  }

  Future<void> _onContinueLevel(ContinueLevelEvent event, Emitter<FindwordState> emit) async {
    if (state is FindwordLoaded) {
      final currentState = state as FindwordLoaded;
      emit(currentState.copyWith(currentRow: currentState.currentRow + 1, completed: false, maxRow: currentState.maxRow + 1, failed: false, selectedCol: 0, selectedRow: currentState.currentRow + 1));  
    }
  }

  Future<void> _onRemoveCompleted(RemoveCompletedEvent event, Emitter<FindwordState> emit) async {
    if (state is FindwordLoaded) {
      final currentState = state as FindwordLoaded;
      emit(currentState.copyWith(completed: false));  
    }
  }
}
