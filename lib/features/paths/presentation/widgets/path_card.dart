import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../providers/app_providers.dart';
import '../../domain/learning_path.dart';

class PathCard extends ConsumerWidget {
  const PathCard({
    super.key,
    required this.path,
    required this.completed,
    required this.onToggleCompleted,
  });

  final LearningPath path;
  final bool completed;
  final VoidCallback onToggleCompleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    path.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Icon(
                  completed ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: completed ? Colors.green : null,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(path.goal, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              path.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            ...path.steps.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  '${e.key + 1}. ${e.value}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: path.recommendedCommandIds.map((id) {
                final command = ref.watch(commandByIdProvider(id));
                return ActionChip(
                  label: Text(command?.name ?? id.replaceAll('_', ' ')),
                  onPressed: () => context.push('/command/$id'),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: onToggleCompleted,
                child: Text(
                  completed ? 'Marquer non terminé' : 'Marquer terminé',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
