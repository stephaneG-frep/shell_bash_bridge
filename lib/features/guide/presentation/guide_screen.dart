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
            title: '1. Navigation rapide (Drawer)',
            content:
                'Tout passe par le Drawer: Accueil, Bash, PowerShell, Compare, Centre de réponses, Notes+, Commandes Linux par distro, Quiz, Favoris, Progression.',
          ),
          _GuideSection(
            title: '2. Centre de réponses (mode intelligent)',
            content:
                'Pose une question libre ou choisis une intention. Ajoute un contexte Shell/Niveau pour obtenir une réponse ciblée plus pertinente.',
          ),
          _GuideSection(
            title: '3. Objectifs métier',
            content:
                'Sélectionne un cas concret (ex: nettoyer des logs, contrôler un process) pour lancer un plan prêt à exécuter.',
          ),
          _GuideSection(
            title: '4. Plan d’action checklist',
            content:
                'Chaque plan propose des étapes cochables + commandes liées. Tu peux reprendre plus tard: la progression est sauvegardée.',
          ),
          _GuideSection(
            title: '5. Détail commande',
            content:
                'Chaque fiche inclut syntaxe, exemple, erreurs fréquentes, conseils, équivalent inter-shell et notes personnelles.',
          ),
          _GuideSection(
            title: '6. Mode commande sûre',
            content:
                'Active ce mode dans Paramètres. Pour les commandes sensibles (rm, chmod, systemctl...), une checklist sécurité s’affiche avant action.',
          ),
          _GuideSection(
            title: '7. Favoris contextuels',
            content:
                'Range tes favoris par contexte (Urgence prod, Routine dev, Maintenance Linux...) et filtre-les dans l’écran Favoris.',
          ),
          _GuideSection(
            title: '8. Notes+ perso',
            content:
                'Centralise tes notes globales, tes commandes du quotidien et tes snippets réutilisables avec copie rapide.',
          ),
          _GuideSection(
            title: '9. Export / Import JSON',
            content:
                'Depuis Notes+, exporte en JSON (copie presse-papiers) et réimporte pour restaurer progression, favoris, notes et snippets.',
          ),
          _GuideSection(
            title: '10. Linux par distribution',
            content:
                'La page distro couvre apt/pacman/dnf/zypper et aussi Services & Logs (systemctl/service/journalctl) avec copier-coller 1 tap.',
          ),
          _GuideSection(
            title: '11. Révision intelligente',
            content:
                'Utilise Quiz + Progression pour identifier tes lacunes, refaire des sessions courtes et renforcer la mémorisation.',
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
