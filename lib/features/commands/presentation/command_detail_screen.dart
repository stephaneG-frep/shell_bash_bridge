import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/command_risk.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/difficulty_badge.dart';
import '../../../core/widgets/risk_badge.dart';
import '../../../core/widgets/shell_chip.dart';
import '../../../core/widgets/terminal_code_block.dart';
import '../../../providers/app_providers.dart';
import 'widgets/command_info_card.dart';

class CommandDetailScreen extends ConsumerWidget {
  const CommandDetailScreen({super.key, required this.commandId});

  final String commandId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final command = ref.watch(commandByIdProvider(commandId));
    if (command == null) {
      return const Scaffold(
        drawer: AppDrawer(),
        body: Center(child: Text('Commande introuvable.')),
      );
    }

    final progress = ref.watch(userProgressProvider);
    final notes = ref.watch(commandNotesProvider);
    final safeModeEnabled = ref.watch(safeCommandModeProvider);
    final favoriteCollections = ref.watch(favoriteCollectionsProvider);
    final risk = assessCommandRisk(name: command.name, syntax: command.syntax);
    final isFavorite = progress.favoriteCommandIds.contains(command.id);
    final currentNote = notes[command.id] ?? '';
    final shellTotal = ref
        .watch(allCommandsProvider)
        .where((c) => c.shellType == command.shellType)
        .length;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(userProgressProvider.notifier)
          .markCommandViewed(command.id, command.shellType, shellTotal);
    });

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(command.name),
        actions: [
          IconButton(
            onPressed: () {
              ref
                  .read(userProgressProvider.notifier)
                  .toggleFavorite(command.id);
            },
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              ShellChip(shellType: command.shellType),
              DifficultyBadge(level: command.difficulty),
              RiskBadge(risk: risk),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TerminalCodeBlock(
            code: command.syntax,
            accent: command.shellType.name == 'bash'
                ? AppColors.bashAccent
                : AppColors.powershellAccent,
          ),
          const SizedBox(height: AppSpacing.md),
          CommandInfoCard(
            title: 'Description',
            content: command.fullDescription,
          ),
          CommandInfoCard(title: 'Exemple pratique', content: command.example),
          CommandInfoCard(
            title: 'Équivalent',
            content: command.equivalentCommandName,
          ),
          _FavoriteCollectionsCard(
            commandId: command.id,
            collections: favoriteCollections,
          ),
          if (risk.level != CommandRiskLevel.low) _RiskWarningCard(risk: risk),
          if (safeModeEnabled &&
              _isSensitiveCommand(command.name, command.syntax))
            _SafeCommandChecklistCard(
              commandName: command.name,
              syntax: command.syntax,
            ),
          _CommandNoteCard(
            commandId: command.id,
            initialValue: currentNote,
            onSave: (value) {
              ref
                  .read(commandNotesProvider.notifier)
                  .saveNote(command.id, value);
            },
          ),
          _ListInfoCard(
            title: 'Erreurs fréquentes',
            values: command.commonMistakes,
          ),
          _ListInfoCard(title: 'Conseils', values: command.tips),
        ],
      ),
    );
  }
}

class _RiskWarningCard extends StatelessWidget {
  const _RiskWarningCard({required this.risk});

  final CommandRisk risk;

  @override
  Widget build(BuildContext context) {
    final color = risk.level == CommandRiskLevel.high
        ? Colors.redAccent
        : Colors.amberAccent;
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.6)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: color),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                risk.message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool _isSensitiveCommand(String name, String syntax) {
  final normalized = '$name $syntax'.toLowerCase();
  const riskPatterns = [
    'rm',
    'remove-item',
    'chmod',
    'chown',
    'kill',
    'stop-process',
    'systemctl',
    'service ',
    'zypper remove',
    'apt remove',
    'dnf remove',
    'pacman -r',
  ];
  return riskPatterns.any(normalized.contains);
}

class _SafeCommandChecklistCard extends StatefulWidget {
  const _SafeCommandChecklistCard({
    required this.commandName,
    required this.syntax,
  });

  final String commandName;
  final String syntax;

  @override
  State<_SafeCommandChecklistCard> createState() =>
      _SafeCommandChecklistCardState();
}

class _SafeCommandChecklistCardState extends State<_SafeCommandChecklistCard> {
  bool _checkPath = false;
  bool _checkTarget = false;
  bool _checkRollback = false;

  @override
  Widget build(BuildContext context) {
    final completed = [
      _checkPath,
      _checkTarget,
      _checkRollback,
    ].where((v) => v).length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mode commande sûre',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Commande sensible détectée: ${widget.commandName}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _checkPath,
              title: const Text(
                'J’ai vérifié le contexte (chemin/service ciblé).',
              ),
              onChanged: (v) => setState(() => _checkPath = v ?? false),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _checkTarget,
              title: const Text(
                'J’ai confirmé la cible exacte de la commande.',
              ),
              onChanged: (v) => setState(() => _checkTarget = v ?? false),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _checkRollback,
              title: const Text('J’ai un plan de rollback ou une sauvegarde.'),
              onChanged: (v) => setState(() => _checkRollback = v ?? false),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Checklist: $completed/3',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteCollectionsCard extends ConsumerWidget {
  const _FavoriteCollectionsCard({
    required this.commandId,
    required this.collections,
  });

  final String commandId;
  final Map<String, List<String>> collections;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = collections.entries.toList()
      ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Favoris contextuels',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Nouvelle collection',
                  onPressed: () async {
                    final c = TextEditingController();
                    final add = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Nouvelle collection'),
                        content: TextField(
                          controller: c,
                          decoration: const InputDecoration(
                            hintText: 'Ex: Debug réseau',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Annuler'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Ajouter'),
                          ),
                        ],
                      ),
                    );
                    if (add == true) {
                      await ref
                          .read(favoriteCollectionsProvider.notifier)
                          .addCollection(c.text);
                    }
                    c.dispose();
                  },
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (entries.isEmpty)
              Text(
                'Aucune collection pour le moment.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: entries.map((entry) {
                  final selected = entry.value.contains(commandId);
                  return FilterChip(
                    label: Text(entry.key),
                    selected: selected,
                    onSelected: (_) {
                      ref
                          .read(favoriteCollectionsProvider.notifier)
                          .toggleCommand(entry.key, commandId);
                    },
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _CommandNoteCard extends StatefulWidget {
  const _CommandNoteCard({
    required this.commandId,
    required this.initialValue,
    required this.onSave,
  });

  final String commandId;
  final String initialValue;
  final ValueChanged<String> onSave;

  @override
  State<_CommandNoteCard> createState() => _CommandNoteCardState();
}

class _CommandNoteCardState extends State<_CommandNoteCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _CommandNoteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.commandId != widget.commandId) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mes notes', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _controller,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Ajoute ta note perso, exemple, piège à éviter...',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                FilledButton.tonal(
                  onPressed: () => widget.onSave(_controller.text),
                  child: const Text('Enregistrer'),
                ),
                TextButton(
                  onPressed: () {
                    _controller.clear();
                    widget.onSave('');
                  },
                  child: const Text('Effacer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ListInfoCard extends StatelessWidget {
  const _ListInfoCard({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            ...values.map(
              (value) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  '• $value',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
