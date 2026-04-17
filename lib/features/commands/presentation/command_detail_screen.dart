import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/difficulty_badge.dart';
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
          Row(
            children: [
              ShellChip(shellType: command.shellType),
              const SizedBox(width: AppSpacing.sm),
              DifficultyBadge(level: command.difficulty),
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
            Row(
              children: [
                FilledButton.tonal(
                  onPressed: () => widget.onSave(_controller.text),
                  child: const Text('Enregistrer'),
                ),
                const SizedBox(width: AppSpacing.sm),
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
