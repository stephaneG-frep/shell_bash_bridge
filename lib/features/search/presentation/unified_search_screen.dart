import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/section_header.dart';
import '../../../providers/app_providers.dart';
import '../../distros/data/mock_package_actions.dart';
import '../../distros/data/mock_service_actions.dart';

class UnifiedSearchScreen extends ConsumerStatefulWidget {
  const UnifiedSearchScreen({super.key});

  @override
  ConsumerState<UnifiedSearchScreen> createState() =>
      _UnifiedSearchScreenState();
}

class _UnifiedSearchScreenState extends ConsumerState<UnifiedSearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();

    final commands = ref
        .watch(allCommandsProvider)
        .where((c) {
          if (q.isEmpty) return false;
          return ('${c.name} ${c.shortDescription} ${c.syntax}')
              .toLowerCase()
              .contains(q);
        })
        .take(8)
        .toList();

    final answers = ref
        .watch(answersProvider)
        .where((a) {
          if (q.isEmpty) return false;
          return ('${a.question} ${a.shortAnswer} ${a.tags.join(' ')}')
              .toLowerCase()
              .contains(q);
        })
        .take(6)
        .toList();

    final objectives = ref
        .watch(businessObjectivesProvider)
        .where((o) {
          if (q.isEmpty) return false;
          return ('${o.title} ${o.description}').toLowerCase().contains(q);
        })
        .take(6)
        .toList();

    final snippets = ref
        .watch(personalSnippetsProvider)
        .where((s) {
          if (q.isEmpty) return false;
          return ('${s.title} ${s.content}').toLowerCase().contains(q);
        })
        .take(6)
        .toList();

    final distroEntries = [...mockPackageActions, ...mockServiceActions]
        .where((d) {
          if (q.isEmpty) return false;
          return ('${d.action} ${d.description} ${d.commands.keys.join(' ')} ${d.commands.values.join(' ')}')
              .toLowerCase()
              .contains(q);
        })
        .take(8)
        .toList();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Recherche unifiée')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppSearchBar(
            hintText:
                'Recherche globale: commande, objectif, distro, snippet...',
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (q.isEmpty)
            Text(
              'Tape un mot-clé pour chercher partout.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else ...[
            _Section(
              title: 'Commandes',
              count: commands.length,
              child: Column(
                children: commands
                    .map(
                      (c) => ListTile(
                        title: Text(c.name),
                        subtitle: Text(c.shortDescription),
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () => context.push('/command/${c.id}'),
                      ),
                    )
                    .toList(),
              ),
            ),
            _Section(
              title: 'Réponses',
              count: answers.length,
              child: Column(
                children: answers
                    .map(
                      (a) => ListTile(
                        title: Text(a.question),
                        subtitle: Text(a.shortAnswer),
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () {
                          ref.read(answerQueryProvider.notifier).state =
                              a.question;
                          context.go('/answers');
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            _Section(
              title: 'Objectifs métier',
              count: objectives.length,
              child: Column(
                children: objectives
                    .map(
                      (o) => ListTile(
                        title: Text(o.title),
                        subtitle: Text(o.description),
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () {
                          ref.read(selectedIntentIdProvider.notifier).state =
                              o.intentId;
                          context.go('/answers');
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            _Section(
              title: 'Linux distro (paquets/services)',
              count: distroEntries.length,
              child: Column(
                children: distroEntries
                    .map(
                      (d) => ListTile(
                        title: Text(d.action),
                        subtitle: Text(d.description),
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () => context.go('/linux-packages'),
                      ),
                    )
                    .toList(),
              ),
            ),
            _Section(
              title: 'Snippets perso',
              count: snippets.length,
              child: Column(
                children: snippets
                    .map(
                      (s) => ListTile(
                        title: Text(s.title),
                        subtitle: Text(
                          s.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () => context.go('/notes'),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.count,
    required this.child,
  });

  final String title;
  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: title, subtitle: '$count résultat(s)'),
            const SizedBox(height: AppSpacing.xs),
            child,
          ],
        ),
      ),
    );
  }
}
