import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key, required this.score, required this.total});

  final int score;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0 : score / total;

    return Scaffold(
      appBar: AppBar(title: const Text('Résultat du quiz')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              ratio >= 0.7
                  ? Icons.emoji_events_outlined
                  : Icons.school_outlined,
              size: 72,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '$score / $total',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              ratio >= 0.7
                  ? 'Très bon score, continue comme ça.'
                  : 'Bon début, relance un quiz pour progresser.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.go('/progress'),
                child: const Text('Voir ma progression'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Retour à l’accueil'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
