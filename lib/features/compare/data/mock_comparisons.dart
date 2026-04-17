import '../domain/command_comparison.dart';

const mockComparisons = <CommandComparison>[
  CommandComparison(
    id: 'cmp_pwd',
    actionTitle: 'Afficher le dossier courant',
    bashCommand: 'pwd',
    powershellCommand: 'Get-Location',
    explanation: 'Les deux montrent le chemin de travail actuel.',
  ),
  CommandComparison(
    id: 'cmp_ls',
    actionTitle: 'Lister les fichiers',
    bashCommand: 'ls -la',
    powershellCommand: 'Get-ChildItem -Force',
    explanation: 'Même objectif: voir le contenu avec plus de détails.',
  ),
  CommandComparison(
    id: 'cmp_cd',
    actionTitle: 'Changer de dossier',
    bashCommand: 'cd ~/Documents',
    powershellCommand: 'Set-Location C:\\Users\\User\\Documents',
    explanation: 'Navigue dans l’arborescence.',
  ),
  CommandComparison(
    id: 'cmp_cp',
    actionTitle: 'Copier un fichier',
    bashCommand: 'cp file.txt backup/file.txt',
    powershellCommand: 'Copy-Item file.txt backup\\file.txt',
    explanation: 'Duplique un fichier vers une destination.',
  ),
  CommandComparison(
    id: 'cmp_mv',
    actionTitle: 'Déplacer un fichier',
    bashCommand: 'mv file.txt archive/file.txt',
    powershellCommand: 'Move-Item file.txt archive\\file.txt',
    explanation: 'Déplace ou renomme selon la destination.',
  ),
  CommandComparison(
    id: 'cmp_rm',
    actionTitle: 'Supprimer un fichier',
    bashCommand: 'rm file.txt',
    powershellCommand: 'Remove-Item file.txt',
    explanation: 'Supprime des éléments du système de fichiers.',
  ),
  CommandComparison(
    id: 'cmp_cat',
    actionTitle: 'Lire un fichier',
    bashCommand: 'cat README.md',
    powershellCommand: 'Get-Content README.md',
    explanation: 'Affiche le contenu d’un fichier texte.',
  ),
  CommandComparison(
    id: 'cmp_grep',
    actionTitle: 'Rechercher un texte',
    bashCommand: 'grep "TODO" src/*',
    powershellCommand: 'Select-String -Path src\\* -Pattern "TODO"',
    explanation: 'Trouve un motif dans un ou plusieurs fichiers.',
  ),
  CommandComparison(
    id: 'cmp_ps',
    actionTitle: 'Afficher les processus',
    bashCommand: 'ps aux',
    powershellCommand: 'Get-Process',
    explanation: 'Liste les processus actifs.',
  ),
  CommandComparison(
    id: 'cmp_create_file',
    actionTitle: 'Créer un fichier',
    bashCommand: 'touch notes.txt',
    powershellCommand: 'New-Item -ItemType File -Name notes.txt',
    explanation: 'Crée un nouveau fichier vide.',
  ),
];
