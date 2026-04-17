import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';

class ShellHeaderCard extends StatelessWidget {
  const ShellHeaderCard({
    super.key,
    required this.title,
    required this.description,
    required this.color,
    required this.progress,
  });

  final String title;
  final String description;
  final Color color;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.code, color: color),
                const SizedBox(width: AppSpacing.sm),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(description, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            LinearProgressIndicator(value: progress, color: color),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${(progress * 100).toInt()}% de progression',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
