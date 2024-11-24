import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_game/core/crossword/bloc/crossword_bloc.dart';
import 'package:word_game/core/crossword/pages/crossword_page.dart';
import 'package:word_game/data_models/GameSection.dart';

class LevelsPage extends StatelessWidget {
  GameSection section;
  LevelsPage({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${section.name.toUpperCase()}"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6, // Numero di colonne nella griglia
            crossAxisSpacing: 10.0, // Spaziatura orizzontale tra i quadratini
            mainAxisSpacing: 10.0, // Spaziatura verticale tra i quadratini
          ),
          itemCount: 200, // Numero totale di quadratini
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => CrosswordBloc([]),
                      child: CrosswordPage(level: index+1,),
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: index < 10 ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}', // Mostra il numero del quadratino
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}