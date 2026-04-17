import '../../../core/utils/enums.dart';
import '../../commands/data/mock_commands.dart';
import '../../compare/data/mock_comparisons.dart';
import '../domain/quiz_question.dart';

const baseMockQuizQuestions = <QuizQuestion>[
  QuizQuestion(
    id: 'q1',
    shellType: ShellType.bash,
    question: 'Quelle commande Bash affiche le dossier courant ?',
    options: ['ls', 'pwd', 'cd', 'cat'],
    correctAnswerIndex: 1,
    explanation: '`pwd` affiche le chemin absolu du dossier actif.',
    difficulty: DifficultyLevel.beginner,
  ),
  QuizQuestion(
    id: 'q2',
    shellType: ShellType.powershell,
    question: 'Quel équivalent PowerShell de `ls` liste les fichiers ?',
    options: ['Get-Process', 'Get-Location', 'Get-ChildItem', 'Select-String'],
    correctAnswerIndex: 2,
    explanation: '`Get-ChildItem` est la commande de listing.',
    difficulty: DifficultyLevel.beginner,
  ),
  QuizQuestion(
    id: 'q3',
    shellType: null,
    question: 'Quelle paire est correcte pour supprimer un fichier ?',
    options: [
      'rm ↔ Remove-Item',
      'touch ↔ Get-Content',
      'grep ↔ Get-Location',
      'chmod ↔ Set-Location',
    ],
    correctAnswerIndex: 0,
    explanation: '`rm` et `Remove-Item` servent à supprimer.',
    difficulty: DifficultyLevel.beginner,
  ),
  QuizQuestion(
    id: 'q4',
    shellType: ShellType.bash,
    question: 'Quelle option copier un dossier avec `cp` ?',
    options: ['-f', '-r', '-a', '-d'],
    correctAnswerIndex: 1,
    explanation: '`-r` active la copie récursive des dossiers.',
    difficulty: DifficultyLevel.intermediate,
  ),
  QuizQuestion(
    id: 'q5',
    shellType: ShellType.powershell,
    question: 'Quelle commande recherche un motif texte en PowerShell ?',
    options: ['Get-Content', 'Set-Variable', 'Select-String', 'Clear-Host'],
    correctAnswerIndex: 2,
    explanation: '`Select-String` est l’équivalent de `grep`.',
    difficulty: DifficultyLevel.intermediate,
  ),
  QuizQuestion(
    id: 'q6',
    shellType: ShellType.bash,
    question: 'Que fait `chmod +x script.sh` ?',
    options: [
      'Supprime script.sh',
      'Ajoute le droit d’exécution',
      'Copie script.sh',
      'Affiche script.sh',
    ],
    correctAnswerIndex: 1,
    explanation: 'La commande rend le script exécutable.',
    difficulty: DifficultyLevel.intermediate,
  ),
  QuizQuestion(
    id: 'q7',
    shellType: ShellType.powershell,
    question: 'Quelle commande vérifie si un chemin existe ?',
    options: ['Test-Path', 'Get-Variable', 'Set-Location', 'Write-Output'],
    correctAnswerIndex: 0,
    explanation: '`Test-Path` retourne true/false.',
    difficulty: DifficultyLevel.beginner,
  ),
  QuizQuestion(
    id: 'q8',
    shellType: null,
    question: 'Quelle commande est la plus risquée sans vérification ?',
    options: ['pwd', 'rm -rf', 'echo', 'Get-Location'],
    correctAnswerIndex: 1,
    explanation: '`rm -rf` peut supprimer des dossiers entiers.',
    difficulty: DifficultyLevel.intermediate,
  ),
  QuizQuestion(
    id: 'q9',
    shellType: ShellType.bash,
    question: 'Quel usage de `grep` est correct ?',
    options: [
      'grep TODO src/',
      'grep "TODO" -R src/',
      'grep --move TODO',
      'grep /etc/passwd > ls',
    ],
    correctAnswerIndex: 1,
    explanation: 'La version avec motif + récursif est correcte.',
    difficulty: DifficultyLevel.intermediate,
  ),
  QuizQuestion(
    id: 'q10',
    shellType: ShellType.powershell,
    question: 'Quel alias courant lance `Set-Location` ?',
    options: ['mv', 'pwd', 'cd', 'ls'],
    correctAnswerIndex: 2,
    explanation: '`cd` est un alias de `Set-Location`.',
    difficulty: DifficultyLevel.beginner,
  ),
  QuizQuestion(
    id: 'q11',
    shellType: null,
    question: 'Que signifie une difficulté "Débutant" ?',
    options: [
      'Commande avancée admin',
      'Commande utile pour démarrer',
      'Commande obsolète',
      'Commande réservée à Linux',
    ],
    correctAnswerIndex: 1,
    explanation: 'Ces commandes sont faites pour l’apprentissage initial.',
    difficulty: DifficultyLevel.beginner,
  ),
  QuizQuestion(
    id: 'q12',
    shellType: ShellType.powershell,
    question: 'Quelle commande affiche les processus ?',
    options: ['Get-Process', 'Clear-Host', 'Get-Content', 'Copy-Item'],
    correctAnswerIndex: 0,
    explanation: '`Get-Process` liste les processus système.',
    difficulty: DifficultyLevel.beginner,
  ),
  QuizQuestion(
    id: 'q13',
    shellType: ShellType.bash,
    question: 'Quelle commande crée un fichier vide ?',
    options: ['mkdir', 'touch', 'cat', 'ps'],
    correctAnswerIndex: 1,
    explanation: '`touch` crée un fichier s’il n’existe pas.',
    difficulty: DifficultyLevel.beginner,
  ),
  QuizQuestion(
    id: 'q14',
    shellType: null,
    question: 'Quelle paire correspond à la copie ?',
    options: [
      'mv ↔ Move-Item',
      'cp ↔ Copy-Item',
      'rm ↔ Get-Content',
      'cat ↔ Remove-Item',
    ],
    correctAnswerIndex: 1,
    explanation: '`cp` et `Copy-Item` servent à copier.',
    difficulty: DifficultyLevel.beginner,
  ),
  QuizQuestion(
    id: 'q15',
    shellType: null,
    question: 'Bonne pratique avant suppression massive ?',
    options: [
      'Utiliser -WhatIf ou vérifier le chemin',
      'Toujours lancer en root/admin',
      'Éviter les sauvegardes',
      'Nettoyer l’écran avant',
    ],
    correctAnswerIndex: 0,
    explanation: 'Simulation et vérification réduisent le risque.',
    difficulty: DifficultyLevel.advanced,
  ),
];

final mockQuizQuestions = <QuizQuestion>[
  ...baseMockQuizQuestions,
  ..._buildComparisonQuizQuestions(30),
  ..._buildShellDetectionQuizQuestions(25),
];

List<QuizQuestion> _buildComparisonQuizQuestions(int count) {
  final data = mockComparisons.take(count).toList();
  final pool = mockComparisons
      .map((item) => item.powershellCommand)
      .toSet()
      .toList();

  return data.asMap().entries.map((entry) {
    final i = entry.key;
    final item = entry.value;
    final correct = item.powershellCommand;
    final wrongs = <String>[];

    var cursor = (i * 5 + 3) % pool.length;
    while (wrongs.length < 3) {
      final candidate = pool[cursor];
      if (candidate != correct && !wrongs.contains(candidate)) {
        wrongs.add(candidate);
      }
      cursor = (cursor + 7) % pool.length;
    }

    final options = <String>[correct, ...wrongs];
    final shift = i % options.length;
    final rotated = [...options.sublist(shift), ...options.sublist(0, shift)];
    final correctIndex = rotated.indexOf(correct);

    return QuizQuestion(
      id: 'q_auto_cmp_${i + 1}',
      shellType: null,
      question:
          'Quel équivalent PowerShell correspond à `${item.bashCommand}` ?',
      options: rotated,
      correctAnswerIndex: correctIndex,
      explanation:
          'Pour l’action "${item.actionTitle}", la bonne commande est `${item.powershellCommand}`.',
      difficulty: _difficultyFromIndex(i),
    );
  }).toList();
}

List<QuizQuestion> _buildShellDetectionQuizQuestions(int count) {
  final candidates = mockCommands
      .where((cmd) => cmd.name.length > 2)
      .take(count)
      .toList();

  const options = ['Bash', 'PowerShell', 'Les deux', 'Aucun'];

  return candidates.asMap().entries.map((entry) {
    final i = entry.key;
    final cmd = entry.value;

    final correctLabel = cmd.shellType == ShellType.bash
        ? 'Bash'
        : 'PowerShell';
    final correctIndex = options.indexOf(correctLabel);

    return QuizQuestion(
      id: 'q_auto_shell_${i + 1}',
      shellType: cmd.shellType,
      question:
          'Dans quel shell la commande `${cmd.name}` est-elle principalement utilisée ?',
      options: options,
      correctAnswerIndex: correctIndex,
      explanation: '`${cmd.name}` est une commande de ${cmd.shellType.label}.',
      difficulty: _difficultyFromIndex(i + 30),
    );
  }).toList();
}

DifficultyLevel _difficultyFromIndex(int i) {
  if (i % 3 == 0) return DifficultyLevel.beginner;
  if (i % 3 == 1) return DifficultyLevel.intermediate;
  return DifficultyLevel.advanced;
}
