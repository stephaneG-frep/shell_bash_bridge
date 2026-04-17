import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../data/mock_package_actions.dart';
import '../data/mock_service_actions.dart';
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
  _LinuxCommandsMode _mode = _LinuxCommandsMode.packages;

  @override
  Widget build(BuildContext context) {
    final source = _mode == _LinuxCommandsMode.packages
        ? mockPackageActions
        : mockServiceActions;
    final data = source.where((item) {
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
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Paquets'),
                  selected: _mode == _LinuxCommandsMode.packages,
                  onSelected: (_) =>
                      setState(() => _mode = _LinuxCommandsMode.packages),
                ),
                const SizedBox(width: AppSpacing.sm),
                ChoiceChip(
                  label: const Text('Services & Logs'),
                  selected: _mode == _LinuxCommandsMode.services,
                  onSelected: (_) =>
                      setState(() => _mode = _LinuxCommandsMode.services),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xs,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: AppSearchBar(
              hintText: _mode == _LinuxCommandsMode.packages
                  ? 'Ex: install, pacman -Syu, zypper refresh...'
                  : 'Ex: systemctl status, journalctl -u nginx...',
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

enum _LinuxCommandsMode { packages, services }
