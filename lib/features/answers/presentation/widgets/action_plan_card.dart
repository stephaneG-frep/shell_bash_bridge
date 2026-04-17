import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../providers/app_providers.dart';
import '../../domain/action_plan.dart';

class ActionPlanCard extends ConsumerWidget {
  const ActionPlanCard({super.key, required this.plan});

  final ActionPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressMap = ref.watch(actionPlanProgressProvider);
    final checks =
        progressMap[plan.id] ?? List<bool>.filled(plan.steps.length, false);
    final completed = checks.where((c) => c).length;
    final ratio = plan.steps.isEmpty ? 0.0 : completed / plan.steps.length;

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
                    plan.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Text('${(ratio * 100).toInt()}%'),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              plan.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(value: ratio),
            const SizedBox(height: AppSpacing.md),
            ...plan.steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isChecked = index < checks.length ? checks[index] : false;
              return CheckboxListTile(
                value: isChecked,
                contentPadding: EdgeInsets.zero,
                title: Text(step),
                onChanged: (_) {
                  ref
                      .read(actionPlanProgressProvider.notifier)
                      .toggleStep(plan.id, plan.steps.length, index);
                },
              );
            }),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Conseil de sécurité',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            ...plan.safetyTips.map(
              (tip) =>
                  Text('• $tip', style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: plan.commandIds.map((id) {
                final command = ref.watch(commandByIdProvider(id));
                return ActionChip(
                  label: Text(command?.name ?? id.replaceAll('_', ' ')),
                  onPressed: () => context.push('/command/$id'),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: () {
                ref
                    .read(actionPlanProgressProvider.notifier)
                    .resetPlan(plan.id, plan.steps.length);
              },
              icon: const Icon(Icons.restart_alt),
              label: const Text('Réinitialiser la checklist'),
            ),
          ],
        ),
      ),
    );
  }
}
