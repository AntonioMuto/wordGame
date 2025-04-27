import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:word_game/controllers/playSounds_controller.dart';

part 'anagram_event.dart';
part 'anagram_state.dart';

class AnagramBloc extends Bloc<AnagramEvent, AnagramState> {
  AnagramBloc() : super(AnagramInitial()) {
    on<FetchAnagramData>(_onFetchAnagramData);
    on<AddLetterEvent>(_onAddLetterEvent);
    on<AddLetterAtPositionEvent>(_onAddLetterAtPositionEvent);
    on<RemoveLastLetterEvent>(_onRemoveLastLetterEvent);
    on<ResetWordAnagramEvent>(_onResetWordEvent);
    on<RemoveElementEventByPosition>(_onRemoveElementEventByPosition);
    on<StartGameEvent>(_onStartGame);
  }

  Future<void> _onFetchAnagramData(FetchAnagramData event, Emitter<AnagramState> emit) async {
    emit(AnagramInitial());
    try {
      final url = Uri.parse('https://raw.githubusercontent.com/AntonioMuto/wordGame/refs/heads/main/anagram.json');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        final List<String> anagramList = (jsonData['anagramList'] as List<dynamic>).map((e) => e as String).toList();
        final List<String> correctWords = (jsonData['correctWords'] as List<dynamic>).map((e) => e as String).toList();

        final List<String> initialCurrentWord = List.generate(correctWords.length, (index) => "");

        emit(AnagramLoaded(
          anagram: anagramList,
          solution: correctWords,
          currentWord: initialCurrentWord,
          usedLetters: {}, // Mappa vuota iniziale
        ));
        print('AnagramLoaded emitted: $correctWords');
      } else {
        throw Exception('Errore nella risposta del server: ${response.statusCode}');
      }
    } catch (e) {
      emit(AnagramError('Errore nel caricamento dei dati: $e'));
      print(e);
    }
  }

  Future<void> _onAddLetterEvent(AddLetterEvent event, Emitter<AnagramState> emit) async {
    if (state is AnagramLoaded) {
      final currentState = state as AnagramLoaded;

      // Cerca il primo spazio libero in currentWord
      final indexToAddLetter = currentState.currentWord.indexOf("");

      if (indexToAddLetter != -1) {
        final updatedWord = List<String>.from(currentState.currentWord);
        updatedWord[indexToAddLetter] = event.letter;

        // Aggiorna la mappa delle lettere usate
        final updatedUsedLetters = Map<int, String>.from(currentState.usedLetters);
        updatedUsedLetters[event.position] = event.letter;

        bool completed = false;
        bool isAttempt = false;
        if(listEquals(updatedWord, currentState.solution)){
          PlaysoundsController().playSoundCompletedLevel();
          completed = true;
          isAttempt = true;
        } else {
          if(updatedWord.every((element) => element != '')){
            PlaysoundsController().playSoundWrongWord();
            isAttempt = true;
          }
        }

        emit(currentState.copyWith(
          currentWord: updatedWord,
          usedLetters: updatedUsedLetters,
          completed: completed,
          attempts: currentState.attempts + 1,
        ));
      }
    }
  }

  Future<void> _onAddLetterAtPositionEvent(AddLetterAtPositionEvent event, Emitter<AnagramState> emit) async {
    if (state is AnagramLoaded) {
      final currentState = state as AnagramLoaded;
      final updatedWord = List<String>.from(currentState.currentWord);

      if (event.position >= 0 && event.position < updatedWord.length) {
        updatedWord[event.position] = event.letter;
      } else {
        return; // Posizione non valida
      }

      // Aggiorna la mappa delle lettere usate
      final updatedUsedLetters = Map<int, String>.from(currentState.usedLetters);
      updatedUsedLetters[event.position] = event.letter;

      emit(currentState.copyWith(
        currentWord: updatedWord,
        usedLetters: updatedUsedLetters,
      ));
    }
  }

  Future<void> _onRemoveLastLetterEvent(RemoveLastLetterEvent event, Emitter<AnagramState> emit) async {
    if (state is AnagramLoaded) {
      final currentState = state as AnagramLoaded;

      // Cerca l'ultima posizione occupata in currentWord
      final indexToRemoveLetter = currentState.currentWord.lastIndexWhere((letter) => letter.isNotEmpty);

      if (indexToRemoveLetter != -1) {
        final updatedWord = List<String>.from(currentState.currentWord);
        final updatedUsedLetters = Map<int, String>.from(currentState.usedLetters);

        // Recupera la lettera da rimuovere
        final letterToRemove = updatedWord[indexToRemoveLetter];

        // Rimuovi la lettera da currentWord
        updatedWord[indexToRemoveLetter] = "";

        // Trova la prima chiave in usedLetters che corrisponde alla lettera
        final keyToRemove = updatedUsedLetters.entries
            .firstWhere((entry) => entry.value == letterToRemove, orElse: () => MapEntry(-1, ""))
            .key;

        // Rimuovi quella chiave dalla mappa se esiste
        if (keyToRemove != -1) {
          updatedUsedLetters.remove(keyToRemove);
        }

        emit(currentState.copyWith(
          currentWord: updatedWord,
          usedLetters: updatedUsedLetters,
        ));
      }
    }
  }

  Future<void> _onResetWordEvent(ResetWordAnagramEvent event, Emitter<AnagramState> emit) async {
    if (state is AnagramLoaded) {
      final currentState = state as AnagramLoaded;

      emit(currentState.copyWith(
        currentWord: List.generate(currentState.solution.length, (index) => ""),
        usedLetters: {}, // Resetta la mappa
      ));
    }
  }

  Future<void> _onRemoveElementEventByPosition(RemoveElementEventByPosition event, Emitter<AnagramState> emit) async {
    if (state is AnagramLoaded) {
      final currentState = state as AnagramLoaded;

      final updatedWord = List<String>.from(currentState.currentWord);
      final updatedUsedLetters = Map<int, String>.from(currentState.usedLetters);

      // Trova la prima chiave che ha il valore uguale a `event.letter`
      final keyToRemove = updatedUsedLetters.entries
          .firstWhere((entry) => entry.value == event.letter, orElse: () => MapEntry(-1, ""))
          .key;

      if (keyToRemove != -1) {
        updatedUsedLetters.remove(keyToRemove); // Rimuovi l'elemento dalla mappa
      }

      updatedWord[event.position] = ""; // Resetta la posizione in currentWord

      emit(currentState.copyWith(
        currentWord: updatedWord,
        usedLetters: updatedUsedLetters,
      ));
    }
  }

  Future<void> _onStartGame (StartGameEvent event, Emitter<AnagramState> emit) async {
    if (state is AnagramLoaded) {
      final currentState = state as AnagramLoaded;
      emit(currentState.copyWith(
        started: true
      ));
    }
  }

}