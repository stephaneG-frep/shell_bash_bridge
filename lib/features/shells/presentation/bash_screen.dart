import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/enums.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/section_header.dart';
import '../../../providers/app_providers.dart';
import '../presentation/widgets/category_grid.dart';
import '../presentation/widgets/shell_header_card.dart';

class BashScreen extends ConsumerWidget {
  const BashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);
    final categories = ref
        .watch(categoriesProvider)
        .where((c) => c.shellTypes.contains(ShellType.bash))
        .toList();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Bash')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          ShellHeaderCard(
            title: 'Bash Foundations',
            description:
                'Commandes Linux essentielles pour naviguer et manipuler fichiers.',
            color: AppColors.bashAccent,
            progress: progress.bashProgress,
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Catégories Bash'),
          const SizedBox(height: AppSpacing.sm),
          CategoryGrid(
            categories: categories,
            onTap: (category) {
              ref.read(commandFilterProvider.notifier).reset(ShellType.bash);
              ref.read(commandFilterProvider.notifier).setCategory(category.id);
              context.push('/commands?shell=${ShellType.bash.name}');
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: () {
              ref.read(commandFilterProvider.notifier).reset(ShellType.bash);
              context.push('/commands?shell=${ShellType.bash.name}');
            },
            icon: const Icon(Icons.menu_book_outlined),
            label: const Text('Voir toutes les commandes Bash'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => context.push('/quiz?shell=${ShellType.bash.name}'),
            icon: const Icon(Icons.quiz_outlined),
            label: const Text('Lancer le quiz Bash'),
          ),
        ],
      ),
    );
  }
}
