import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_game/core/levels/bloc/levels_bloc.dart';
import 'package:word_game/core/levels/pages/levels_page.dart';
import 'package:word_game/data_models/GameSection.dart';

import '../../anagram/pages/anagram_page.dart';
import '../../crossword/pages/crossword_page.dart';
import '../../findword/pages/findword_pages.dart';
import '../../searchword/pages/searchword_page.dart';
import '../../sudoku/pages/sudoku_page.dart';

class GameSectionCard extends StatelessWidget {
  final GameSection section;

  const GameSectionCard({required this.section, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => LevelsBloc(),
              child: _loadGamePage(section, section.currentLevel),
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        color: section.color.withOpacity(0.8),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: titolo + immagine
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Text(
                        section.name,
                        style: TextStyle(
                          fontFamily: 'ChunkFive',
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Immagine piccola
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.transparent, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        "assets/images/${section.gameImage}.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: section.progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade400,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              // Livello
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: section.color.withOpacity(1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "LIVELLO ${section.currentLevel}",
                  style: const TextStyle(
                    fontFamily: 'ChunkFive',
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _loadGamePage(GameSection section, int index) {
    switch (section.name) {
      case "Cruciverba":
        return CrosswordPage(level: index);
      case "Anagramma":
        return AnagramPage(level: index);
      case "Trova la Parola":
        return FindWordPage(level: index);
      case "Sudoku":
        return SudokuPage(level: index);
      case "Cerca le Parole":
        return SearchWord(level: index);
      default:
        return const Placeholder(); // Gestisci il caso predefinito
    }
  }
}
