import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../providers/app_providers.dart';
import 'widgets/path_card.dart';

class LearningPathsScreen extends ConsumerWidget {
  const LearningPathsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paths = ref.watch(learningPathsProvider);
    final completedIds = ref.watch(completedPathIdsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Parcours guidés')),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: paths.length,
        itemBuilder: (context, index) {
          final path = paths[index];
          final completed = completedIds.contains(path.id);
          return PathCard(
            path: path,
            completed: completed,
            onToggleCompleted: () {
              ref.read(completedPathIdsProvider.notifier).toggle(path.id);
            },
          );
        },
      ),
    );
  }
}
