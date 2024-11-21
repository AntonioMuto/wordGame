import 'package:flutter/material.dart';
import 'package:word_game/data_models/GameSection.dart';

class GameSectionCard extends StatelessWidget {
  final GameSection section;

  const GameSectionCard({required this.section, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icona
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue[100],
              child: Icon(section.icon, size: 30, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            // Descrizione
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.name,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Livello: ${section.level}",
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: section.progress,
                    backgroundColor: Colors.grey[300],
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
