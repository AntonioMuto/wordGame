import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_game/core/levels/bloc/levels_bloc.dart';
import 'package:word_game/core/levels/pages/levels_page.dart';
import 'package:word_game/data_models/GameSection.dart';

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
                child: LevelsPage(section: section),
              ),
            ),
          );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: section.color.withOpacity(1), width: 2)),
        elevation: 4,
        color: section.color.withOpacity(0.9),
        shadowColor: section.color.withOpacity(0.5),
        borderOnForeground: true,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 83, 83, 83),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color.fromARGB(255, 30, 78, 32), width: 1),
                  shape: BoxShape.rectangle,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10), // Stesso raggio del Container
                  child: Center(
                    child: Image.asset(
                      "assets/images/${section.gameImage}.png",
                      width: 50, // Deve coincidere con il container
                      height: 50, // Deve coincidere con il container
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Descrizione
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(section.name, style: const TextStyle(
                            fontFamily: 'ChunkFive',
                            color: Colors.white,
                            fontSize: 15)),
                    const SizedBox(height: 8),
                    Text("${section.progress * 100} %", style: const TextStyle(
                            fontFamily: 'ChunkFive',
                            color: Colors.white,
                            fontSize: 15)),
                    
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 73, 73, 73),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color.fromARGB(255, 30, 78, 32), width: 1),
                  shape: BoxShape.rectangle,
                ),
                child: Center(
                  child: Column(
                    children: [
                      Text("LVL", style: const TextStyle(
                            fontFamily: 'ChunkFive',
                            color: Colors.white,
                            fontSize: 14)),
                      Text(section.level.toString(),
                          style: const TextStyle(
                            fontFamily: 'ChunkFive',
                            color: Colors.white,
                            fontSize: 19
                      )),
                    ],
                  ),
              ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
