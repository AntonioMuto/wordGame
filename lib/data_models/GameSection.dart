import 'package:flutter/material.dart';

class GameSection {
  final String name;
  final IconData icon;
  final int level;
  final double progress;

  GameSection({
    required this.name,
    required this.icon,
    required this.level,
    required this.progress,
  });
}
