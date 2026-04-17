import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../providers/app_providers.dart';
import '../domain/personal_snippet.dart';

class NotesPlusScreen extends ConsumerStatefulWidget {
  const NotesPlusScreen({super.key});

  @override
  ConsumerState<NotesPlusScreen> createState() => _NotesPlusScreenState();
}

class _NotesPlusScreenState extends ConsumerState<NotesPlusScreen> {
  late final TextEditingController _globalNotesController;
  final TextEditingController _importController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _globalNotesController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _globalNotesController.text = ref.read(globalNotesProvider);
    });
  }

  @override
  void dispose() {
    _globalNotesController.dispose();
    _importController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final globalNotes = ref.watch(globalNotesProvider);
    final snippets = ref.watch(personalSnippetsProvider);
    final dailyIds = ref.watch(dailyCommandIdsProvider);
    final dailyCommands = ref.watch(dailyCommandsProvider);
    final allCommands = ref.watch(allCommandsProvider);

    if (_globalNotesController.text != globalNotes) {
      _globalNotesController.text = globalNotes;
      _globalNotesController.selection = TextSelection.fromPosition(
        TextPosition(offset: _globalNotesController.text.length),
      );
    }

    final q = _searchController.text.trim().toLowerCase();
    final filteredCommands = allCommands
        .where((cmd) {
          if (q.isEmpty) return true;
          return ('${cmd.name} ${cmd.shortDescription}').toLowerCase().contains(
            q,
          );
        })
        .take(120)
        .toList();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Notes+ perso')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes globales',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _globalNotesController,
                    minLines: 4,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      hintText:
                          'Ajoute tes repères, commandes réflexes, anti-pièges...',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      ref
                          .read(globalNotesProvider.notifier)
                          .setNotes(_globalNotesController.text);
                      _snack(context, 'Notes globales enregistrées');
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Enregistrer'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mes commandes du quotidien',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (dailyCommands.isEmpty)
                    Text(
                      'Aucune pour l’instant.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: dailyCommands
                          .map(
                            (c) => InputChip(
                              label: Text(c.name),
                              onPressed: () {},
                              onDeleted: () => ref
                                  .read(dailyCommandIdsProvider.notifier)
                                  .toggle(c.id),
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Rechercher commande à ajouter...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      itemCount: filteredCommands.length,
                      itemBuilder: (context, index) {
                        final cmd = filteredCommands[index];
                        final selected = dailyIds.contains(cmd.id);
                        return CheckboxListTile(
                          dense: true,
                          value: selected,
                          title: Text(cmd.name),
                          subtitle: Text(
                            cmd.shortDescription,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onChanged: (_) => ref
                              .read(dailyCommandIdsProvider.notifier)
                              .toggle(cmd.id),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Snippets perso',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () => _showSnippetDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (snippets.isEmpty)
                    Text(
                      'Aucun snippet pour le moment.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    ...snippets.map(
                      (snippet) => Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ListTile(
                          title: Text(snippet.title),
                          subtitle: Text(
                            snippet.content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _showSnippetDialog(
                                  context,
                                  existing: snippet,
                                ),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                onPressed: () => ref
                                    .read(personalSnippetsProvider.notifier)
                                    .remove(snippet.id),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                          onTap: () async {
                            await Clipboard.setData(
                              ClipboardData(text: snippet.content),
                            );
                            if (context.mounted) {
                              _snack(context, 'Snippet copié');
                            }
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sauvegarde JSON (export/import)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      FilledButton.icon(
                        onPressed: () async {
                          final json = ref
                              .read(appBackupServiceProvider)
                              .exportJson();
                          await Clipboard.setData(ClipboardData(text: json));
                          if (context.mounted) {
                            _snack(
                              context,
                              'Export JSON copié dans le presse-papiers',
                            );
                          }
                        },
                        icon: const Icon(Icons.ios_share_outlined),
                        label: const Text('Exporter (copier)'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final ok = await ref
                              .read(appBackupServiceProvider)
                              .importJson(_importController.text);
                          if (context.mounted) {
                            _snack(
                              context,
                              ok ? 'Import réussi' : 'Import invalide',
                            );
                          }
                        },
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Importer'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _importController,
                    minLines: 5,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      hintText:
                          'Colle ici ton JSON exporté puis clique sur Importer',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSnippetDialog(
    BuildContext context, {
    PersonalSnippet? existing,
  }) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final contentController = TextEditingController(
      text: existing?.content ?? '',
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            existing == null ? 'Nouveau snippet' : 'Modifier snippet',
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(hintText: 'Titre'),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: contentController,
                  minLines: 4,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText: 'Contenu snippet',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    if (saved == true) {
      final snippet = PersonalSnippet(
        id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: titleController.text.trim().isEmpty
            ? 'Snippet'
            : titleController.text.trim(),
        content: contentController.text,
      );
      await ref.read(personalSnippetsProvider.notifier).upsert(snippet);
      if (context.mounted) {
        _snack(context, 'Snippet enregistré');
      }
    }

    titleController.dispose();
    contentController.dispose();
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
