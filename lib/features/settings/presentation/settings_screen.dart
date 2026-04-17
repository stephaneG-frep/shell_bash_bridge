import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [
          _SettingTile(
            title: 'Thème',
            subtitle: 'Sombre premium (Material 3)',
            icon: Icons.dark_mode_outlined,
          ),
          _SettingTile(
            title: 'Version',
            subtitle: '1.0.0+1',
            icon: Icons.info_outline,
          ),
          _SettingTile(
            title: 'À propos',
            subtitle: 'Application éducative Bash / PowerShell',
            icon: Icons.school_outlined,
          ),
          _SettingTile(
            title: 'Exporter/Importer',
            subtitle: 'Fonction prévue dans une prochaine version',
            icon: Icons.import_export,
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
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
