import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_strings.dart';
import '../core/utils/command_risk.dart';
import '../core/utils/enums.dart';
import '../features/categories/domain/command_category.dart';
import '../features/answers/data/mock_answers.dart';
import '../features/answers/data/intent_presets.dart';
import '../features/answers/data/action_plan_templates.dart';
import '../features/answers/data/mock_business_objectives.dart';
import '../features/answers/domain/action_plan.dart';
import '../features/answers/domain/answer_intent.dart';
import '../features/answers/domain/answer_entry.dart';
import '../features/answers/domain/business_objective.dart';
import '../features/commands/data/commands_repository.dart';
import '../features/commands/domain/command_item.dart';
import '../features/compare/data/mock_comparisons.dart';
import '../features/compare/domain/command_comparison.dart';
import '../features/paths/data/mock_learning_paths.dart';
import '../features/paths/domain/learning_path.dart';
import '../features/notes/domain/personal_snippet.dart';
import '../features/progress/domain/user_progress.dart';
import '../features/quiz/data/mock_quiz_questions.dart';
import '../features/quiz/domain/quiz_question.dart';

final commandsRepositoryProvider = Provider<CommandsRepository>((ref) {
  return const CommandsRepository();
});

final allCommandsProvider = Provider<List<CommandItem>>((ref) {
  return ref.watch(commandsRepositoryProvider).getAll();
});

final categoriesProvider = Provider<List<CommandCategory>>((ref) {
  return ref.watch(commandsRepositoryProvider).getCategories();
});

final commandByIdProvider = Provider.family<CommandItem?, String>((ref, id) {
  return ref.watch(commandsRepositoryProvider).getById(id);
});

final comparisonsProvider = Provider<List<CommandComparison>>((ref) {
  return mockComparisons;
});

final answersProvider = Provider<List<AnswerEntry>>((ref) {
  return mockAnswers;
});

final answerIntentPresetsProvider = Provider<List<AnswerIntent>>((ref) {
  return intentPresets;
});
final businessObjectivesProvider = Provider<List<BusinessObjective>>((ref) {
  final shell = ref.watch(selectedAnswerShellProvider);
  final difficulty = ref.watch(selectedAnswerDifficultyProvider);

  return mockBusinessObjectives.where((objective) {
    if (shell != null &&
        objective.shellType != null &&
        objective.shellType != shell) {
      return false;
    }
    if (difficulty != null &&
        objective.targetDifficulty != null &&
        objective.targetDifficulty != difficulty) {
      return false;
    }
    return true;
  }).toList();
});

final answerQueryProvider = StateProvider<String>((ref) => '');
final selectedIntentIdProvider = StateProvider<String?>((ref) => null);
final selectedAnswerShellProvider = StateProvider<ShellType?>((ref) => null);
final selectedAnswerDifficultyProvider = StateProvider<DifficultyLevel?>(
  (ref) => null,
);

final filteredAnswersProvider = Provider<List<AnswerEntry>>((ref) {
  final query = ref.watch(answerQueryProvider).trim().toLowerCase();
  final answers = ref.watch(answersProvider);
  final selectedShell = ref.watch(selectedAnswerShellProvider);
  final selectedDifficulty = ref.watch(selectedAnswerDifficultyProvider);
  if (query.isEmpty) {
    return answers.where((entry) {
      if (selectedShell != null &&
          entry.shellType != null &&
          entry.shellType != selectedShell) {
        return false;
      }
      if (selectedDifficulty != null &&
          entry.targetDifficulty != null &&
          entry.targetDifficulty != selectedDifficulty) {
        return false;
      }
      return true;
    }).toList();
  }

  final tokens = query
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty)
      .toList();
  int scoreFor(AnswerEntry entry) {
    var score = 0;
    final haystack = [
      entry.question.toLowerCase(),
      entry.shortAnswer.toLowerCase(),
      ...entry.tags.map((e) => e.toLowerCase()),
      ...entry.steps.map((e) => e.toLowerCase()),
    ].join(' ');

    for (final token in tokens) {
      if (haystack.contains(token)) {
        score += 2;
      }
      if (entry.question.toLowerCase().contains(token)) {
        score += 2;
      }
      if (entry.tags.any((tag) => tag.toLowerCase().contains(token))) {
        score += 3;
      }
    }

    if (selectedShell != null) {
      if (entry.shellType == selectedShell || entry.shellType == null) {
        score += 4;
      } else {
        score -= 3;
      }
    }

    if (selectedDifficulty != null) {
      if (entry.targetDifficulty == selectedDifficulty ||
          entry.targetDifficulty == null) {
        score += 3;
      } else {
        score -= 2;
      }
    }

    return score;
  }

  final ranked =
      answers
          .map((e) => (entry: e, score: scoreFor(e)))
          .where((item) => item.score > 0)
          .toList()
        ..sort((a, b) => b.score.compareTo(a.score));

  return ranked.map((item) => item.entry).toList();
});

final topAnswerProvider = Provider<AnswerEntry?>((ref) {
  final answers = ref.watch(filteredAnswersProvider);
  if (answers.isEmpty) {
    return null;
  }
  return answers.first;
});

class OfflineAdvisorResponse {
  const OfflineAdvisorResponse({
    required this.title,
    required this.context,
    required this.summary,
    required this.steps,
    required this.commandIds,
  });

  final String title;
  final String context;
  final String summary;
  final List<String> steps;
  final List<String> commandIds;
}

final offlineAdvisorResponseProvider = Provider<OfflineAdvisorResponse?>((ref) {
  final answer = ref.watch(topAnswerProvider);
  final plan = ref.watch(selectedActionPlanProvider);
  final shell = ref.watch(selectedAnswerShellProvider);
  final difficulty = ref.watch(selectedAnswerDifficultyProvider);
  if (answer == null) {
    return null;
  }

  final contextParts = <String>[
    shell?.label ?? 'Tous shells',
    difficulty?.label ?? 'Tous niveaux',
  ];

  final mergedSteps = <String>[
    ...answer.steps,
    if (difficulty == DifficultyLevel.beginner)
      'Commence par exécuter la version la plus simple de la commande.',
    if (difficulty == DifficultyLevel.advanced)
      'Ajoute des options avancées seulement après validation du résultat.',
    if (plan != null) ...plan.steps.take(2),
  ];

  final mergedCommands = <String>{
    ...answer.relatedCommandIds,
    if (plan != null) ...plan.commandIds,
  }.toList();

  return OfflineAdvisorResponse(
    title: 'Réponse ciblée',
    context: contextParts.join(' • '),
    summary: answer.shortAnswer,
    steps: mergedSteps.take(6).toList(),
    commandIds: mergedCommands.take(6).toList(),
  );
});

class GuidedAnswerResponse {
  const GuidedAnswerResponse({
    required this.confidence,
    required this.confidenceLabel,
    required this.riskLevel,
    required this.riskLabel,
    required this.riskMessage,
    required this.checklist,
    required this.alternatives,
    required this.keyCommandIds,
  });

  final double confidence;
  final String confidenceLabel;
  final CommandRiskLevel riskLevel;
  final String riskLabel;
  final String riskMessage;
  final List<String> checklist;
  final List<AnswerEntry> alternatives;
  final List<String> keyCommandIds;
}

final guidedAnswerResponseProvider = Provider<GuidedAnswerResponse?>((ref) {
  final top = ref.watch(topAnswerProvider);
  final filtered = ref.watch(filteredAnswersProvider);
  final query = ref.watch(answerQueryProvider).trim().toLowerCase();
  final selectedShell = ref.watch(selectedAnswerShellProvider);
  final selectedDifficulty = ref.watch(selectedAnswerDifficultyProvider);
  final commands = ref.watch(allCommandsProvider);
  final commandById = <String, CommandItem>{for (final c in commands) c.id: c};

  if (top == null) {
    return null;
  }

  final risks = top.relatedCommandIds
      .map((id) => commandById[id])
      .whereType<CommandItem>()
      .map((cmd) => assessCommandRisk(name: cmd.name, syntax: cmd.syntax))
      .toList();

  CommandRisk worstRisk = const CommandRisk(
    level: CommandRiskLevel.low,
    label: 'Risque faible',
    message: 'Commande généralement sûre pour la pratique.',
  );
  for (final risk in risks) {
    if (risk.level.index > worstRisk.level.index) {
      worstRisk = risk;
    }
  }

  final tokens = query
      .split(RegExp(r'\s+'))
      .where((token) => token.trim().isNotEmpty)
      .toList();
  var confidence = 0.45;
  var tokenMatches = 0;
  for (final token in tokens) {
    final inQuestion = top.question.toLowerCase().contains(token);
    final inTags = top.tags.any((tag) => tag.toLowerCase().contains(token));
    final inSteps = top.steps.any((step) => step.toLowerCase().contains(token));
    if (inQuestion || inTags || inSteps) {
      tokenMatches += 1;
    }
  }

  confidence += (tokenMatches.clamp(0, 3)) * 0.12;
  if (selectedShell == null ||
      top.shellType == null ||
      top.shellType == selectedShell) {
    confidence += 0.08;
  }
  if (selectedDifficulty == null ||
      top.targetDifficulty == null ||
      top.targetDifficulty == selectedDifficulty) {
    confidence += 0.08;
  }
  confidence = confidence.clamp(0.35, 0.95);

  final confidenceLabel = switch (confidence) {
    >= 0.8 => 'Confiance élevée',
    >= 0.6 => 'Confiance moyenne',
    _ => 'Confiance faible',
  };

  final checklist = <String>[
    'Valide le shell actif avant exécution (${selectedShell?.label ?? 'auto-détection'}).',
    if (worstRisk.level != CommandRiskLevel.low)
      'Teste la commande sur un cas non critique avant usage réel.',
    if (worstRisk.level == CommandRiskLevel.high)
      'Prépare une sauvegarde ou un rollback avant action.',
    'Relis la syntaxe exacte et adapte le chemin à ton contexte.',
  ];

  return GuidedAnswerResponse(
    confidence: confidence,
    confidenceLabel: confidenceLabel,
    riskLevel: worstRisk.level,
    riskLabel: worstRisk.label,
    riskMessage: worstRisk.message,
    checklist: checklist,
    alternatives: filtered.skip(1).take(2).toList(),
    keyCommandIds: top.relatedCommandIds.take(4).toList(),
  );
});

final actionPlansProvider = Provider<List<ActionPlan>>((ref) {
  return actionPlanTemplates;
});

final selectedActionPlanProvider = Provider<ActionPlan?>((ref) {
  final selectedIntentId = ref.watch(selectedIntentIdProvider);
  if (selectedIntentId == null) {
    return null;
  }
  final plans = ref.watch(actionPlansProvider);
  for (final plan in plans) {
    if (plan.intentId == selectedIntentId) {
      return plan;
    }
  }
  return null;
});

class ActionPlanProgressNotifier
    extends StateNotifier<Map<String, List<bool>>> {
  ActionPlanProgressNotifier() : super(const {}) {
    _load();
  }

  static const _storageKey = 'action_plan_progress_v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return;
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final parsed = <String, List<bool>>{};
    decoded.forEach((key, value) {
      parsed[key] = List<bool>.from((value as List).map((e) => e == true));
    });
    state = parsed;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(state));
  }

  List<bool> _ensureLength(List<bool>? source, int totalSteps) {
    final base = List<bool>.from(source ?? const <bool>[]);
    if (base.length < totalSteps) {
      base.addAll(List<bool>.filled(totalSteps - base.length, false));
    }
    if (base.length > totalSteps) {
      return base.take(totalSteps).toList();
    }
    return base;
  }

  Future<void> toggleStep(String planId, int totalSteps, int index) async {
    final checks = _ensureLength(state[planId], totalSteps);
    if (index < 0 || index >= checks.length) {
      return;
    }
    checks[index] = !checks[index];
    state = {...state, planId: checks};
    await _save();
  }

  Future<void> resetPlan(String planId, int totalSteps) async {
    state = {...state, planId: List<bool>.filled(totalSteps, false)};
    await _save();
  }

  Future<void> setAll(Map<String, List<bool>> values) async {
    state = values;
    await _save();
  }
}

final actionPlanProgressProvider =
    StateNotifierProvider<ActionPlanProgressNotifier, Map<String, List<bool>>>((
      ref,
    ) {
      return ActionPlanProgressNotifier();
    });

final quizQuestionsProvider = Provider.family<List<QuizQuestion>, ShellType?>((
  ref,
  shell,
) {
  if (shell == null) return mockQuizQuestions;
  return mockQuizQuestions
      .where((q) => q.shellType == null || q.shellType == shell)
      .toList();
});

class CommandFilterState {
  const CommandFilterState({
    this.query = '',
    this.categoryId,
    this.difficulty,
    this.onlyFavorites = false,
    this.shellType,
  });

  final String query;
  final String? categoryId;
  final DifficultyLevel? difficulty;
  final bool onlyFavorites;
  final ShellType? shellType;

  CommandFilterState copyWith({
    String? query,
    String? categoryId,
    bool clearCategory = false,
    DifficultyLevel? difficulty,
    bool clearDifficulty = false,
    bool? onlyFavorites,
    ShellType? shellType,
    bool clearShell = false,
  }) {
    return CommandFilterState(
      query: query ?? this.query,
      categoryId: clearCategory ? null : categoryId ?? this.categoryId,
      difficulty: clearDifficulty ? null : difficulty ?? this.difficulty,
      onlyFavorites: onlyFavorites ?? this.onlyFavorites,
      shellType: clearShell ? null : shellType ?? this.shellType,
    );
  }
}

class CommandFilterNotifier extends StateNotifier<CommandFilterState> {
  CommandFilterNotifier() : super(const CommandFilterState());

  void setQuery(String value) => state = state.copyWith(query: value);

  void setCategory(String? value) {
    if (value == null) {
      state = state.copyWith(clearCategory: true);
      return;
    }
    state = state.copyWith(categoryId: value);
  }

  void setDifficulty(DifficultyLevel? value) {
    if (value == null) {
      state = state.copyWith(clearDifficulty: true);
      return;
    }
    state = state.copyWith(difficulty: value);
  }

  void setOnlyFavorites(bool value) =>
      state = state.copyWith(onlyFavorites: value);

  void setShell(ShellType? value) {
    if (value == null) {
      state = state.copyWith(clearShell: true);
      return;
    }
    state = state.copyWith(shellType: value);
  }

  void reset(ShellType? shellType) {
    state = CommandFilterState(shellType: shellType);
  }
}

final commandFilterProvider =
    StateNotifierProvider<CommandFilterNotifier, CommandFilterState>((ref) {
      return CommandFilterNotifier();
    });

class UserProgressNotifier extends StateNotifier<UserProgress> {
  UserProgressNotifier() : super(UserProgress.initial()) {
    _load();
  }

  static const _storageKey = 'user_progress_v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    state = UserProgress.fromMap(map);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(state.toMap()));
  }

  Future<void> toggleFavorite(String commandId) async {
    final current = [...state.favoriteCommandIds];
    if (current.contains(commandId)) {
      current.remove(commandId);
    } else {
      current.add(commandId);
    }
    state = state.copyWith(favoriteCommandIds: current);
    await _save();
  }

  Future<void> markCommandViewed(
    String commandId,
    ShellType shellType,
    int totalInShell,
  ) async {
    final viewed = [...state.viewedCommandIds];
    if (!viewed.contains(commandId)) {
      viewed.add(commandId);
    }

    final viewedBash = viewed.where((id) => id.startsWith('bash_')).length;
    final viewedPs = viewed.where((id) => id.startsWith('ps_')).length;

    state = state.copyWith(
      viewedCommandIds: viewed,
      bashProgress: totalInShell == 0 && shellType == ShellType.bash
          ? state.bashProgress
          : (shellType == ShellType.bash
                ? (viewedBash / totalInShell).clamp(0, 1)
                : state.bashProgress),
      powershellProgress: totalInShell == 0 && shellType == ShellType.powershell
          ? state.powershellProgress
          : (shellType == ShellType.powershell
                ? (viewedPs / totalInShell).clamp(0, 1)
                : state.powershellProgress),
    );

    _recomputeBadges();
    await _save();
  }

  Future<void> recordQuizResult({
    required ShellType? shellType,
    required int correct,
    required int total,
  }) async {
    final completed = state.completedQuizCount + 1;
    final correctCount = state.correctAnswersCount + correct;
    final answeredCount = state.totalAnsweredCount + total;

    state = state.copyWith(
      completedQuizCount: completed,
      correctAnswersCount: correctCount,
      totalAnsweredCount: answeredCount,
      learningStreak: state.learningStreak + 1,
    );

    _recomputeBadges();
    await _save();
  }

  Future<void> importProgress(UserProgress progress) async {
    state = progress;
    await _save();
  }

  void _recomputeBadges() {
    final badges = <String>{...state.earnedBadges};

    if (state.viewedCommandIds.length >= 5) {
      badges.add('Explorateur débutant');
    }
    if (state.completedQuizCount >= 1) {
      badges.add('Premier quiz terminé');
    }
    if (state.averageScore >= 0.8 && state.totalAnsweredCount >= 5) {
      badges.add('Score 80%+');
    }
    if (state.learningStreak >= 5) {
      badges.add('Série x5');
    }

    state = state.copyWith(earnedBadges: badges.toList());
  }
}

final userProgressProvider =
    StateNotifierProvider<UserProgressNotifier, UserProgress>((ref) {
      return UserProgressNotifier();
    });

final favoriteCommandsProvider = Provider<List<CommandItem>>((ref) {
  final favorites = ref.watch(userProgressProvider).favoriteCommandIds.toSet();
  return ref
      .watch(allCommandsProvider)
      .where((cmd) => favorites.contains(cmd.id))
      .toList();
});

final filteredCommandsProvider = Provider<List<CommandItem>>((ref) {
  final commands = ref.watch(allCommandsProvider);
  final filter = ref.watch(commandFilterProvider);
  final favorites = ref.watch(userProgressProvider).favoriteCommandIds.toSet();

  return commands.where((cmd) {
    if (filter.shellType != null && cmd.shellType != filter.shellType) {
      return false;
    }
    if (filter.categoryId != null && cmd.categoryId != filter.categoryId) {
      return false;
    }
    if (filter.difficulty != null && cmd.difficulty != filter.difficulty) {
      return false;
    }
    if (filter.onlyFavorites && !favorites.contains(cmd.id)) return false;

    if (filter.query.trim().isNotEmpty) {
      final q = filter.query.trim().toLowerCase();
      final searchable = '${cmd.name} ${cmd.shortDescription} ${cmd.syntax}'
          .toLowerCase();
      return searchable.contains(q);
    }

    return true;
  }).toList();
});

final recommendedCommandsProvider = Provider<List<CommandItem>>((ref) {
  return ref
      .watch(allCommandsProvider)
      .where((cmd) => cmd.difficulty == DifficultyLevel.beginner)
      .take(6)
      .toList();
});

final tipOfDayProvider = Provider<String>((ref) {
  final tips = AppStrings.dailyTips;
  final dayIndex = DateTime.now().difference(DateTime(2026, 1, 1)).inDays;
  return tips[dayIndex % tips.length];
});

final reviewShellFilterProvider = StateProvider<ShellType?>((ref) => null);
final reviewDifficultyFilterProvider = StateProvider<DifficultyLevel?>(
  (ref) => null,
);
final reviewFocusWeakProvider = StateProvider<bool>((ref) => true);

class AdaptiveReviewBundle {
  const AdaptiveReviewBundle({
    required this.commands,
    required this.reasonsByCommandId,
    required this.quizQuestions,
    required this.quizMistakesById,
    required this.objective,
  });

  final List<CommandItem> commands;
  final Map<String, String> reasonsByCommandId;
  final List<QuizQuestion> quizQuestions;
  final Map<String, int> quizMistakesById;
  final BusinessObjective? objective;
}

final adaptiveReviewBundleProvider = Provider<AdaptiveReviewBundle>((ref) {
  final shell = ref.watch(reviewShellFilterProvider);
  final difficulty = ref.watch(reviewDifficultyFilterProvider);
  final focusWeak = ref.watch(reviewFocusWeakProvider);
  final allCommands = ref.watch(allCommandsProvider);
  final progress = ref.watch(userProgressProvider);
  final quizInsights = ref.watch(quizInsightsProvider);
  final quizPool = ref.watch(quizQuestionsProvider(shell));

  bool commandMatches(CommandItem cmd) {
    if (shell != null && cmd.shellType != shell) {
      return false;
    }
    if (difficulty != null && cmd.difficulty != difficulty) {
      return false;
    }
    return true;
  }

  final filteredCommands = allCommands.where(commandMatches).toList();
  final reasons = <String, String>{};
  final selected = <CommandItem>[];

  final weakCommandEntries = quizInsights.wrongCommandCount.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  void addByIdIfPossible(String commandId, String reason) {
    if (selected.length >= 3) {
      return;
    }
    final existing = selected.any((item) => item.id == commandId);
    if (existing) {
      return;
    }
    CommandItem? cmd;
    for (final item in filteredCommands) {
      if (item.id == commandId) {
        cmd = item;
        break;
      }
    }
    if (cmd == null) {
      return;
    }
    selected.add(cmd);
    reasons[cmd.id] = reason;
  }

  if (focusWeak) {
    for (final entry in weakCommandEntries) {
      addByIdIfPossible(
        entry.key,
        'Point faible détecté (${entry.value} erreur(s) quiz)',
      );
    }
  }

  for (final cmd in filteredCommands) {
    if (selected.length >= 3) {
      break;
    }
    if (!progress.viewedCommandIds.contains(cmd.id)) {
      addByIdIfPossible(cmd.id, 'Commande encore peu consultée');
    }
  }

  for (final cmd in filteredCommands) {
    if (selected.length >= 3) {
      break;
    }
    if (cmd.difficulty == DifficultyLevel.beginner) {
      addByIdIfPossible(cmd.id, 'Renforcement des fondamentaux');
    }
  }

  for (final cmd in filteredCommands) {
    if (selected.length >= 3) {
      break;
    }
    addByIdIfPossible(cmd.id, 'Révision complémentaire');
  }

  final quizMistakesById = <String, int>{...quizInsights.wrongQuestionCount};
  final prioritizedQuiz =
      quizPool
          .where((q) => difficulty == null || q.difficulty == difficulty)
          .toList()
        ..sort((a, b) {
          final wa = quizMistakesById[a.id] ?? 0;
          final wb = quizMistakesById[b.id] ?? 0;
          if (wa != wb) {
            return wb.compareTo(wa);
          }
          return a.id.compareTo(b.id);
        });
  final quizSlice = prioritizedQuiz.take(5).toList();

  final matchingObjectives = mockBusinessObjectives.where((item) {
    if (shell != null && item.shellType != null && item.shellType != shell) {
      return false;
    }
    if (difficulty != null &&
        item.targetDifficulty != null &&
        item.targetDifficulty != difficulty) {
      return false;
    }
    return true;
  }).toList();
  final objective = matchingObjectives.isEmpty
      ? null
      : matchingObjectives.first;

  return AdaptiveReviewBundle(
    commands: selected,
    reasonsByCommandId: reasons,
    quizQuestions: quizSlice,
    quizMistakesById: quizMistakesById,
    objective: objective,
  );
});

final learningPathsProvider = Provider<List<LearningPath>>((ref) {
  return mockLearningPaths;
});

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  SearchHistoryNotifier() : super(const []) {
    _load();
  }

  static const _storageKey = 'search_history_v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList(_storageKey) ?? const [];
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, state);
  }

  Future<void> add(String query) async {
    final normalized = query.trim();
    if (normalized.length < 3) {
      return;
    }
    final next = [
      normalized,
      ...state.where((item) => item.toLowerCase() != normalized.toLowerCase()),
    ].take(10).toList();
    state = next;
    await _save();
  }

  Future<void> clear() async {
    state = const [];
    await _save();
  }

  Future<void> setAll(List<String> values) async {
    state = values.take(20).toList();
    await _save();
  }
}

final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
      return SearchHistoryNotifier();
    });

class CommandNotesNotifier extends StateNotifier<Map<String, String>> {
  CommandNotesNotifier() : super(const {}) {
    _load();
  }

  static const _storageKey = 'command_notes_v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return;
    }
    final map = jsonDecode(raw) as Map<String, dynamic>;
    state = map.map((key, value) => MapEntry(key, value.toString()));
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(state));
  }

  Future<void> saveNote(String commandId, String note) async {
    final trimmed = note.trim();
    final next = {...state};
    if (trimmed.isEmpty) {
      next.remove(commandId);
    } else {
      next[commandId] = trimmed;
    }
    state = next;
    await _save();
  }

  Future<void> setAll(Map<String, String> values) async {
    state = values;
    await _save();
  }
}

final commandNotesProvider =
    StateNotifierProvider<CommandNotesNotifier, Map<String, String>>((ref) {
      return CommandNotesNotifier();
    });

class SafeCommandModeNotifier extends StateNotifier<bool> {
  SafeCommandModeNotifier() : super(true) {
    _load();
  }

  static const _storageKey = 'safe_command_mode_v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_storageKey) ?? true;
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_storageKey, enabled);
  }
}

final safeCommandModeProvider =
    StateNotifierProvider<SafeCommandModeNotifier, bool>((ref) {
      return SafeCommandModeNotifier();
    });

const _defaultFavoriteCollections = <String>[
  'Urgence prod',
  'Routine dev',
  'Maintenance Linux',
];

class FavoriteCollectionsNotifier
    extends StateNotifier<Map<String, List<String>>> {
  FavoriteCollectionsNotifier() : super(const {}) {
    _load();
  }

  static const _storageKey = 'favorite_collections_v1';

  Map<String, List<String>> _ensureDefaults(Map<String, List<String>> source) {
    final next = <String, List<String>>{};
    for (final name in _defaultFavoriteCollections) {
      next[name] = List<String>.from(source[name] ?? const <String>[]);
    }
    source.forEach((key, value) {
      if (!next.containsKey(key)) {
        next[key] = List<String>.from(value);
      }
    });
    return next;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      state = _ensureDefaults(const {});
      return;
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final mapped = <String, List<String>>{};
    decoded.forEach((key, value) {
      mapped[key] = List<String>.from(value as List? ?? const []);
    });
    state = _ensureDefaults(mapped);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(state));
  }

  Future<void> addCollection(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || state.containsKey(trimmed)) {
      return;
    }
    state = {...state, trimmed: const <String>[]};
    await _save();
  }

  Future<void> toggleCommand(String collectionName, String commandId) async {
    final next = {...state};
    final list = List<String>.from(next[collectionName] ?? const <String>[]);
    if (list.contains(commandId)) {
      list.remove(commandId);
    } else {
      list.add(commandId);
    }
    next[collectionName] = list;
    state = next;
    await _save();
  }
}

final favoriteCollectionsProvider =
    StateNotifierProvider<
      FavoriteCollectionsNotifier,
      Map<String, List<String>>
    >((ref) {
      return FavoriteCollectionsNotifier();
    });

class CompletedPathsNotifier extends StateNotifier<Set<String>> {
  CompletedPathsNotifier() : super(<String>{}) {
    _load();
  }

  static const _storageKey = 'completed_paths_v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = {...(prefs.getStringList(_storageKey) ?? const <String>[])};
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, state.toList());
  }

  Future<void> toggle(String pathId) async {
    final next = {...state};
    if (next.contains(pathId)) {
      next.remove(pathId);
    } else {
      next.add(pathId);
    }
    state = next;
    await _save();
  }

  Future<void> setAll(Set<String> values) async {
    state = values;
    await _save();
  }
}

final completedPathIdsProvider =
    StateNotifierProvider<CompletedPathsNotifier, Set<String>>((ref) {
      return CompletedPathsNotifier();
    });

class GlobalNotesNotifier extends StateNotifier<String> {
  GlobalNotesNotifier() : super('') {
    _load();
  }

  static const _storageKey = 'global_notes_v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_storageKey) ?? '';
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, state);
  }

  Future<void> setNotes(String notes) async {
    state = notes;
    await _save();
  }
}

final globalNotesProvider = StateNotifierProvider<GlobalNotesNotifier, String>((
  ref,
) {
  return GlobalNotesNotifier();
});

class DailyCommandIdsNotifier extends StateNotifier<List<String>> {
  DailyCommandIdsNotifier() : super(const []) {
    _load();
  }

  static const _storageKey = 'daily_command_ids_v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList(_storageKey) ?? const [];
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, state);
  }

  Future<void> toggle(String commandId) async {
    final next = [...state];
    if (next.contains(commandId)) {
      next.remove(commandId);
    } else {
      next.add(commandId);
    }
    state = next;
    await _save();
  }

  Future<void> setAll(List<String> ids) async {
    state = ids;
    await _save();
  }
}

final dailyCommandIdsProvider =
    StateNotifierProvider<DailyCommandIdsNotifier, List<String>>((ref) {
      return DailyCommandIdsNotifier();
    });

final dailyCommandsProvider = Provider<List<CommandItem>>((ref) {
  final all = ref.watch(allCommandsProvider);
  final ids = ref.watch(dailyCommandIdsProvider).toSet();
  return all.where((cmd) => ids.contains(cmd.id)).toList();
});

class PersonalSnippetsNotifier extends StateNotifier<List<PersonalSnippet>> {
  PersonalSnippetsNotifier() : super(const []) {
    _load();
  }

  static const _storageKey = 'personal_snippets_v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return;
    }
    final data = jsonDecode(raw) as List<dynamic>;
    state = data
        .map((item) => PersonalSnippet.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(state.map((e) => e.toMap()).toList()),
    );
  }

  Future<void> upsert(PersonalSnippet snippet) async {
    final next = [...state];
    final index = next.indexWhere((s) => s.id == snippet.id);
    if (index == -1) {
      next.add(snippet);
    } else {
      next[index] = snippet;
    }
    state = next;
    await _save();
  }

  Future<void> remove(String id) async {
    state = state.where((s) => s.id != id).toList();
    await _save();
  }

  Future<void> setAll(List<PersonalSnippet> snippets) async {
    state = snippets;
    await _save();
  }
}

final personalSnippetsProvider =
    StateNotifierProvider<PersonalSnippetsNotifier, List<PersonalSnippet>>((
      ref,
    ) {
      return PersonalSnippetsNotifier();
    });

class AppBackupService {
  const AppBackupService(this.ref);

  final Ref ref;

  String exportJson() {
    final payload = <String, dynamic>{
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'userProgress': ref.read(userProgressProvider).toMap(),
      'searchHistory': ref.read(searchHistoryProvider),
      'commandNotes': ref.read(commandNotesProvider),
      'completedPathIds': ref.read(completedPathIdsProvider).toList(),
      'actionPlanProgress': ref.read(actionPlanProgressProvider),
      'globalNotes': ref.read(globalNotesProvider),
      'dailyCommandIds': ref.read(dailyCommandIdsProvider),
      'personalSnippets': ref
          .read(personalSnippetsProvider)
          .map((s) => s.toMap())
          .toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<bool> importJson(String raw) async {
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final progress = UserProgress.fromMap(
        data['userProgress'] as Map<String, dynamic>? ?? {},
      );

      await ref.read(userProgressProvider.notifier).importProgress(progress);
      await ref
          .read(searchHistoryProvider.notifier)
          .setAll(List<String>.from(data['searchHistory'] as List? ?? []));
      await ref
          .read(commandNotesProvider.notifier)
          .setAll(Map<String, String>.from(data['commandNotes'] as Map? ?? {}));
      await ref
          .read(completedPathIdsProvider.notifier)
          .setAll(
            Set<String>.from(data['completedPathIds'] as List? ?? const []),
          );

      final actionMapRaw = Map<String, dynamic>.from(
        data['actionPlanProgress'] as Map? ?? const {},
      );
      final actionMap = <String, List<bool>>{};
      actionMapRaw.forEach((key, value) {
        actionMap[key] = List<bool>.from((value as List).map((e) => e == true));
      });
      await ref.read(actionPlanProgressProvider.notifier).setAll(actionMap);

      await ref
          .read(globalNotesProvider.notifier)
          .setNotes(data['globalNotes']?.toString() ?? '');
      await ref
          .read(dailyCommandIdsProvider.notifier)
          .setAll(List<String>.from(data['dailyCommandIds'] as List? ?? []));

      final snippetData = data['personalSnippets'] as List? ?? const [];
      await ref
          .read(personalSnippetsProvider.notifier)
          .setAll(
            snippetData
                .map(
                  (e) => PersonalSnippet.fromMap(
                    Map<String, dynamic>.from(e as Map),
                  ),
                )
                .toList(),
          );
      return true;
    } catch (_) {
      return false;
    }
  }
}

final appBackupServiceProvider = Provider<AppBackupService>((ref) {
  return AppBackupService(ref);
});

class QuizInsightsState {
  const QuizInsightsState({
    this.wrongQuestionCount = const {},
    this.wrongCommandCount = const {},
    this.totalWrongAnswers = 0,
    this.totalCorrectAnswers = 0,
  });

  final Map<String, int> wrongQuestionCount;
  final Map<String, int> wrongCommandCount;
  final int totalWrongAnswers;
  final int totalCorrectAnswers;

  int get totalAnswers => totalWrongAnswers + totalCorrectAnswers;

  double get accuracyRate =>
      totalAnswers == 0 ? 0 : totalCorrectAnswers / totalAnswers;

  Map<String, dynamic> toMap() {
    return {
      'wrongQuestionCount': wrongQuestionCount,
      'wrongCommandCount': wrongCommandCount,
      'totalWrongAnswers': totalWrongAnswers,
      'totalCorrectAnswers': totalCorrectAnswers,
    };
  }

  factory QuizInsightsState.fromMap(Map<String, dynamic> map) {
    return QuizInsightsState(
      wrongQuestionCount: Map<String, int>.from(
        map['wrongQuestionCount'] as Map? ?? const {},
      ),
      wrongCommandCount: Map<String, int>.from(
        map['wrongCommandCount'] as Map? ?? const {},
      ),
      totalWrongAnswers: map['totalWrongAnswers'] is int
          ? map['totalWrongAnswers'] as int
          : 0,
      totalCorrectAnswers: map['totalCorrectAnswers'] is int
          ? map['totalCorrectAnswers'] as int
          : 0,
    );
  }

  QuizInsightsState copyWith({
    Map<String, int>? wrongQuestionCount,
    Map<String, int>? wrongCommandCount,
    int? totalWrongAnswers,
    int? totalCorrectAnswers,
  }) {
    return QuizInsightsState(
      wrongQuestionCount: wrongQuestionCount ?? this.wrongQuestionCount,
      wrongCommandCount: wrongCommandCount ?? this.wrongCommandCount,
      totalWrongAnswers: totalWrongAnswers ?? this.totalWrongAnswers,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
    );
  }
}

class QuizInsightsNotifier extends StateNotifier<QuizInsightsState> {
  QuizInsightsNotifier() : super(const QuizInsightsState()) {
    _load();
  }

  static const _storageKey = 'quiz_insights_v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return;
    }
    state = QuizInsightsState.fromMap(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(state.toMap()));
  }

  Future<void> recordAnswer({
    required QuizQuestion question,
    required bool isCorrect,
    required List<CommandItem> commandPool,
  }) async {
    if (isCorrect) {
      state = state.copyWith(
        totalCorrectAnswers: state.totalCorrectAnswers + 1,
      );
      await _save();
      return;
    }

    final wrongQuestions = <String, int>{...state.wrongQuestionCount};
    wrongQuestions[question.id] = (wrongQuestions[question.id] ?? 0) + 1;

    final wrongCommands = <String, int>{...state.wrongCommandCount};
    final related = _inferRelatedCommandIds(question, commandPool);
    for (final commandId in related) {
      wrongCommands[commandId] = (wrongCommands[commandId] ?? 0) + 1;
    }

    state = state.copyWith(
      wrongQuestionCount: wrongQuestions,
      wrongCommandCount: wrongCommands,
      totalWrongAnswers: state.totalWrongAnswers + 1,
    );
    await _save();
  }

  Future<void> reset() async {
    state = const QuizInsightsState();
    await _save();
  }

  List<String> _inferRelatedCommandIds(
    QuizQuestion question,
    List<CommandItem> commandPool,
  ) {
    final text = [
      question.question,
      question.explanation,
      ...question.options,
    ].join(' ').toLowerCase();

    final matches = <String>[];
    for (final command in commandPool) {
      final commandName = command.name.toLowerCase();
      final pattern = RegExp('\\b${RegExp.escape(commandName)}\\b');
      if (pattern.hasMatch(text)) {
        matches.add(command.id);
      }
    }

    if (matches.isNotEmpty) {
      return matches.take(3).toList();
    }

    return commandPool
        .where((cmd) {
          if (question.shellType != null &&
              cmd.shellType != question.shellType) {
            return false;
          }
          return cmd.difficulty == question.difficulty;
        })
        .take(2)
        .map((cmd) => cmd.id)
        .toList();
  }
}

final quizInsightsProvider =
    StateNotifierProvider<QuizInsightsNotifier, QuizInsightsState>((ref) {
      return QuizInsightsNotifier();
    });

class QuizSession {
  const QuizSession({
    required this.questions,
    this.currentIndex = 0,
    this.selectedIndex,
    this.submitted = false,
    this.score = 0,
  });

  final List<QuizQuestion> questions;
  final int currentIndex;
  final int? selectedIndex;
  final bool submitted;
  final int score;

  bool get isCompleted => currentIndex >= questions.length;

  QuizQuestion get currentQuestion => questions[currentIndex];

  QuizSession copyWith({
    List<QuizQuestion>? questions,
    int? currentIndex,
    int? selectedIndex,
    bool clearSelected = false,
    bool? submitted,
    int? score,
  }) {
    return QuizSession(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedIndex: clearSelected ? null : selectedIndex ?? this.selectedIndex,
      submitted: submitted ?? this.submitted,
      score: score ?? this.score,
    );
  }
}

class QuizSessionNotifier extends StateNotifier<QuizSession> {
  QuizSessionNotifier(List<QuizQuestion> questions)
    : super(QuizSession(questions: questions));

  void selectOption(int index) {
    if (state.submitted) return;
    state = state.copyWith(selectedIndex: index);
  }

  void submitAnswer() {
    if (state.selectedIndex == null || state.submitted || state.isCompleted) {
      return;
    }
    final isCorrect =
        state.selectedIndex == state.currentQuestion.correctAnswerIndex;

    state = state.copyWith(
      submitted: true,
      score: state.score + (isCorrect ? 1 : 0),
    );
  }

  void nextQuestion() {
    if (!state.submitted) return;

    final nextIndex = state.currentIndex + 1;
    if (nextIndex >= state.questions.length) {
      state = state.copyWith(
        currentIndex: nextIndex,
        clearSelected: true,
        submitted: false,
      );
      return;
    }

    state = state.copyWith(
      currentIndex: nextIndex,
      clearSelected: true,
      submitted: false,
    );
  }

  void restart(List<QuizQuestion> questions) {
    state = QuizSession(questions: questions);
  }
}

final quizSessionProvider =
    StateNotifierProvider.family<QuizSessionNotifier, QuizSession, ShellType?>((
      ref,
      shell,
    ) {
      final questions = ref.watch(quizQuestionsProvider(shell));
      return QuizSessionNotifier(questions);
    });
