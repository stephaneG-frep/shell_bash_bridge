import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/enums.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../providers/app_providers.dart';
import 'widgets/command_list_item.dart';

class CommandsScreen extends ConsumerStatefulWidget {
  const CommandsScreen({super.key, this.initialShell});

  final ShellType? initialShell;

  @override
  ConsumerState<CommandsScreen> createState() => _CommandsScreenState();
}

class _CommandsScreenState extends ConsumerState<CommandsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(commandFilterProvider.notifier).reset(widget.initialShell);
    });
  }

  @override
  Widget build(BuildContext context) {
    final commands = ref.watch(filteredCommandsProvider);
    final progress = ref.watch(userProgressProvider);
    final filter = ref.watch(commandFilterProvider);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Commandes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
            child: AppSearchBar(
              hintText: 'Nom, syntaxe, description...',
              onChanged: (value) => ref.read(commandFilterProvider.notifier).setQuery(value),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Favoris'),
                  selected: filter.onlyFavorites,
                  onSelected: (value) => ref.read(commandFilterProvider.notifier).setOnlyFavorites(value),
                ),
                const SizedBox(width: AppSpacing.sm),
                ...DifficultyLevel.values.map(
                  (level) => Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: FilterChip(
                      label: Text(level.label),
                      selected: filter.difficulty == level,
                      onSelected: (value) {
                        ref.read(commandFilterProvider.notifier).setDifficulty(value ? level : null);
                      },
                    ),
                  ),
                ),
                DropdownButton<String?>(
                  value: filter.categoryId,
                  hint: const Text('Catégorie'),
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('Toutes')),
                    ...categories.map(
                      (c) => DropdownMenuItem<String?>(value: c.id, child: Text(c.title)),
                    ),
                  ],
                  onChanged: (value) {
                    ref.read(commandFilterProvider.notifier).setCategory(value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: commands.isEmpty
                ? const EmptyStateView(
                    icon: Icons.search_off,
                    title: 'Aucune commande',
                    message: 'Ajuste les filtres ou la recherche.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: commands.length,
                    itemBuilder: (context, index) {
                      final command = commands[index];
                      return CommandListItem(
                        command: command,
                        isFavorite: progress.favoriteCommandIds.contains(command.id),
                        onTap: () => context.push('/command/${command.id}'),
                        onFavoriteTap: () {
                          ref.read(userProgressProvider.notifier).toggleFavorite(command.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
