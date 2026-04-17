import '../../../core/utils/enums.dart';

class AnswerEntry {
  const AnswerEntry({
    required this.id,
    required this.question,
    required this.shortAnswer,
    required this.steps,
    required this.tags,
    required this.relatedCommandIds,
    this.shellType,
    this.targetDifficulty,
  });

  final String id;
  final String question;
  final String shortAnswer;
  final List<String> steps;
  final List<String> tags;
  final List<String> relatedCommandIds;
  final ShellType? shellType;
  final DifficultyLevel? targetDifficulty;
}
