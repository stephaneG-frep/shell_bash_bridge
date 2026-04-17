import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../data/mock_package_actions.dart';
import 'widgets/package_action_card.dart';

class LinuxPackageManagersScreen extends StatefulWidget {
  const LinuxPackageManagersScreen({super.key});

  @override
  State<LinuxPackageManagersScreen> createState() =>
      _LinuxPackageManagersScreenState();
}

class _LinuxPackageManagersScreenState
    extends State<LinuxPackageManagersScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final data = mockPackageActions.where((item) {
      if (_query.trim().isEmpty) return true;
      final q = _query.trim().toLowerCase();
      final haystack = [
        item.action,
        item.description,
        ...item.commands.keys,
        ...item.commands.values,
      ].join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Commandes Linux par distro')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: AppSearchBar(
              hintText: 'Ex: install package, update, pacman -Syu, zypper...',
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: data.isEmpty
                ? const EmptyStateView(
                    icon: Icons.search_off,
                    title: 'Aucun résultat',
                    message: 'Essaie avec apt, pacman, dnf, zypper, install...',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: data.length,
                    itemBuilder: (context, index) =>
                        PackageActionCard(item: data[index]),
                  ),
          ),
        ],
      ),
    );
  }
}
