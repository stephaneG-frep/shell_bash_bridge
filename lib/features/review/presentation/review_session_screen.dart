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
  final Set<String> _doneCommands = <String>{};
  bool _objectiveDone = false;
  final Set<String> _doneQuiz = <String>{};

  @override
  Widget build(BuildContext context) {
    final bundle = ref.watch(adaptiveReviewBundleProvider);
    final quizInsights = ref.watch(quizInsightsProvider);
    final selectedShell = ref.watch(reviewShellFilterProvider);
    final selectedDifficulty = ref.watch(reviewDifficultyFilterProvider);
    final focusWeak = ref.watch(reviewFocusWeakProvider);

    final commands = bundle.commands;
    final objective = bundle.objective;
    final quizSlice = bundle.quizQuestions;

    final commandDone = _doneCommands
        .where((id) => commands.any((cmd) => cmd.id == id))
        .length;
    final quizDone = _doneQuiz
        .where((id) => quizSlice.any((q) => q.id == id))
        .length;

    final total =
        commands.length + (objective == null ? 0 : 1) + quizSlice.length;
    final completedCount =
        commandDone + (objective != null && _objectiveDone ? 1 : 0) + quizDone;
    final ratio = total == 0 ? 0.0 : completedCount / total;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Révision adaptative 10 min')),
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
                    'Session auto-personnalisée',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'La sélection se base sur tes erreurs quiz + commandes moins consultées.',
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
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      ChoiceChip(
                        label: const Text('Tous shells'),
                        selected: selectedShell == null,
                        onSelected: (_) {
                          ref.read(reviewShellFilterProvider.notifier).state =
                              null;
                          _resetSession();
                        },
                      ),
                      ...ShellType.values.map(
                        (shell) => ChoiceChip(
                          label: Text(shell.label),
                          selected: selectedShell == shell,
                          onSelected: (_) {
                            ref.read(reviewShellFilterProvider.notifier).state =
                                shell;
                            _resetSession();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      ChoiceChip(
                        label: const Text('Tous niveaux'),
                        selected: selectedDifficulty == null,
                        onSelected: (_) {
                          ref
                                  .read(reviewDifficultyFilterProvider.notifier)
                                  .state =
                              null;
                          _resetSession();
                        },
                      ),
                      ...DifficultyLevel.values.map(
                        (level) => ChoiceChip(
                          label: Text(level.label),
                          selected: selectedDifficulty == level,
                          onSelected: (_) {
                            ref
                                    .read(
                                      reviewDifficultyFilterProvider.notifier,
                                    )
                                    .state =
                                level;
                            _resetSession();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  FilterChip(
                    label: const Text('Prioriser mes points faibles'),
                    selected: focusWeak,
                    onSelected: (value) {
                      ref.read(reviewFocusWeakProvider.notifier).state = value;
                      _resetSession();
                    },
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
                    'Indicateurs adaptatifs',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Réponses quiz: ${quizInsights.totalAnswers} • Précision: ${(quizInsights.accuracyRate * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Erreurs cumulées: ${quizInsights.totalWrongAnswers}',
                    style: Theme.of(context).textTheme.bodyMedium,
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
                    '3 commandes recommandées',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (commands.isEmpty)
                    Text(
                      'Aucune commande ne correspond à ce filtre.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    ...commands.map(
                      (cmd) => CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _doneCommands.contains(cmd.id),
                        title: Text(cmd.name),
                        subtitle: Text(
                          '${cmd.shortDescription}\n${bundle.reasonsByCommandId[cmd.id] ?? 'Révision ciblée'}',
                        ),
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
                    'Objectif recommandé',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (objective == null)
                    Text(
                      'Aucun objectif disponible pour ce contexte.',
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
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        FilledButton.tonal(
                          onPressed: () {
                            ref.read(selectedIntentIdProvider.notifier).state =
                                objective.intentId;
                            context.go('/answers');
                          },
                          child: const Text('Ouvrir plan'),
                        ),
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
                    'Quiz ciblé (5 questions)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (quizSlice.isEmpty)
                    Text(
                      'Aucune question disponible pour ce contexte.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    ...quizSlice.map(
                      (q) => CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _doneQuiz.contains(q.id),
                        title: Text(q.question),
                        subtitle: Text(
                          'Niveau: ${q.difficulty.label} • erreurs passées: ${bundle.quizMistakesById[q.id] ?? 0}',
                        ),
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
                    onPressed: () {
                      final shell = selectedShell?.name;
                      if (shell == null) {
                        context.push('/quiz');
                      } else {
                        context.push('/quiz?shell=$shell');
                      }
                    },
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

  void _resetSession() {
    setState(() {
      _doneCommands.clear();
      _objectiveDone = false;
      _doneQuiz.clear();
    });
  }
}
