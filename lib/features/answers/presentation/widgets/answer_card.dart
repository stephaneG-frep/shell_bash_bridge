import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../providers/app_providers.dart';
import '../../domain/answer_entry.dart';

class AnswerCard extends ConsumerWidget {
  const AnswerCard({super.key, required this.entry});

  final AnswerEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.question, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              entry.shortAnswer,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Étapes', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            ...entry.steps.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  '• $s',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            if (entry.relatedCommandIds.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: entry.relatedCommandIds.map((id) {
                  final command = ref.watch(commandByIdProvider(id));
                  return ActionChip(
                    label: Text(command?.name ?? id.replaceAll('_', ' ')),
                    onPressed: () => context.push('/command/$id'),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
