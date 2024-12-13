import 'dart:convert';
import 'dart:math';

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

      print(currentState.currentRow);
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
      for(var i = 0; i < newCurrentWord[currentState.currentRow].length; i++) {
        if(newCurrentWord[currentState.currentRow][i].letter == '') {
          return;
        }
      }
      for(var i = 0; i < newCurrentWord[currentState.currentRow].length; i++) {
        var letter = newCurrentWord[currentState.currentRow][i].letter;
        if(letter == currentState.solution[i]) {
          newCurrentWord[currentState.currentRow][i].type = "O";
        } else {
          _checkIfLetterExixtsButWrongPosition(letter, i, currentState.solution, newCurrentWord[currentState.currentRow]);
        }
      }
      _validateWord(newCurrentWord[currentState.currentRow], currentState.solution, emit);

      var newSelectedCol = 0;
      var newSelectedRow = currentState.currentRow + 1;

      if(newCurrentWord[currentState.currentRow].every((cell) => cell.type == "O")) {
        emit(currentState.copyWith(currentWord: newCurrentWord, completed: true));
      }

      emit(currentState.copyWith(currentWord: newCurrentWord, selectedCol: newSelectedCol, selectedRow: newSelectedRow, currentRow: currentState.currentRow + 1));
    }
  }

  Future<void> _onSelectCell(ChangeSelectedCellEvent event, Emitter<FindwordState> emit) async {
    if (state is FindwordLoaded) {
      final currentState = state as FindwordLoaded;
      emit(currentState.copyWith(selectedCol: event.col, selectedRow: event.row));
    }
  }

  _checkIfLetterExixtsButWrongPosition(String? letter, int index, List<String> solution, List<Findwordcell> currentWord) {
    if(!solution.contains(letter)) {
      currentWord[index].type = "X";
    } else {
      currentWord[index].type = "%";
    }
  }

  _validateWord(List<Findwordcell> currentWord, List<String> solution, Emitter<FindwordState> emit) {
    for (var cell in currentWord) {
      if(cell.type == "%") {
        int countLetter = solution.where((lettera) => lettera == cell.letter).length;
        int numberSolution = 0;
        for (var i = 0; i < currentWord.length; i++) {
          if(currentWord[i].letter == cell.letter) {
            numberSolution++;
            if(numberSolution > countLetter){
              cell.type = "X";
            }
          }
        }
      }
    }
  }

  Future<void> _onContinueLevel(ContinueLevelEvent event, Emitter<FindwordState> emit) async {
    if (state is FindwordLoaded) {
      final currentState = state as FindwordLoaded;
      emit(currentState.copyWith(currentRow: currentState.currentRow + 1, completed: false, maxRow: currentState.maxRow + 1));  
    }
  }

  Future<void> _onRemoveCompleted(RemoveCompletedEvent event, Emitter<FindwordState> emit) async {
    if (state is FindwordLoaded) {
      final currentState = state as FindwordLoaded;
      emit(currentState.copyWith(completed: false));  
    }
  }
}
