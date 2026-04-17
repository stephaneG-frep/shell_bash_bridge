enum ShellType { bash, powershell }

enum DifficultyLevel { beginner, intermediate, advanced }

extension ShellTypeX on ShellType {
  String get label => this == ShellType.bash ? 'Bash' : 'PowerShell';
}

extension DifficultyLevelX on DifficultyLevel {
  String get label {
    switch (this) {
      case DifficultyLevel.beginner:
        return 'Débutant';
      case DifficultyLevel.intermediate:
        return 'Intermédiaire';
      case DifficultyLevel.advanced:
        return 'Avancé';
    }
  }
}
