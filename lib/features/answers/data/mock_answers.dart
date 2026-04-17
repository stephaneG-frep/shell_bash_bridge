import '../../../core/utils/enums.dart';
import '../domain/answer_entry.dart';

const mockAnswers = <AnswerEntry>[
  AnswerEntry(
    id: 'a_pwd',
    question: 'Comment savoir dans quel dossier je suis ?',
    shortAnswer: 'Utilise `pwd` en Bash ou `Get-Location` en PowerShell.',
    steps: [
      'Ouvre ton terminal.',
      'Tape la commande adaptée au shell.',
      'Lis le chemin absolu affiché.',
    ],
    tags: ['dossier', 'chemin', 'where am i', 'pwd', 'get-location'],
    relatedCommandIds: ['bash_pwd', 'ps_get_location'],
  ),
  AnswerEntry(
    id: 'a_list_files',
    question: 'Comment lister les fichiers, y compris cachés ?',
    shortAnswer: 'Bash: `ls -la`, PowerShell: `Get-ChildItem -Force`.',
    steps: [
      'Positionne-toi dans le dossier voulu.',
      'Exécute `ls -la` ou `Get-ChildItem -Force`.',
      'Vérifie les permissions et tailles dans la sortie.',
    ],
    tags: ['liste', 'fichiers', 'cachés', 'ls', 'dir'],
    relatedCommandIds: ['bash_ls', 'ps_get_child_item'],
  ),
  AnswerEntry(
    id: 'a_change_dir',
    question: 'Comment changer de dossier proprement ?',
    shortAnswer: 'Utilise `cd` (Bash) ou `Set-Location` (PowerShell).',
    steps: [
      'Copie le chemin cible.',
      'Mets des guillemets si le chemin contient des espaces.',
      'Vérifie avec `pwd` ou `Get-Location`.',
    ],
    tags: ['cd', 'set-location', 'navigation', 'répertoire'],
    relatedCommandIds: [
      'bash_cd',
      'ps_set_location',
      'bash_pwd',
      'ps_get_location',
    ],
  ),
  AnswerEntry(
    id: 'a_create_file',
    question: 'Comment créer un fichier rapidement ?',
    shortAnswer: 'Bash: `touch`, PowerShell: `New-Item -ItemType File`.',
    steps: [
      'Choisis le nom du fichier.',
      'Crée le fichier avec la commande de ton shell.',
      'Vérifie qu’il existe avec `ls` ou `Get-ChildItem`.',
    ],
    tags: ['créer fichier', 'touch', 'new-item'],
    relatedCommandIds: ['bash_touch', 'ps_new_item'],
  ),
  AnswerEntry(
    id: 'a_copy_move',
    question: 'Quelle différence entre copier et déplacer ?',
    shortAnswer:
        'Copier garde l’original (`cp`/`Copy-Item`), déplacer le retire de la source (`mv`/`Move-Item`).',
    steps: [
      'Copie quand tu veux conserver la source.',
      'Déplace quand tu veux changer emplacement ou nom.',
      'Teste sur des fichiers non critiques au début.',
    ],
    tags: ['copier', 'déplacer', 'cp', 'mv', 'copy-item', 'move-item'],
    relatedCommandIds: ['bash_cp', 'bash_mv', 'ps_copy_item', 'ps_move_item'],
  ),
  AnswerEntry(
    id: 'a_delete_safe',
    question: 'Comment supprimer sans faire d’erreur ?',
    shortAnswer:
        'Vérifie toujours le chemin avant `rm`/`Remove-Item`, et simule quand possible.',
    steps: [
      'Confirme le dossier courant (`pwd` / `Get-Location`).',
      'Teste le chemin (`Test-Path` en PowerShell).',
      'Supprime ensuite la cible exacte.',
    ],
    tags: ['supprimer', 'rm', 'remove-item', 'sécurité'],
    relatedCommandIds: [
      'bash_rm',
      'ps_remove_item',
      'ps_test_path',
      'bash_pwd',
    ],
  ),
  AnswerEntry(
    id: 'a_find_text',
    question: 'Comment rechercher du texte dans des fichiers ?',
    shortAnswer: 'Bash: `grep`, PowerShell: `Select-String`.',
    steps: [
      'Définis un motif précis.',
      'Lance la commande sur le dossier ou fichier ciblé.',
      'Affiche le numéro de ligne quand c’est utile.',
    ],
    tags: ['recherche texte', 'grep', 'select-string', 'pattern'],
    relatedCommandIds: ['bash_grep', 'ps_select_string'],
  ),
  AnswerEntry(
    id: 'a_process',
    question: 'Comment voir les processus actifs ?',
    shortAnswer: 'Bash: `ps` / `top`, PowerShell: `Get-Process`.',
    steps: [
      'Affiche une liste instantanée avec `ps` ou `Get-Process`.',
      'Pour du temps réel, utilise `top` côté Bash.',
      'Trie ou filtre selon le nom du processus.',
    ],
    tags: ['processus', 'ps', 'top', 'get-process'],
    relatedCommandIds: ['bash_ps', 'bash_top', 'ps_get_process'],
  ),
  AnswerEntry(
    id: 'a_vars_ps',
    question: 'Comment gérer les variables en PowerShell ?',
    shortAnswer:
        'Utilise `Set-Variable` pour définir et `Get-Variable` pour lire.',
    steps: [
      'Crée la variable avec un nom clair.',
      'Lis-la avec `Get-Variable`.',
      'Distingue variable de session et variable d’environnement.',
    ],
    tags: ['variable', 'powershell', 'set-variable', 'get-variable'],
    relatedCommandIds: ['ps_set_variable', 'ps_get_variable'],
    shellType: ShellType.powershell,
  ),
  AnswerEntry(
    id: 'a_quiz_progress',
    question: 'Comment progresser vite avec l’app ?',
    shortAnswer:
        'Enchaîne: apprendre, tester, mettre en favori, refaire un quiz.',
    steps: [
      'Consulte 5 commandes débutant.',
      'Ajoute les plus utiles en favoris.',
      'Fais un quiz ciblé Bash ou PowerShell.',
      'Observe ta progression et tes badges.',
    ],
    tags: ['progression', 'quiz', 'favoris', 'apprendre'],
    relatedCommandIds: [
      'bash_pwd',
      'bash_ls',
      'ps_get_location',
      'ps_get_child_item',
    ],
  ),
];
