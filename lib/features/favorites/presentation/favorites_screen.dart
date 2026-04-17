import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/enums.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../providers/app_providers.dart';
import '../../commands/presentation/widgets/command_list_item.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  ShellType? _shellType;

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoriteCommandsProvider).where((cmd) {
      if (_shellType == null) return true;
      return cmd.shellType == _shellType;
    }).toList();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Favoris')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: DropdownButton<ShellType?>(
              isExpanded: true,
              value: _shellType,
              hint: const Text('Filtrer par shell'),
              items: const [
                DropdownMenuItem<ShellType?>(value: null, child: Text('Tous')),
                DropdownMenuItem<ShellType?>(
                  value: ShellType.bash,
                  child: Text('Bash'),
                ),
                DropdownMenuItem<ShellType?>(
                  value: ShellType.powershell,
                  child: Text('PowerShell'),
                ),
              ],
              onChanged: (value) => setState(() => _shellType = value),
            ),
          ),
          Expanded(
            child: favorites.isEmpty
                ? const EmptyStateView(
                    icon: Icons.favorite_border,
                    title: 'Aucun favori',
                    message:
                        'Ajoute des commandes en favori pour les retrouver vite.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final item = favorites[index];
                      return CommandListItem(
                        command: item,
                        isFavorite: true,
                        onTap: () => context.push('/command/${item.id}'),
                        onFavoriteTap: () {
                          ref
                              .read(userProgressProvider.notifier)
                              .toggleFavorite(item.id);
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
