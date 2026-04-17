import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';

class BadgeCard extends StatelessWidget {
  const BadgeCard({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium_outlined),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(title)),
          ],
        ),
      ),
    );
  }
}
