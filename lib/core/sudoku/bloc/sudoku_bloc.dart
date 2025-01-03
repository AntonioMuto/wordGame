import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:word_game/data_models/SudokuCell.dart';

part 'sudoku_event.dart';
part 'sudoku_state.dart';

class SudokuBloc extends Bloc<SudokuEvent, SudokuState> {
  SudokuBloc() : super(SudokuInitial()) {
    on<FetchSudokuData>(_fetchSudokuData);
    on<SelectSudokuCell>(_selectSudokuCell);
    on<InsertLetterEvent>(_insertLetter);
  }

  Future<void> _fetchSudokuData(FetchSudokuData event, Emitter<SudokuState> emit) async {
    emit(SudokuInitial());
    try {
      final url = Uri.parse('https://raw.githubusercontent.com/AntonioMuto/wordGame/refs/heads/main/sudoku.json');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        final List<List<String>> solution = (jsonData['solution'] as List)
            .map((row) => (row as List).map((cell) => cell.toString()).toList())
            .toList();

        final List<List<Sudokucell>> initialSudoku = (jsonData['initialData'] as List)
            .map((row) => (row as List).map((cell) => Sudokucell(value: cell.toString(), isHint: cell.toString() != "" ? true : false )).toList())
            .toList();

        emit(SudokuLoaded(
          sudokuData: initialSudoku,
          sudokuSolution: solution
        ));
      } else {
        throw Exception('Errore nella risposta del server: ${response.statusCode}');
      }
    } catch (e) {
      emit(SudokuError('Errore nel caricamento dei dati: $e'));
      print(e);
    }
  }

  Future<void> _selectSudokuCell(SelectSudokuCell event, Emitter<SudokuState> emit) async {
    if (state is SudokuLoaded) {
      final currentState = state as SudokuLoaded;
      emit(currentState.copyWith(selectedRow: event.row, selectedCol: event.column));
    }
  }

  Future<void> _insertLetter(InsertLetterEvent event, Emitter<SudokuState> emit) async {
    if (state is SudokuLoaded) {
      final currentState = state as SudokuLoaded;
      var newSudoku = List<List<Sudokucell>>.from(currentState.sudokuData!);
      newSudoku[currentState.selectedRow!][currentState.selectedCol!].value = event.letter;

      emit(currentState.copyWith(sudokuData: newSudoku));
    }
  }
}
