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
        GameSection(name: "Classico", icon: Icons.star, level: 5, progress: 0.7),
        GameSection(name: "A Tempo", icon: Icons.timer, level: 3, progress: 0.4),
        GameSection(name: "Puzzle", icon: Icons.extension, level: 7, progress: 0.8),
        GameSection(name: "Parole Difficili", icon: Icons.language, level: 2, progress: 0.2),
        GameSection(name: "Sfida", icon: Icons.bolt, level: 6, progress: 0.9),
        GameSection(name: "Allenamento", icon: Icons.fitness_center, level: 10, progress: 1.0),
      ]));
    });
  }
}
