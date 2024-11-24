import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/crossword_bloc.dart';

class Keyboard extends StatelessWidget {
  final List<String> letters = [
    'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P',
    'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L',
    'Z', 'X', 'C', 'V', 'B', 'N', 'M', "<-", "CANC" 
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 10, // Numero di colonne per la tastiera
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: letters.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            if(letters[index] == '<-'){
              context.read<CrosswordBloc>()
                  .add(RemoveLetterEvent());
            } else if(letters[index] == 'CANC'){
              context.read<CrosswordBloc>()
                  .add(ResetWordEvent());
            } 
            else {
              context.read<CrosswordBloc>()
                  .add(InsertLetterEvent(letter: letters[index]));
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Center(
              child: Text(
                letters[index],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
