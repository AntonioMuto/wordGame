import 'dart:collection';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'dart:convert'; // Per decodificare la risposta JSON
import 'package:http/http.dart' as http;
import 'package:word_game/controllers/playSounds_controller.dart';
import 'package:word_game/data_models/CrossWordCell.dart';

part 'crossword_event.dart';
part 'crossword_state.dart';

class CrosswordBloc extends Bloc<CrosswordEvent, CrosswordState> {
  CrosswordBloc(List<List<CrosswordCell>> initialData)
      : super(CrosswordLoaded(crosswordData: initialData)) {
    on<FetchCrosswordData>(_onFetchCrosswordData);
    on<SelectCellEvent>(_onSelectCell);
    on<InsertLetterEvent>(_onInsertLetter);
    on<RemoveLetterEvent>(_onRemoveLetter);
    on<ResetWordEvent>(_onResetWord);
    on<ResetHintEvent>(_onResetHint);
    on<ToggleHintEvent>(_onToggleHint);
  }

  // Gestore per l'evento di selezione della cella
  void _onSelectCell(SelectCellEvent event, Emitter<CrosswordState> emit) {
    if (state is CrosswordLoaded) {
      final loadedState = state as CrosswordLoaded;

      if (loadedState.crosswordData[event.row][event.col].isCorrect) {
        return;
      }

      // Controlla se la cella selezionata è la stessa
      final isSameCell = loadedState.selectedRow == event.row &&
          loadedState.selectedCol == event.col;

      // Aggiungiamo una logica che verifica se è possibile selezionare una parola orizzontale o verticale
      bool canSelectHorizontal = canSelectHorizontalWord(
          event.row, event.col, loadedState.crosswordData);
      bool canSelectVertical = canSelectVerticalWord(
          event.row, event.col, loadedState.crosswordData);

      // Se la casella è la stessa, alterna la direzione tra orizzontale e verticale, ma solo se possibile
      bool isHorizontal = loadedState.isHorizontal;
      if (isSameCell) {
        if (canSelectHorizontal && !canSelectVertical) {
          isHorizontal = true; // Se posso solo orizzontale, rimango orizzontale
        } else if (canSelectVertical && !canSelectHorizontal) {
          isHorizontal = false; // Se posso solo verticale, rimango verticale
        } else {
          isHorizontal = !loadedState
              .isHorizontal; // Alterna tra orizzontale e verticale se entrambi possibili
        }
      } else {
        // Se la cella selezionata non è la stessa, alterna la direzione se possibile
        if (canSelectHorizontal && !canSelectVertical) {
          isHorizontal = true;
        } else if (canSelectVertical && !canSelectHorizontal) {
          isHorizontal = false;
        }
      }

      // Trova tutte le celle della parola selezionata (orizzontale o verticale)
      final highlightedCells = findWordCells(
          event.row, event.col, loadedState.crosswordData, isHorizontal);
      final highlightedCellsSecondary = findWordCells(
          event.row, event.col, loadedState.crosswordData, !isHorizontal);

      String definition = "";

      if (highlightedCells.isNotEmpty) {
        var cellDef = loadedState.crosswordData[highlightedCells[0][0]]
            [highlightedCells[0][1]];
        if (isHorizontal) {
          definition = cellDef.questionX ?? "";
        } else {
          definition = cellDef.questionY ?? "";
        }
      }

      // Emitti un nuovo stato con la selezione aggiornata e le celle evidenziate
      emit(loadedState.copyWith(
          selectedRow: event.row,
          selectedCol: event.col,
          highlightedCells: highlightedCells,
          highlightedCellsSecondary: highlightedCellsSecondary,
          isHorizontal: isHorizontal,
          definition: definition));
    }
  }

  // Gestore per l'evento di inserimento di una lettera
  void _onInsertLetter(InsertLetterEvent event, Emitter<CrosswordState> emit) {
    if (state is CrosswordLoaded) {
      final loadedState = state as CrosswordLoaded;
      print(loadedState.highlightedCellsSecondary);
      // Copia immutabile della griglia
      final updatedData = List<List<CrosswordCell>>.from(
        loadedState.crosswordData.map((row) => List<CrosswordCell>.from(row)),
      );

      // Aggiorna solo la cella selezionata
      if (loadedState.selectedRow != null &&
          loadedState.selectedCol != null &&
          loadedState.selectedRow! >= 0 &&
          loadedState.selectedCol! >= 0) {
        int? row = loadedState.selectedRow!;
        int? col = loadedState.selectedCol!;
        updatedData[row][col].value = event.letter.toUpperCase();
        if (loadedState.isHorizontal) {
          col = col + 1;
          while (col! < loadedState.crosswordData[col - 1].length &&
              loadedState.crosswordData[row][col].isCorrect) {
            col = col + 1;
          }
        } else {
          row = row + 1;
          while (row! < loadedState.crosswordData[row - 1].length &&
              loadedState.crosswordData[row][col].isCorrect) {
            row = row + 1;
          }
        }
        print(loadedState.highlightedCellsSecondary);
        var status = checkWords(updatedData, loadedState.highlightedCells,
            loadedState.highlightedCellsSecondary);

        if (status['completed'] == true) {
          PlaysoundsController().playSoundCompletedLevel();
        }
        if ((row > 0 && row >= loadedState.crosswordData[row - 1].length) ||
            (col > 0 && col >= loadedState.crosswordData[col - 1].length)) {
          emit(loadedState.copyWith(
              crosswordData: status['crosswordData'],
              selectedRow: -1,
              selectedCol: -1,
              highlightedCells: [],
              definition: loadedState.definition,
              completed: status['completed'] ? true : false));
          return;
        }
        if (loadedState.crosswordData[row][col].type == "X" ||
            loadedState.crosswordData[row][col].isCorrect) {
          emit(loadedState.copyWith(
              crosswordData: status['crosswordData'],
              selectedRow: -1,
              selectedCol: -1,
              highlightedCells: [],
              definition: loadedState.definition,
              completed: status['completed'] ? true : false));
          return;
        }
        bool isHorizontal = loadedState.isHorizontal;

        final highlightedCells =
            findWordCells(row, col, loadedState.crosswordData, isHorizontal);
        final highlightedCellsSecondary =
            findWordCells(row, col, loadedState.crosswordData, !isHorizontal);

        // Emette il nuovo stato con la griglia aggiornata
        emit(loadedState.copyWith(
            crosswordData: status['crosswordData'],
            selectedRow: status['isCorrect'] ? -1 : row,
            selectedCol: status['isCorrect'] ? -1 : col,
            highlightedCells: status['isCorrect'] ? [] : highlightedCells,
            definition: loadedState.definition,
            highlightedCellsSecondary:
                status['isCorrect'] ? [] : highlightedCellsSecondary,
            completed: status['completed'] ? true : false));
      }
    }
  }

  void _onRemoveLetter(RemoveLetterEvent event, Emitter<CrosswordState> emit) {
    if (state is CrosswordLoaded) {
      final loadedState = state as CrosswordLoaded;

      final updatedData = List<List<CrosswordCell>>.from(
        loadedState.crosswordData.map((row) => List<CrosswordCell>.from(row)),
      );

      if (loadedState.selectedRow != null &&
          loadedState.selectedCol != null &&
          loadedState.selectedRow! >= 0 &&
          loadedState.selectedCol! >= 0) {
        int? row = loadedState.selectedRow!;
        int? col = loadedState.selectedCol!;
        if (!updatedData[row][col].isCorrect) {
          updatedData[row][col].value = "";
        }
        if (loadedState.isHorizontal) {
          col = col - 1;
          while (col! > 0 && updatedData[row][col].isCorrect) {
            col = col - 1;
          }
        } else {
          row = row - 1;
          while (row! > 0 && updatedData[row][col].isCorrect) {
            row = row - 1;
          }
        }
        if (row < 0 || col < 0) {
          emit(loadedState.copyWith(
              crosswordData: updatedData,
              selectedRow: -1,
              selectedCol: -1,
              highlightedCells: []));
          return;
        }
        if (loadedState.crosswordData[row][col].type == "X") {
          emit(loadedState.copyWith(
              crosswordData: updatedData,
              selectedRow: -1,
              selectedCol: -1,
              highlightedCells: []));
          return;
        }
        bool isHorizontal = loadedState.isHorizontal;
        final highlightedCells =
            findWordCells(row, col, loadedState.crosswordData, isHorizontal);
        final highlightedCellsSecondary =
            findWordCells(row, col, loadedState.crosswordData, !isHorizontal);
        emit(loadedState.copyWith(
            crosswordData: updatedData, selectedRow: row, selectedCol: col, highlightedCells: highlightedCells, highlightedCellsSecondary: highlightedCellsSecondary));
      }
    }
  }

  void _onResetWord(ResetWordEvent event, Emitter<CrosswordState> emit) {
    if (state is CrosswordLoaded) {
      final loadedState = state as CrosswordLoaded;

      final updatedData = List<List<CrosswordCell>>.from(
        loadedState.crosswordData.map((row) => List<CrosswordCell>.from(row)),
      );

      for (var cell in loadedState.highlightedCells) {
        if (!updatedData[cell[0]][cell[1]].isCorrect) {
          updatedData[cell[0]][cell[1]].value = "";
        }
      }

      emit(loadedState.copyWith(crosswordData: updatedData));
    }
  }

  Future<void> _onFetchCrosswordData(
      FetchCrosswordData event, Emitter<CrosswordState> emit) async {
    emit(CrosswordInitial()); // Stato iniziale mentre si attendono i dati

    try {
      // URL dell'API
      final url = Uri.parse(
          'https://raw.githubusercontent.com/AntonioMuto/wordGame/refs/heads/main/crossword.json');

      // Chiamata GET all'API
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Decodifica la risposta JSON
        final jsonData = jsonDecode(response.body);

        // Parsing dei dati in una struttura List<List<CrosswordCell>>
        final crosswordData = _parseCrosswordData(jsonData);
        await Future.delayed(const Duration(seconds: 1));
        // Emetti lo stato con i dati ricevuti
        emit(CrosswordLoaded(crosswordData: crosswordData));
      } else {
        // Errore nella risposta
        throw Exception(
            'Errore nella risposta del server: ${response.statusCode}');
      }
    } catch (e) {
      // Emette uno stato di errore
      emit(CrosswordError('Errore nel caricamento dei dati: $e'));
      print(e);
    }
  }

  List<List<int>> findWordCells(int row, int col,
      List<List<CrosswordCell>> crosswordData, bool isHorizontal) {
    final List<List<int>> wordCells = [];

    if (isHorizontal) {
      // Trova la parola orizzontale a partire da (row, col)
      int startCol = col;
      while (
          startCol - 1 >= 0 && crosswordData[row][startCol - 1].type != "X") {
        startCol--;
      }

      int endCol = col;
      while (endCol + 1 < crosswordData[row].length &&
          crosswordData[row][endCol + 1].type != "X") {
        endCol++;
      }

      // Aggiungi tutte le celle orizzontali della parola
      for (int c = startCol; c <= endCol; c++) {
        wordCells.add([row, c]);
      }
    } else {
      // Trova la parola verticale a partire da (row, col)
      int startRow = row;
      while (
          startRow - 1 >= 0 && crosswordData[startRow - 1][col].type != "X") {
        startRow--;
      }

      int endRow = row;
      while (endRow + 1 < crosswordData.length &&
          crosswordData[endRow + 1][col].type != "X") {
        endRow++;
      }

      // Aggiungi tutte le celle verticali della parola
      for (int r = startRow; r <= endRow; r++) {
        wordCells.add([r, col]);
      }
    }

    return wordCells;
  }

  bool canSelectVerticalWord(
      int row, int col, List<List<CrosswordCell>> crosswordData) {
    // Verifica se la cella sopra è un "X" o fuori limite
    if (row - 1 >= 0 && crosswordData[row - 1][col].type != "X") {
      return true; // Se c'è una cella sopra non è l'inizio di una parola verticale
    }

    // Verifica se la cella sotto è una casella bianca o fuori limite
    if (row + 1 < crosswordData.length &&
        crosswordData[row + 1][col].type != "X") {
      return true; // Se la cella sotto è bianca, posso continuare verticalmente
    }

    return false; // Altrimenti, non è possibile una parola verticale
  }

  bool canSelectHorizontalWord(
      int row, int col, List<List<CrosswordCell>> crosswordData) {
    // Verifica se la cella a sinistra è un "X" o fuori limite
    if (col - 1 >= 0 && crosswordData[row][col - 1].type != "X") {
      return true; // Se c'è una cella a sinistra non è l'inizio di una parola orizzontale
    }

    if (col + 1 < crosswordData[row].length) {
      if (crosswordData[row][col + 1].type != "X") {
        return true; // Se la cella a destra è bianca, posso continuare orizzontalmente
      }
      return false;
    }

    return false; // Altrimenti, non è possibile una parola orizzontale
  }

  List<List<CrosswordCell>> _parseCrosswordData(Map<String, dynamic> json) {
    final map = json['map'] as List;
    final sizeMapX = json['sizeMapX'] as int;
    final sizeMapY = json['sizeMapY'] as int;

    // Creazione di una griglia vuota di celle
    final crosswordData = List<List<CrosswordCell>>.generate(
      sizeMapY,
      (_) => List<CrosswordCell>.filled(
          sizeMapX, CrosswordCell(type: "X", isCorrect: false)),
    );
    for (var row = 0; row < map.length; row++) {
      for (var col = 0; col < map[row].length; col++) {
        crosswordData[row][col] = CrosswordCell.fromJson(map[row][col]);
      }
    }

    return crosswordData;
  }

  Map<String, dynamic> checkWords(
      List<List<CrosswordCell>> crosswordData,
      List<List<int>> highlightedCells,
      List<List<int>> highlightedCellsSecondary) {
    var crosswordCopyPrimary = crosswordData
        .map((row) => row.map((cell) => cell.copy()).toList())
        .toList();
    var crosswordCopySecondary = crosswordData
        .map((row) => row.map((cell) => cell.copy()).toList())
        .toList();


    var isCorrectPrimary = false;
    var isCorrectSecondary = false;

    var everyPrimaryWordIsCorrect = true;
    var everySecondaryWordIsCorrect = true;

    var completed = true;

    // Verifica delle parole secondarie
    print(highlightedCellsSecondary.length);
    if (highlightedCellsSecondary.length > 1) {
      for (var cell in highlightedCellsSecondary) {
        int row = cell[0];
        int col = cell[1];
        print("${crosswordData[row][col].value} == ${crosswordData[row][col].answer}");
        if (crosswordData[row][col].value == crosswordData[row][col].answer) {
          crosswordCopySecondary[row][col].isCorrect = true;
        } else {
          crosswordCopySecondary[row][col].isCorrect = false;
          everySecondaryWordIsCorrect = false;
        }
      }
    } else {
      everySecondaryWordIsCorrect = false;
    }

    isCorrectSecondary = everySecondaryWordIsCorrect;

    // Verifica delle parole principali
    for (var cell in highlightedCells) {
      int row = cell[0];
      int col = cell[1];
      if (crosswordData[row][col].value == crosswordData[row][col].answer) {
        crosswordCopyPrimary[row][col].isCorrect = true;
      } else {
        crosswordCopyPrimary[row][col].isCorrect = false;
        everyPrimaryWordIsCorrect = false;
      }
    }
    isCorrectPrimary = everyPrimaryWordIsCorrect;

    // Merge dei dati se entrambe le verifiche sono corrette
    if (isCorrectPrimary && isCorrectSecondary) {
      for (int y = 0; y < crosswordData.length; y++) {
        for (int x = 0; x < crosswordData[y].length; x++) {
          if (crosswordCopyPrimary[y][x].isCorrect ||
              crosswordCopySecondary[y][x].isCorrect) {
            crosswordData[y][x] = crosswordCopyPrimary[y][x].copy();
            crosswordData[y][x].isCorrect = true;
          }
        }
      }
    } else {
      // Usa il risultato corretto se disponibile
      if (isCorrectPrimary) {
        crosswordData = crosswordCopyPrimary;
      } else if (isCorrectSecondary) {
        crosswordData = crosswordCopySecondary;
      }
    }

    for (int y = 0; y < crosswordData.length; y++) {
      for (int x = 0; x < crosswordData[y].length; x++) {
        if (crosswordData[y][x].type != "X" && !crosswordData[y][x].isCorrect) {
          completed = false;
        }
      }
    }

    if (isCorrectPrimary || isCorrectSecondary) {
      PlaysoundsController().playSoundCorrectWord();
    }

    var status = {
      "isCorrect": isCorrectPrimary,
      "crosswordData": crosswordData,
      "completed": completed
    };
    return status;
  }

  Future<void> _onToggleHint(ToggleHintEvent event, Emitter<CrosswordState> emit) async {
     if (state is CrosswordLoaded) {
      final loadedState = state as CrosswordLoaded;
      final updatedData = List<List<CrosswordCell>>.from(
        loadedState.crosswordData.map((row) => List<CrosswordCell>.from(row)),
      );

      bool isHorizontal = loadedState.isHorizontal;
      final highlightedCells =
            findWordCells(loadedState.selectedRow!, loadedState.selectedCol!, loadedState.crosswordData, isHorizontal);
      if(highlightedCells.isNotEmpty){
        List<int> countList = [];
        for (var i = 0; i < highlightedCells.length; i++) {
          var element = highlightedCells[i];
          if(!updatedData[element[0]][element[1]].isCorrect){
            countList.add(i);
          }
        }
        final random = Random();
        try {
          int randomNumber = countList[random.nextInt(countList.length)];
          updatedData[highlightedCells[randomNumber][0]][highlightedCells[randomNumber][1]].value = updatedData[highlightedCells[randomNumber][0]][highlightedCells[randomNumber][1]].answer;
          updatedData[highlightedCells[randomNumber][0]][highlightedCells[randomNumber][1]].isCorrect = true;
          emit(loadedState.copyWith(crosswordData: updatedData, selectedCol: -1, selectedRow: -1, highlightedCells: [], hintedCorrectly: true));
        } catch (e) {
          emit(loadedState.copyWith(selectedCol: -1, selectedRow: -1, highlightedCells: [], hintedCorrectly: false));          
        }
      }  
    }
  }

  Future<void> _onResetHint(ResetHintEvent event, Emitter<CrosswordState> emit) async {
    if (state is CrosswordLoaded) {
      final loadedState = state as CrosswordLoaded;
      emit(loadedState.copyWith(hintedCorrectly: false));
    }
  }

}
