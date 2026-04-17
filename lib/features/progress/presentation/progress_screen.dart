import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/section_header.dart';
import '../../../providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/badge_card.dart';
import 'widgets/progress_stat_card.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progression')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              ProgressStatCard(
                label: 'Commandes vues',
                value: '${progress.viewedCommandIds.length}',
                icon: Icons.visibility_outlined,
              ),
              ProgressStatCard(
                label: 'Quiz terminés',
                value: '${progress.completedQuizCount}',
                icon: Icons.quiz_outlined,
              ),
              ProgressStatCard(
                label: 'Score moyen',
                value: '${(progress.averageScore * 100).toInt()}%',
                icon: Icons.analytics_outlined,
              ),
              ProgressStatCard(
                label: 'Série',
                value: '${progress.learningStreak} jours',
                icon: Icons.local_fire_department_outlined,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Progression par shell'),
          const SizedBox(height: AppSpacing.sm),
          _ProgressBar(label: 'Bash', value: progress.bashProgress),
          _ProgressBar(label: 'PowerShell', value: progress.powershellProgress),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Badges'),
          const SizedBox(height: AppSpacing.sm),
          if (progress.earnedBadges.isEmpty)
            const BadgeCard(
              title: 'Débutant - commence par consulter 5 commandes',
            )
          else
            ...progress.earnedBadges.map((b) => BadgeCard(title: b)),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          LinearProgressIndicator(value: value),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${(value * 100).toInt()}%',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
