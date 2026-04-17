import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/terminal_code_block.dart';
import '../../domain/command_comparison.dart';

class ComparisonCard extends StatelessWidget {
  const ComparisonCard({super.key, required this.item});

  final CommandComparison item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.actionTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            TerminalCodeBlock(
              code: item.bashCommand,
              accent: AppColors.bashAccent,
            ),
            const SizedBox(height: AppSpacing.sm),
            TerminalCodeBlock(
              code: item.powershellCommand,
              accent: AppColors.powershellAccent,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              item.explanation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
