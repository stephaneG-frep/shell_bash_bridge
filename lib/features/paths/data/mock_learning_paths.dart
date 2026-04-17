import '../../../core/utils/enums.dart';
import '../domain/learning_path.dart';

const mockLearningPaths = <LearningPath>[
  LearningPath(
    id: 'lp_first_terminal_session',
    title: 'Première session terminal',
    goal: 'Se repérer et manipuler des fichiers de base',
    description: 'Parcours idéal pour débuter en 15 minutes.',
    steps: [
      'Vérifier le dossier courant',
      'Lister les fichiers',
      'Changer de dossier',
      'Créer un fichier test',
      'Lire son contenu',
    ],
    recommendedCommandIds: [
      'bash_pwd',
      'bash_ls',
      'bash_cd',
      'bash_touch',
      'bash_cat',
    ],
    shellType: ShellType.bash,
  ),
  LearningPath(
    id: 'lp_safe_file_cleanup',
    title: 'Nettoyage sécurisé',
    goal: 'Supprimer sans risque',
    description: 'Méthode pour éviter les erreurs de suppression.',
    steps: [
      'Vérifier le chemin courant',
      'Tester l’existence du chemin cible',
      'Lister avant suppression',
      'Supprimer la cible exacte',
    ],
    recommendedCommandIds: [
      'bash_pwd',
      'ps_test_path',
      'bash_ls',
      'bash_rm',
      'ps_remove_item',
    ],
  ),
  LearningPath(
    id: 'lp_find_debug_info',
    title: 'Trouver une info vite',
    goal: 'Chercher texte et processus rapidement',
    description: 'Très utile pour debug ou support système.',
    steps: [
      'Rechercher un motif dans les logs',
      'Lister les processus',
      'Isoler le processus concerné',
    ],
    recommendedCommandIds: [
      'bash_grep',
      'ps_select_string',
      'bash_ps',
      'ps_get_process',
    ],
  ),
  LearningPath(
    id: 'lp_powershell_basics',
    title: 'PowerShell express',
    goal: 'Prendre en main les cmdlets essentielles',
    description: 'Pack de base pour utilisateurs Windows.',
    steps: [
      'Voir la position courante',
      'Lister les éléments',
      'Créer un dossier',
      'Copier et déplacer un fichier',
    ],
    recommendedCommandIds: [
      'ps_get_location',
      'ps_get_child_item',
      'ps_new_item',
      'ps_copy_item',
      'ps_move_item',
    ],
    shellType: ShellType.powershell,
  ),
];
