import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/enums.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../providers/app_providers.dart';
import '../domain/answer_intent.dart';
import '../domain/business_objective.dart';
import 'widgets/action_plan_card.dart';
import 'widgets/answer_card.dart';

class AnswersScreen extends ConsumerWidget {
  const AnswersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(answerQueryProvider);
    final answers = ref.watch(filteredAnswersProvider);
    final history = ref.watch(searchHistoryProvider);
    final intents = ref.watch(answerIntentPresetsProvider);
    final objectives = ref.watch(businessObjectivesProvider);
    final topAnswer = ref.watch(topAnswerProvider);
    final advisor = ref.watch(offlineAdvisorResponseProvider);
    final selectedIntentId = ref.watch(selectedIntentIdProvider);
    final selectedPlan = ref.watch(selectedActionPlanProvider);
    final selectedShell = ref.watch(selectedAnswerShellProvider);
    final selectedDifficulty = ref.watch(selectedAnswerDifficultyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Centre de réponses'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              onPressed: () => ref.read(searchHistoryProvider.notifier).clear(),
              icon: const Icon(Icons.history_toggle_off),
              tooltip: 'Effacer historique',
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            AppSearchBar(
              hintText:
                  'Pose une question: supprimer un fichier, rechercher texte...',
              onChanged: (value) {
                ref.read(answerQueryProvider.notifier).state = value;
                if (value.trim().isNotEmpty) {
                  ref.read(selectedIntentIdProvider.notifier).state = null;
                }
              },
              onSubmitted: (value) {
                ref.read(searchHistoryProvider.notifier).add(value);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contexte de réponse',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        ChoiceChip(
                          label: const Text('Tous shells'),
                          selected: selectedShell == null,
                          onSelected: (_) =>
                              ref
                                      .read(
                                        selectedAnswerShellProvider.notifier,
                                      )
                                      .state =
                                  null,
                        ),
                        ...ShellType.values.map(
                          (shell) => ChoiceChip(
                            label: Text(shell.label),
                            selected: selectedShell == shell,
                            onSelected: (_) =>
                                ref
                                        .read(
                                          selectedAnswerShellProvider.notifier,
                                        )
                                        .state =
                                    shell,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        ChoiceChip(
                          label: const Text('Tous niveaux'),
                          selected: selectedDifficulty == null,
                          onSelected: (_) =>
                              ref
                                      .read(
                                        selectedAnswerDifficultyProvider
                                            .notifier,
                                      )
                                      .state =
                                  null,
                        ),
                        ...DifficultyLevel.values.map(
                          (level) => ChoiceChip(
                            label: Text(level.label),
                            selected: selectedDifficulty == level,
                            onSelected: (_) =>
                                ref
                                        .read(
                                          selectedAnswerDifficultyProvider
                                              .notifier,
                                        )
                                        .state =
                                    level,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _AssistantOfflineCard(
              intents: intents,
              selectedIntentId: selectedIntentId,
              onSelectIntent: (intent) {
                ref.read(answerQueryProvider.notifier).state = intent.query;
                ref.read(searchHistoryProvider.notifier).add(intent.query);
                ref.read(selectedIntentIdProvider.notifier).state = intent.id;
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _BusinessObjectivesCard(
              objectives: objectives,
              onSelectObjective: (objective) {
                ref.read(selectedIntentIdProvider.notifier).state =
                    objective.intentId;
                ref.read(answerQueryProvider.notifier).state = objective.title
                    .toLowerCase();
                if (objective.shellType != null) {
                  ref.read(selectedAnswerShellProvider.notifier).state =
                      objective.shellType;
                }
                if (objective.targetDifficulty != null) {
                  ref.read(selectedAnswerDifficultyProvider.notifier).state =
                      objective.targetDifficulty;
                }
                ref
                    .read(searchHistoryProvider.notifier)
                    .add(objective.title.toLowerCase());
              },
            ),
            if (selectedPlan != null) ...[
              const SizedBox(height: AppSpacing.sm),
              ActionPlanCard(plan: selectedPlan),
            ],
            if (advisor != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        advisor.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        advisor.context,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        advisor.summary,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...advisor.steps.map(
                        (step) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: Text(
                            '• $step',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      if (advisor.commandIds.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: advisor.commandIds
                              .map(
                                (id) => ActionChip(
                                  label: Text(id.replaceAll('_', ' ')),
                                  onPressed: () => context.push('/command/$id'),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            if (query.trim().isNotEmpty && topAnswer != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Réponse instantanée',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        topAnswer.question,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        topAnswer.shortAnswer,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (topAnswer.relatedCommandIds.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            context.push(
                              '/command/${topAnswer.relatedCommandIds.first}',
                            );
                          },
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Ouvrir la meilleure commande'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            if (history.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: history
                    .map(
                      (h) => ActionChip(
                        label: Text(h),
                        onPressed: () {
                          ref.read(answerQueryProvider.notifier).state = h;
                          ref.read(selectedIntentIdProvider.notifier).state =
                              null;
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            if (answers.isEmpty)
              EmptyStateView(
                icon: Icons.help_outline,
                title: 'Pas encore de réponse',
                message: query.trim().isEmpty
                    ? 'Choisis une intention ou pose une question.'
                    : 'Essaie avec des mots-clés plus simples.',
              )
            else
              ...answers.map((entry) => AnswerCard(entry: entry)),
          ],
        ),
      ),
    );
  }
}

class _BusinessObjectivesCard extends StatelessWidget {
  const _BusinessObjectivesCard({
    required this.objectives,
    required this.onSelectObjective,
  });

  final List<BusinessObjective> objectives;
  final ValueChanged<BusinessObjective> onSelectObjective;

  @override
  Widget build(BuildContext context) {
    if (objectives.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Objectifs métier',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Choisis un cas concret et lance un plan prêt à exécuter.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            ...objectives.map(
              (objective) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  tileColor: Theme.of(context).colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  title: Text(objective.title),
                  subtitle: Text(objective.description),
                  trailing: const Icon(Icons.play_circle_outline),
                  onTap: () => onSelectObjective(objective),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssistantOfflineCard extends StatelessWidget {
  const _AssistantOfflineCard({
    required this.intents,
    required this.selectedIntentId,
    required this.onSelectIntent,
  });

  final List<AnswerIntent> intents;
  final String? selectedIntentId;
  final ValueChanged<AnswerIntent> onSelectIntent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assistant offline',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Choisis une intention et obtiens une réponse ciblée en un tap.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: intents
                  .map(
                    (intent) => ChoiceChip(
                      label: Text(intent.label),
                      selected: selectedIntentId == intent.id,
                      onSelected: (_) => onSelectIntent(intent),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
