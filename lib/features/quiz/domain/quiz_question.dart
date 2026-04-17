import '../../../core/utils/enums.dart';

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.shellType,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.difficulty,
  });

  final String id;
  final ShellType? shellType;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final DifficultyLevel difficulty;
}
