import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../utils/enums.dart';

class ShellChip extends StatelessWidget {
  const ShellChip({super.key, required this.shellType});

  final ShellType shellType;

  @override
  Widget build(BuildContext context) {
    final color = shellType == ShellType.bash
        ? AppColors.bashAccent
        : AppColors.powershellAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        shellType.label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
