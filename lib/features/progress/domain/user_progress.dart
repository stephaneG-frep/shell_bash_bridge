class UserProgress {
  const UserProgress({
    required this.viewedCommandIds,
    required this.favoriteCommandIds,
    required this.completedQuizCount,
    required this.correctAnswersCount,
    required this.totalAnsweredCount,
    required this.bashProgress,
    required this.powershellProgress,
    required this.earnedBadges,
    required this.learningStreak,
  });

  final List<String> viewedCommandIds;
  final List<String> favoriteCommandIds;
  final int completedQuizCount;
  final int correctAnswersCount;
  final int totalAnsweredCount;
  final double bashProgress;
  final double powershellProgress;
  final List<String> earnedBadges;
  final int learningStreak;

  factory UserProgress.initial() {
    return const UserProgress(
      viewedCommandIds: [],
      favoriteCommandIds: [],
      completedQuizCount: 0,
      correctAnswersCount: 0,
      totalAnsweredCount: 0,
      bashProgress: 0,
      powershellProgress: 0,
      earnedBadges: [],
      learningStreak: 1,
    );
  }

  double get averageScore {
    if (totalAnsweredCount == 0) return 0;
    return correctAnswersCount / totalAnsweredCount;
  }

  UserProgress copyWith({
    List<String>? viewedCommandIds,
    List<String>? favoriteCommandIds,
    int? completedQuizCount,
    int? correctAnswersCount,
    int? totalAnsweredCount,
    double? bashProgress,
    double? powershellProgress,
    List<String>? earnedBadges,
    int? learningStreak,
  }) {
    return UserProgress(
      viewedCommandIds: viewedCommandIds ?? this.viewedCommandIds,
      favoriteCommandIds: favoriteCommandIds ?? this.favoriteCommandIds,
      completedQuizCount: completedQuizCount ?? this.completedQuizCount,
      correctAnswersCount: correctAnswersCount ?? this.correctAnswersCount,
      totalAnsweredCount: totalAnsweredCount ?? this.totalAnsweredCount,
      bashProgress: bashProgress ?? this.bashProgress,
      powershellProgress: powershellProgress ?? this.powershellProgress,
      earnedBadges: earnedBadges ?? this.earnedBadges,
      learningStreak: learningStreak ?? this.learningStreak,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'viewedCommandIds': viewedCommandIds,
      'favoriteCommandIds': favoriteCommandIds,
      'completedQuizCount': completedQuizCount,
      'correctAnswersCount': correctAnswersCount,
      'totalAnsweredCount': totalAnsweredCount,
      'bashProgress': bashProgress,
      'powershellProgress': powershellProgress,
      'earnedBadges': earnedBadges,
      'learningStreak': learningStreak,
    };
  }

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      viewedCommandIds: List<String>.from(
        map['viewedCommandIds'] as List? ?? [],
      ),
      favoriteCommandIds: List<String>.from(
        map['favoriteCommandIds'] as List? ?? [],
      ),
      completedQuizCount: (map['completedQuizCount'] as num? ?? 0).toInt(),
      correctAnswersCount: (map['correctAnswersCount'] as num? ?? 0).toInt(),
      totalAnsweredCount: (map['totalAnsweredCount'] as num? ?? 0).toInt(),
      bashProgress: (map['bashProgress'] as num? ?? 0).toDouble(),
      powershellProgress: (map['powershellProgress'] as num? ?? 0).toDouble(),
      earnedBadges: List<String>.from(map['earnedBadges'] as List? ?? []),
      learningStreak: (map['learningStreak'] as num? ?? 1).toInt(),
    );
  }
}
