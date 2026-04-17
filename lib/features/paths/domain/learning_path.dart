import '../../../core/utils/enums.dart';

class LearningPath {
  const LearningPath({
    required this.id,
    required this.title,
    required this.goal,
    required this.description,
    required this.steps,
    required this.recommendedCommandIds,
    this.shellType,
  });

  final String id;
  final String title;
  final String goal;
  final String description;
  final List<String> steps;
  final List<String> recommendedCommandIds;
  final ShellType? shellType;
}
