import 'package:flutter/material.dart';

class GameSection {
  final String name;
  final String gameImage;
  final int level;
  final double progress;
  final Color color;
  final int currentLevel;

  GameSection({
    required this.name,
    required this.gameImage,
    required this.level,
    required this.progress,
    required this.color,
    required this.currentLevel,
  });
}
