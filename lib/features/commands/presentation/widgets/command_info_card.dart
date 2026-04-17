import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';

class CommandInfoCard extends StatelessWidget {
  const CommandInfoCard({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(content, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
