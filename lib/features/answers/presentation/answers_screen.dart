import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../providers/app_providers.dart';
import 'widgets/answer_card.dart';

class AnswersScreen extends ConsumerWidget {
  const AnswersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(answerQueryProvider);
    final answers = ref.watch(filteredAnswersProvider);
    final history = ref.watch(searchHistoryProvider);

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: AppSearchBar(
              hintText:
                  'Pose une question: supprimer un fichier, rechercher texte...',
              onChanged: (value) =>
                  ref.read(answerQueryProvider.notifier).state = value,
              onSubmitted: (value) {
                ref.read(searchHistoryProvider.notifier).add(value);
              },
            ),
          ),
          if (history.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: history
                    .map(
                      (h) => ActionChip(
                        label: Text(h),
                        onPressed: () =>
                            ref.read(answerQueryProvider.notifier).state = h,
                      ),
                    )
                    .toList(),
              ),
            ),
          if (history.isNotEmpty) const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children:
                  [
                        'lister fichiers',
                        'changer dossier',
                        'supprimer sans risque',
                        'rechercher texte',
                        'voir processus',
                      ]
                      .map(
                        (s) => ActionChip(
                          label: Text(s),
                          onPressed: () =>
                              ref.read(answerQueryProvider.notifier).state = s,
                        ),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: answers.isEmpty
                ? EmptyStateView(
                    icon: Icons.help_outline,
                    title: 'Pas encore de réponse',
                    message: query.trim().isEmpty
                        ? 'Pose une question pour obtenir un guide pas à pas.'
                        : 'Essaie avec des mots-clés plus simples.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: answers.length,
                    itemBuilder: (context, index) =>
                        AnswerCard(entry: answers[index]),
                  ),
          ),
        ],
      ),
    );
  }
}
