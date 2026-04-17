import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../providers/app_providers.dart';
import 'widgets/comparison_card.dart';

class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({super.key});

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final comparisons = ref.watch(comparisonsProvider).where((item) {
      if (_query.trim().isEmpty) return true;
      final q = _query.trim().toLowerCase();
      final data = '${item.actionTitle} ${item.bashCommand} ${item.powershellCommand}'.toLowerCase();
      return data.contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Compare Bash ↔ PowerShell')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
            child: AppSearchBar(
              hintText: 'Rechercher une action...',
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: comparisons.isEmpty
                ? const EmptyStateView(
                    icon: Icons.compare_arrows,
                    title: 'Aucune correspondance',
                    message: 'Essaie un autre mot-clé.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: comparisons.length,
                    itemBuilder: (context, index) => ComparisonCard(item: comparisons[index]),
                  ),
          ),
        ],
      ),
    );
  }
}
