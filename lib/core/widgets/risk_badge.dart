import 'package:flutter/material.dart';

import '../utils/command_risk.dart';

class RiskBadge extends StatelessWidget {
  const RiskBadge({super.key, required this.risk});

  final CommandRisk risk;

  @override
  Widget build(BuildContext context) {
    final (foreground, background, icon) = switch (risk.level) {
      CommandRiskLevel.low => (
        const Color(0xFF3ED07A),
        const Color(0x193ED07A),
        Icons.check_circle_outline,
      ),
      CommandRiskLevel.medium => (
        const Color(0xFFFFC857),
        const Color(0x19FFC857),
        Icons.warning_amber_rounded,
      ),
      CommandRiskLevel.high => (
        const Color(0xFFFF6B6B),
        const Color(0x19FF6B6B),
        Icons.error_outline,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: foreground.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 6),
          Text(
            risk.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
