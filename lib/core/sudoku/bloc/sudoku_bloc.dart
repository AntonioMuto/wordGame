import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

part 'sudoku_event.dart';
part 'sudoku_state.dart';

class SudokuBloc extends Bloc<SudokuEvent, SudokuState> {
  SudokuBloc() : super(SudokuInitial()) {
    on<FetchSudokuData>(_fetchSudokuData);
  }

  Future<void> _fetchSudokuData(FetchSudokuData event, Emitter<SudokuState> emit) async {
    emit(SudokuInitial());
    try {
      final url = Uri.parse('https://raw.githubusercontent.com/AntonioMuto/wordGame/refs/heads/main/sudoku.json');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        final List<List<String>> solution = (jsonData['solution'] as List<String>).map((e) => e as List<String>).toList();

        final List<List<String>> initialSudoku = (jsonData['initialData'] as List<String>).map((e) => e as List<String>).toList();

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
}
