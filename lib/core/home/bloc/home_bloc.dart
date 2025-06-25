import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_game/data_models/GameSection.dart';
import 'package:word_game/services/app_eventBus.dart';
import 'package:word_game/services/cache_handler.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  StreamSubscription<String>? _eventBusSubscription;

  HomeBloc() : super(HomeInitial()) {
    _eventBusSubscription = AppEventBus.stream.listen((event) {
      if (event == "user_data_updated") {
        add(LoadGameSectionsEvent());
      }
    });

    on<LoadGameSectionsEvent>((event, emit) async {
      final userProfile = await CacheHandler.getUserProfile() as Map<String, dynamic>?;
      if (userProfile != null) {
        emit(HomeLoaded([
          GameSection(
            name: "Cruciverba",
            gameImage: "crossword",
            level: 100,
            progress: userProfile['levelCrossWord'] / 100,
            color: const Color.fromRGBO(56, 142, 60, 1),
            currentLevel: userProfile['levelCrossWord'],
          ),
          GameSection(
            name: "Anagramma",
            gameImage: "anagram",
            level: 100,
            progress: userProfile['levelAnagram'] / 100,
            color: Colors.purple[700]!,
            currentLevel: userProfile['levelAnagram'],
          ),
          GameSection(
            name: "Trova la Parola",
            gameImage: "findword",
            level: 100,
            progress: userProfile['levelFindWord'] / 100,
            color: Colors.blue[700]!,
            currentLevel: userProfile['levelFindWord'],
          ),
          GameSection(
            name: "Cerca le Parole",
            gameImage: "searchword",
            level: 100,
            progress: userProfile['levelSearchWord'] / 100,
            color: Colors.red[700]!,
            currentLevel: userProfile['levelSearchWord'],
          ),
          GameSection(
            name: "Sudoku",
            gameImage: "sudoku",
            level: 100,
            progress: userProfile['levelSudoku'] / 100,
            color: Colors.lightBlue[700]!,
            currentLevel: userProfile['levelSudoku'],
          ),
          GameSection(
            name: "Crucigramma",
            gameImage: "crucigram",
            level: 199,
            progress: 1.0,
            color: Colors.orange[700]!,
            currentLevel: 3,
          ),
        ]));
      }
    });
  }

  @override
  Future<void> close() async {
    await _eventBusSubscription?.cancel();
    return super.close();
  }
}