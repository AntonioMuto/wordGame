import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_game/core/anagram/pages/anagram_page.dart';
import 'package:word_game/core/crossword/bloc/crossword_bloc.dart';
import 'package:word_game/core/crossword/pages/crossword_page.dart';
import 'package:word_game/core/findword/pages/findword_pages.dart';
import 'package:word_game/core/sudoku/pages/sudoku_page.dart';
import 'package:word_game/data_models/GameSection.dart';

class LevelsPage extends StatelessWidget {
  final GameSection section;
  LevelsPage({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(section.name.toUpperCase()),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade600],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // Numero di colonne nella griglia
              crossAxisSpacing: 15.0, // Spaziatura orizzontale tra i quadratini
              mainAxisSpacing: 15.0, // Spaziatura verticale tra i quadratini
            ),
            itemCount: 200, // Numero totale di quadratini
            itemBuilder: (context, index) {
              final isLevelUnlocked = index < 10; // Sblocca solo i primi 10 livelli
              return GestureDetector(
                onTap: () {
                  if (isLevelUnlocked) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (context) => CrosswordBloc([]),
                          child: _loadGamePage(section, index),
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black, width: 1),
                    gradient: isLevelUnlocked
                        ? LinearGradient(
                            colors: [Colors.green.shade700, Colors.green.shade400],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [Colors.grey.shade700, Colors.grey.shade500],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(2, 2),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Aggiungi l'immagine di sfondo
                      Positioned.fill(
                        child: Opacity(
                          opacity: isLevelUnlocked ? 0.05 : 0, // Maggiore trasparenza se bloccato
                          child: Image.asset(
                            'assets/images/${section.gameImage}.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Mostra il numero del livello
                      Center(
                        child: Text(
                          '${index + 1}', // Mostra il numero del quadratino
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Icona di blocco
                      if (!isLevelUnlocked)
                        const Positioned(
                          bottom: 5,
                          child: Icon(Icons.lock, color: Colors.white, size: 20),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  _loadGamePage(GameSection section, int index) {
    switch (section.name) {
      case "Cruciverba":
        return CrosswordPage(level: index + 1);
      case "Anagramma":
        return AnagramPage(level: index + 1);
      case "Trova la Parola":
        return FindWordPage(level: index + 1);
      case "Sudoku":
        return SudokuPage(level: index + 1);
      default:
        
    }
  }
}
