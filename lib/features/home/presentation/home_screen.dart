import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/enums.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/section_header.dart';
import '../../../providers/app_providers.dart';
import '../../commands/presentation/widgets/command_list_item.dart';
import 'widgets/continue_learning_card.dart';
import 'widgets/home_hero_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommended = ref.watch(recommendedCommandsProvider);
    final progress = ref.watch(userProgressProvider);
    final favorites = ref.watch(favoriteCommandsProvider).take(3).toList();
    final tip = ref.watch(tipOfDayProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shell-Bash-Bridge'),
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text('Commencer ici', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Apprends Bash et PowerShell étape par étape, puis compare les commandes.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppSearchBar(
              hintText: 'Rechercher une commande...',
              onChanged: (value) {
                ref.read(commandFilterProvider.notifier).setQuery(value);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            HomeHeroCard(
              title: 'Apprendre Bash',
              subtitle: 'Navigation, fichiers, système, scripts.',
              icon: Icons.terminal,
              color: AppColors.bashAccent,
              onTap: () => context.go('/bash'),
            ),
            HomeHeroCard(
              title: 'Apprendre PowerShell',
              subtitle: 'Cmdlets, pipeline, automatisation Windows.',
              icon: Icons.flash_on,
              color: AppColors.powershellAccent,
              onTap: () => context.push('/powershell'),
            ),
            HomeHeroCard(
              title: 'Comparer les commandes',
              subtitle: 'Bash ↔ PowerShell par action.',
              icon: Icons.compare_arrows,
              color: AppColors.secondaryAccent,
              onTap: () => context.go('/compare'),
            ),
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(
              title: 'Continuer l’apprentissage',
              subtitle: 'Série actuelle: ${progress.learningStreak} jours',
            ),
            const SizedBox(height: AppSpacing.sm),
            ContinueLearningCard(
              title: 'Parcours Bash',
              progress: progress.bashProgress,
              onTap: () => context.go('/bash'),
            ),
            ContinueLearningCard(
              title: 'Parcours PowerShell',
              progress: progress.powershellProgress,
              onTap: () => context.push('/powershell'),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: 'Commandes recommandées pour débuter'),
            const SizedBox(height: AppSpacing.sm),
            ...recommended.map(
              (item) => CommandListItem(
                command: item,
                isFavorite: progress.favoriteCommandIds.contains(item.id),
                onTap: () => context.push('/command/${item.id}'),
                onFavoriteTap: () {
                  ref.read(userProgressProvider.notifier).toggleFavorite(item.id);
                },
              ),
            ),
            if (favorites.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Favoris récents'),
              const SizedBox(height: AppSpacing.sm),
              ...favorites.map(
                (item) => CommandListItem(
                  command: item,
                  isFavorite: true,
                  onTap: () => context.push('/command/${item.id}'),
                  onFavoriteTap: () {
                    ref.read(userProgressProvider.notifier).toggleFavorite(item.id);
                  },
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: AppStrings.tipOfDayTitle),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(tip, style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.tonalIcon(
              onPressed: () => context.push('/quiz?shell=${ShellType.bash.name}'),
              icon: const Icon(Icons.quiz_outlined),
              label: const Text('Quiz Bash rapide'),
            ),
          ],
        ),
      ),
    );
  }
}
