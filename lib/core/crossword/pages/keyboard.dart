import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/crossword_bloc.dart';

class Keyboard extends StatelessWidget {
  final List<String> row1 = ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'];
  final List<String> row2 = ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'];
  final List<String> row3 = ['clean', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', 'delete'];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width; // Larghezza schermo
    final double buttonSize = screenWidth / 10 - 8; // Larghezza dei tasti con spaziatura
    final double spacing = 6.0; // Spaziatura tra i tasti

    return Container(
      color: Colors.white, // Sfondo chiaro
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Prima riga
          _buildKeyboardRow(context, row1, buttonSize, spacing),
          const SizedBox(height: 8), // Spazio tra le righe
          // Seconda riga
          _buildKeyboardRow(context, row2, buttonSize, spacing),
          const SizedBox(height: 8), // Spazio tra le righe
          // Terza riga
          _buildKeyboardRow(context, row3, buttonSize, spacing, isLastRow: true),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(
    BuildContext context,
    List<String> letters,
    double buttonSize,
    double spacing, {
    bool isLastRow = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: letters.map((letter) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing / 2),
          child: GestureDetector(
            onTap: () {
              if (letter == 'delete') {
                context.read<CrosswordBloc>().add(RemoveLetterEvent());
              } else if (letter == 'clean') {
                context.read<CrosswordBloc>().add(ResetWordEvent());
              } else {
                context.read<CrosswordBloc>().add(InsertLetterEvent(letter: letter));
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200], // Colore chiaro per i tasti
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(2, 2),
                    blurRadius: 4.0,
                  ),
                ],
              ),
              width: letter == 'delete' || letter == 'clean' ? buttonSize * 1.4 : buttonSize ,
              height: buttonSize,
              child: Center(
                child: letter == 'delete'
                    ? const Icon(
                        Icons.backspace, // Icona per "cancella"
                        color: Colors.black87,
                        size: 24,
                      )
                    : letter == 'clean'
                        ? const Icon(
                            Icons.cleaning_services, // Icona per "pulisci"
                            color: Colors.black87,
                            size: 24,
                          )
                        : Text(
                            letter,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
