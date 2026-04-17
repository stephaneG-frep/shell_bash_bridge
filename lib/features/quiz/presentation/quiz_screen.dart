import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/enums.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../providers/app_providers.dart';
import 'widgets/quiz_option_tile.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key, this.shellType});

  final ShellType? shellType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizSessionProvider(shellType));
    final notifier = ref.read(quizSessionProvider(shellType).notifier);
    final commandPool = ref.watch(allCommandsProvider);

    if (state.questions.isEmpty) {
      return const Scaffold(
        drawer: AppDrawer(),
        body: Center(child: Text('Aucune question disponible.')),
      );
    }

    if (state.isCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(userProgressProvider.notifier)
            .recordQuizResult(
              shellType: shellType,
              correct: state.score,
              total: state.questions.length,
            );
        context.go(
          '/quiz-result?score=${state.score}&total=${state.questions.length}',
        );
      });
    }

    final question = state.currentQuestion;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: Text('Quiz ${shellType?.label ?? 'Global'}')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${state.currentIndex + 1}/${state.questions.length}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              question.question,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, index) {
                  return QuizOptionTile(
                    label: question.options[index],
                    selected: state.selectedIndex == index,
                    correct: question.correctAnswerIndex == index,
                    showState: state.submitted,
                    onTap: () => notifier.selectOption(index),
                  );
                },
              ),
            ),
            if (state.submitted)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text(
                  question.explanation,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: state.submitted
                    ? notifier.nextQuestion
                    : (state.selectedIndex == null
                          ? null
                          : () async {
                              final question = state.currentQuestion;
                              final isCorrect =
                                  state.selectedIndex ==
                                  question.correctAnswerIndex;
                              await ref
                                  .read(quizInsightsProvider.notifier)
                                  .recordAnswer(
                                    question: question,
                                    isCorrect: isCorrect,
                                    commandPool: commandPool,
                                  );
                              notifier.submitAnswer();
                            }),
                child: Text(state.submitted ? 'Question suivante' : 'Valider'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
