import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'crossword_event.dart';
part 'crossword_state.dart';

class CrosswordBloc extends Bloc<CrosswordEvent, CrosswordState> {
  CrosswordBloc(List<List<String>> initialData)
      : super(CrosswordLoaded(crosswordData: initialData)) {
    on<SelectCellEvent>(_onSelectCell);
    on<InsertLetterEvent>(_onInsertLetter);
    on<RemoveLetterEvent>(_onRemoveLetter);
    on<ResetWordEvent>(_onResetWord);
  }

  // Gestore per l'evento di selezione della cella
  void _onSelectCell(SelectCellEvent event, Emitter<CrosswordState> emit) {
  if (state is CrosswordLoaded) {
    final loadedState = state as CrosswordLoaded;

    // Controlla se la cella selezionata è la stessa
    final isSameCell = loadedState.selectedRow == event.row && loadedState.selectedCol == event.col;

    // Aggiungiamo una logica che verifica se è possibile selezionare una parola orizzontale o verticale
    bool canSelectHorizontal = canSelectHorizontalWord(event.row, event.col, loadedState.crosswordData);
    bool canSelectVertical = canSelectVerticalWord(event.row, event.col, loadedState.crosswordData);

    // Se la casella è la stessa, alterna la direzione tra orizzontale e verticale, ma solo se possibile
    bool isHorizontal = loadedState.isHorizontal;
    if (isSameCell) {
      if (canSelectHorizontal && !canSelectVertical) {
        isHorizontal = true;  // Se posso solo orizzontale, rimango orizzontale
      } else if (canSelectVertical && !canSelectHorizontal) {
        isHorizontal = false; // Se posso solo verticale, rimango verticale
      } else {
        isHorizontal = !loadedState.isHorizontal; // Alterna tra orizzontale e verticale se entrambi possibili
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
    final highlightedCells = findWordCells(event.row, event.col, loadedState.crosswordData, isHorizontal);

    // Emitti un nuovo stato con la selezione aggiornata e le celle evidenziate
    emit(loadedState.copyWith(
      selectedRow: event.row,
      selectedCol: event.col,
      highlightedCells: highlightedCells,
      isHorizontal: isHorizontal,
    ));
  }
}

  // Gestore per l'evento di inserimento di una lettera
  void _onInsertLetter(InsertLetterEvent event, Emitter<CrosswordState> emit) {
    if (state is CrosswordLoaded) {
      final loadedState = state as CrosswordLoaded;

      // Copia immutabile della griglia
      final updatedData = List<List<String>>.from(
        loadedState.crosswordData.map((row) => List<String>.from(row)),
      );

      // Aggiorna solo la cella selezionata
      if (loadedState.selectedRow != null && loadedState.selectedCol != null && loadedState.selectedRow! >= 0 && loadedState.selectedCol! >= 0) {
        int? row = loadedState.selectedRow!;
        int? col = loadedState.selectedCol!;
        updatedData[row][col] = event.letter.toUpperCase();
        if(loadedState.isHorizontal) {
          col = col + 1;
        } else {
          row = row + 1;
        }
        if(row >= loadedState.crosswordData[row-1].length || col >= loadedState.crosswordData[col-1].length) {
          emit(loadedState.copyWith(crosswordData: updatedData, selectedRow: -1, selectedCol: -1, highlightedCells: []));
          return;
        }
        if(loadedState.crosswordData[row][col] == "X") {
          emit(loadedState.copyWith(crosswordData: updatedData, selectedRow: -1, selectedCol: -1, highlightedCells: []));
          return;
        }

        // Emette il nuovo stato con la griglia aggiornata
        emit(loadedState.copyWith(crosswordData: updatedData, selectedRow: row, selectedCol: col));
      }
    }
  }

  void _onRemoveLetter(RemoveLetterEvent event, Emitter<CrosswordState> emit) {
    if(state is CrosswordLoaded) {
      final loadedState = state as CrosswordLoaded;

      final updatedData = List<List<String>>.from(
        loadedState.crosswordData.map((row) => List<String>.from(row)),
      );

      int? row = loadedState.selectedRow!;
      int? col = loadedState.selectedCol!;
      updatedData[row][col] = "";
      if(loadedState.isHorizontal) {
          col = col - 1;
      } else {
          row = row - 1;
      }
        if(row < 0 || col < 0) {
          emit(loadedState.copyWith(crosswordData: updatedData, selectedRow: -1, selectedCol: -1, highlightedCells: []));
          return;
        }
        if(loadedState.crosswordData[row][col] == "X") {
          emit(loadedState.copyWith(crosswordData: updatedData, selectedRow: -1, selectedCol: -1, highlightedCells: []));
          return;
        }

      emit(loadedState.copyWith(crosswordData: updatedData, selectedRow: row, selectedCol: col));
    }
  }


  void _onResetWord(ResetWordEvent event, Emitter<CrosswordState> emit) {
    if(state is CrosswordLoaded) {
      final loadedState = state as CrosswordLoaded;

      final updatedData = List<List<String>>.from(
        loadedState.crosswordData.map((row) => List<String>.from(row)),
      );

      loadedState.highlightedCells.forEach((cell) {
        updatedData[cell[0]][cell[1]] = "";
      });

      emit(loadedState.copyWith(crosswordData: updatedData));
    }
  }

  List<List<int>> findWordCells(int row, int col, List<List<String>> crosswordData, bool isHorizontal) {
    final List<List<int>> wordCells = [];

    if (isHorizontal) {
      // Trova la parola orizzontale a partire da (row, col)
      int startCol = col;
      while (startCol - 1 >= 0 && crosswordData[row][startCol - 1] != "X") {
        startCol--;
      }

      int endCol = col;
      while (endCol + 1 < crosswordData[row].length && crosswordData[row][endCol + 1] != "X") {
        endCol++;
      }

      // Aggiungi tutte le celle orizzontali della parola
      for (int c = startCol; c <= endCol; c++) {
        wordCells.add([row, c]);
      }
    } else {
      // Trova la parola verticale a partire da (row, col)
      int startRow = row;
      while (startRow - 1 >= 0 && crosswordData[startRow - 1][col] != "X") {
        startRow--;
      }

      int endRow = row;
      while (endRow + 1 < crosswordData.length && crosswordData[endRow + 1][col] != "X") {
        endRow++;
      }

      // Aggiungi tutte le celle verticali della parola
      for (int r = startRow; r <= endRow; r++) {
        wordCells.add([r, col]);
      }
    }

    return wordCells;
  }

  bool canSelectVerticalWord(int row, int col, List<List<String>> crosswordData) {
  // Verifica se la cella sopra è un "X" o fuori limite
  if (row - 1 >= 0 && crosswordData[row - 1][col] != "X") {
    return true; // Se c'è una cella sopra non è l'inizio di una parola verticale
  }

  // Verifica se la cella sotto è una casella bianca o fuori limite
  if (row + 1 < crosswordData.length && crosswordData[row + 1][col] != "X") {
    return true; // Se la cella sotto è bianca, posso continuare verticalmente
  }

  return false; // Altrimenti, non è possibile una parola verticale
}

bool canSelectHorizontalWord(int row, int col, List<List<String>> crosswordData) {
  // Verifica se la cella a sinistra è un "X" o fuori limite
  if (col - 1 >= 0 && crosswordData[row][col - 1] != "X") {
    return true; // Se c'è una cella a sinistra non è l'inizio di una parola orizzontale
  }

  if (col + 1 < crosswordData[row].length) {
    if (crosswordData[row][col + 1] != "X") {
      return true; // Se la cella a destra è bianca, posso continuare orizzontalmente
    }
    return false;
  }

  return false; // Altrimenti, non è possibile una parola orizzontale
}


}

