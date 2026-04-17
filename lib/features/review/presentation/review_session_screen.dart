import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/enums.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../providers/app_providers.dart';

class ReviewSessionScreen extends ConsumerStatefulWidget {
  const ReviewSessionScreen({super.key});

  @override
  ConsumerState<ReviewSessionScreen> createState() =>
      _ReviewSessionScreenState();
}

class _ReviewSessionScreenState extends ConsumerState<ReviewSessionScreen> {
  int _bundleSeed = 0;
  final Set<String> _doneCommands = <String>{};
  bool _objectiveDone = false;
  final Set<String> _doneQuiz = <String>{};

  @override
  Widget build(BuildContext context) {
    final commands = ref.watch(allCommandsProvider);
    final objectives = ref.watch(businessObjectivesProvider);
    final quiz = ref.watch(quizQuestionsProvider(null));

    final commandSlice = _slice(commands, 3, _bundleSeed);
    final objective = objectives.isEmpty
        ? null
        : objectives[_bundleSeed % objectives.length];
    final quizSlice = _slice(quiz, 5, _bundleSeed + 2);

    final completedCount =
        _doneCommands.length + (_objectiveDone ? 1 : 0) + _doneQuiz.length;
    const total = 9;
    final ratio = completedCount / total;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Révision 10 min')),
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
                    'Session auto',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '3 commandes + 1 objectif + 5 questions. Avance étape par étape.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  LinearProgressIndicator(value: ratio),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$completedCount / $total terminé',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      setState(() {
                        _bundleSeed += 1;
                        _doneCommands.clear();
                        _objectiveDone = false;
                        _doneQuiz.clear();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Nouvelle session'),
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
                    '3 commandes à revoir',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...commandSlice.map(
                    (cmd) => CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _doneCommands.contains(cmd.id),
                      title: Text(cmd.name),
                      subtitle: Text(cmd.shortDescription),
                      secondary: IconButton(
                        icon: const Icon(Icons.open_in_new),
                        onPressed: () => context.push('/command/${cmd.id}'),
                      ),
                      onChanged: (_) {
                        setState(() {
                          if (_doneCommands.contains(cmd.id)) {
                            _doneCommands.remove(cmd.id);
                          } else {
                            _doneCommands.add(cmd.id);
                          }
                        });
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
                  Text(
                    'Objectif du jour',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (objective == null)
                    Text(
                      'Aucun objectif disponible.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else ...[
                    Text(
                      objective.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      objective.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        FilledButton.tonal(
                          onPressed: () {
                            ref.read(selectedIntentIdProvider.notifier).state =
                                objective.intentId;
                            context.go('/answers');
                          },
                          child: const Text('Ouvrir plan'),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        FilterChip(
                          label: const Text('Terminé'),
                          selected: _objectiveDone,
                          onSelected: (v) => setState(() => _objectiveDone = v),
                        ),
                      ],
                    ),
                  ],
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
                    'Quiz 5 questions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...quizSlice.map(
                    (q) => CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _doneQuiz.contains(q.id),
                      title: Text(q.question),
                      subtitle: Text('Niveau: ${q.difficulty.label}'),
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _doneQuiz.add(q.id);
                          } else {
                            _doneQuiz.remove(q.id);
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FilledButton(
                    onPressed: () => context.push('/quiz'),
                    child: const Text('Lancer quiz complet'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<T> _slice<T>(List<T> data, int count, int seed) {
    if (data.isEmpty) return const [];
    final start = seed % data.length;
    final out = <T>[];
    for (var i = 0; i < count; i++) {
      out.add(data[(start + i) % data.length]);
    }
    return out;
  }
}
