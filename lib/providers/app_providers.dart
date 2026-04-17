import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_strings.dart';
import '../core/utils/enums.dart';
import '../features/categories/domain/command_category.dart';
import '../features/answers/data/mock_answers.dart';
import '../features/answers/domain/answer_entry.dart';
import '../features/commands/data/commands_repository.dart';
import '../features/commands/domain/command_item.dart';
import '../features/compare/data/mock_comparisons.dart';
import '../features/compare/domain/command_comparison.dart';
import '../features/paths/data/mock_learning_paths.dart';
import '../features/paths/domain/learning_path.dart';
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

final answerQueryProvider = StateProvider<String>((ref) => '');

final filteredAnswersProvider = Provider<List<AnswerEntry>>((ref) {
  final query = ref.watch(answerQueryProvider).trim().toLowerCase();
  final answers = ref.watch(answersProvider);
  if (query.isEmpty) return answers;

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
}

final commandNotesProvider =
    StateNotifierProvider<CommandNotesNotifier, Map<String, String>>((ref) {
      return CommandNotesNotifier();
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
}

final completedPathIdsProvider =
    StateNotifierProvider<CompletedPathsNotifier, Set<String>>((ref) {
      return CompletedPathsNotifier();
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
