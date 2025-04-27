import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:word_game/data_models/GameSection.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadGameSectionsEvent>((event, emit) async {
      // Simula caricamento
      await Future.delayed(const Duration(seconds: 1));

      emit(HomeLoaded([
        GameSection(name: "Cruciverba", gameImage: "crossword", level: 123 , progress: 0.7,color: const Color.fromRGBO(56, 142, 60, 1)!, currentLevel: 3),
        GameSection(name: "Anagramma", gameImage: "anagram", level: 3, progress: 0.4, color: Colors.purple[700]!, currentLevel: 3),
        GameSection(name: "Trova la Parola", gameImage: "findword", level: 99, progress: 0.8, color: Colors.blue[700]!, currentLevel: 3),
        GameSection(name: "Cerca le Parole", gameImage: "searchword", level: 1283, progress: 0.2, color: Colors.red[700]!, currentLevel: 3),
        GameSection(name: "Sudoku", gameImage: "sudoku", level: 654, progress: 0.9, color: Colors.lightBlue[700]!, currentLevel: 3),
        GameSection(name: "Crucigramma", gameImage: "crucigram", level: 199, progress: 1.0, color: Colors.orange[700]!, currentLevel: 3),
      ]));
    });
  }
}
