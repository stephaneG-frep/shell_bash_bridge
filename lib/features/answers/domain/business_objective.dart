import '../../../core/utils/enums.dart';

class BusinessObjective {
  const BusinessObjective({
    required this.id,
    required this.title,
    required this.description,
    required this.intentId,
    this.shellType,
    this.targetDifficulty,
  });

  final String id;
  final String title;
  final String description;
  final String intentId;
  final ShellType? shellType;
  final DifficultyLevel? targetDifficulty;
}
