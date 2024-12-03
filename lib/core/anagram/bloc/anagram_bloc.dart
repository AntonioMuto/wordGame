import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

part 'anagram_event.dart';
part 'anagram_state.dart';

class AnagramBloc extends Bloc<AnagramEvent, AnagramState> {
  AnagramBloc() : super(AnagramInitial()) {
    on<FetchAnagramData>(_onFetchAnagramData);
    on<AddLetterEvent>(_onAddLetterEvent);
    on<AddLetterAtPositionEvent>(_onAddLetterAtPositionEvent);
    on<RemoveLastLetterEvent>(_onRemoveLastLetterEvent);
    on<ResetWordAnagramEvent>(_onResetWordEvent);
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

        // Inizializza currentWord come lista di stringhe vuote, della stessa lunghezza di correctWords
        final List<String> initialCurrentWord = List.generate(correctWords.length, (index) => "");

        emit(AnagramLoaded(
          anagram: anagramList,
          solution: correctWords,
          currentWord: initialCurrentWord, // Imposta currentWord inizialmente con stringhe vuote
          usedLetters: [], // Lista iniziale di lettere usate vuota
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

    // Cerca il primo "" in currentWord
    final indexToAddLetter = currentState.currentWord.indexOf("");

    if (indexToAddLetter != -1) {
      // Se c'è spazio, aggiungi la lettera
      currentState.currentWord[indexToAddLetter] = event.letter;

      // Aggiungi la lettera alla lista delle lettere usate, trattando duplicati come unici
      final updatedUsedLetters = List<String>.from(currentState.usedLetters)..add(event.letter);

      emit(currentState.copyWith(
        currentWord: currentState.currentWord,
        usedLetters: updatedUsedLetters,
      ));
    }
  }
}

  Future<void> _onAddLetterAtPositionEvent(AddLetterAtPositionEvent event, Emitter<AnagramState> emit) async {
    if (state is AnagramLoaded) {
      final currentState = state as AnagramLoaded;
      final updatedWord = List<String>.from(currentState.currentWord);

      // Aggiungi la lettera alla posizione specifica
      if (event.position >= 0 && event.position < updatedWord.length) {
        updatedWord[event.position] = event.letter;
      } else {
        updatedWord.add(event.letter); // Se la posizione è fuori limite, aggiungi alla fine
      }

      // Aggiungi la lettera alla lista delle lettere usate
      final updatedUsedLetters = List<String>.from(currentState.usedLetters)..add(event.letter);

      emit(currentState.copyWith(
        currentWord: updatedWord,
        usedLetters: updatedUsedLetters,
      ));
    }
  }

  Future<void> _onRemoveLastLetterEvent(RemoveLastLetterEvent event, Emitter<AnagramState> emit) async {
  if (state is AnagramLoaded) {
    final currentState = state as AnagramLoaded;

    // Cerca l'ultima lettera non vuota e ripristina "" in quella posizione
    final indexToRemoveLetter = currentState.currentWord.lastIndexOf("");

    if (indexToRemoveLetter != -1) {
      // Se ci sono lettere da rimuovere, ripristina l'ultima "" in currentWord
      final letterToRemove = currentState.currentWord[indexToRemoveLetter];
      currentState.currentWord[indexToRemoveLetter] = "";

      // Rimuovi la lettera dalla lista delle lettere usate
      final updatedUsedLetters = List<String>.from(currentState.usedLetters)
        ..removeLast(); // Rimuoviamo solo l'ultima aggiunta

      emit(currentState.copyWith(
        currentWord: currentState.currentWord,
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
        usedLetters: [], // Ripristina anche la lista delle lettere usate
      ));
    }
  }
}
