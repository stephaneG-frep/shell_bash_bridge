import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_drawer.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const _SettingTile(
            title: 'Thème',
            subtitle: 'Sombre premium (Material 3)',
            icon: Icons.dark_mode_outlined,
          ),
          const _SettingTile(
            title: 'Version',
            subtitle: '1.0.0+1',
            icon: Icons.info_outline,
          ),
          const _SettingTile(
            title: 'À propos',
            subtitle: 'Application éducative Bash / PowerShell',
            icon: Icons.school_outlined,
          ),
          const _SettingTile(
            title: 'Exporter/Importer',
            subtitle: 'Fonction prévue dans une prochaine version',
            icon: Icons.import_export,
          ),
          _SettingTile(
            title: 'Mode d’emploi pédagogique',
            subtitle: 'Guide pas à pas pour apprendre avec méthode',
            icon: Icons.menu_book_outlined,
            onTap: () => context.go('/guide'),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
