import '../../../core/utils/enums.dart';

class ShellInfo {
  const ShellInfo({
    required this.type,
    required this.title,
    required this.description,
  });

  final ShellType type;
  final String title;
  final String description;
}
