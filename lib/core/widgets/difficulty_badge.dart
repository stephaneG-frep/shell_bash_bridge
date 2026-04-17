import 'package:flutter/material.dart';

import '../utils/enums.dart';

class DifficultyBadge extends StatelessWidget {
  const DifficultyBadge({super.key, required this.level});

  final DifficultyLevel level;

  Color _colorFor(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return const Color(0xFF2BD67B);
      case DifficultyLevel.intermediate:
        return const Color(0xFFFFC857);
      case DifficultyLevel.advanced:
        return const Color(0xFFFF6B6B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        level.label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}
