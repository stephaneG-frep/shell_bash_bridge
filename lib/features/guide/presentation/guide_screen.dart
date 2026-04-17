import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_drawer.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Mode d’emploi pédagogique')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [
          _GuideSection(
            title: '1. Commencer simplement',
            content:
                'Depuis le Drawer, ouvre Accueil puis Centre de réponses. Choisis une intention (ex: Lister les fichiers) pour obtenir une réponse ciblée.',
          ),
          _GuideSection(
            title: '2. Apprendre par objectifs',
            content:
                'Utilise Objectifs métier pour lancer un cas concret. L’app te propose ensuite un plan d’action avec checklist.',
          ),
          _GuideSection(
            title: '3. Comprendre les commandes',
            content:
                'Ouvre une commande pour voir syntaxe, exemple, erreurs fréquentes, conseils et ton équivalent Bash/PowerShell.',
          ),
          _GuideSection(
            title: '4. Progresser vite',
            content:
                'Ajoute les commandes utiles en favoris, prends des notes personnelles, puis fais des quiz réguliers.',
          ),
          _GuideSection(
            title: '5. Révision intelligente',
            content:
                'Consulte Progression pour suivre commandes vues, score moyen, badges et série d’apprentissage.',
          ),
          _GuideSection(
            title: 'Conseil méthode',
            content:
                'Travaille en boucle courte: objectif -> plan -> commande -> quiz -> révision. Cette cadence ancre durablement les bases terminal.',
          ),
        ],
      ),
    );
  }
}

class _GuideSection extends StatelessWidget {
  const _GuideSection({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(content, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
