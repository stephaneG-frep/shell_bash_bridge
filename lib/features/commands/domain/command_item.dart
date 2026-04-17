import '../../../core/utils/enums.dart';

class CommandItem {
  const CommandItem({
    required this.id,
    required this.name,
    required this.shellType,
    required this.categoryId,
    required this.syntax,
    required this.shortDescription,
    required this.fullDescription,
    required this.example,
    required this.difficulty,
    required this.equivalentCommandName,
    required this.commonMistakes,
    required this.tips,
  });

  final String id;
  final String name;
  final ShellType shellType;
  final String categoryId;
  final String syntax;
  final String shortDescription;
  final String fullDescription;
  final String example;
  final DifficultyLevel difficulty;
  final String equivalentCommandName;
  final List<String> commonMistakes;
  final List<String> tips;
}
