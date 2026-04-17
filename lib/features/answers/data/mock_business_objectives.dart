import '../../../core/utils/enums.dart';
import '../domain/business_objective.dart';

const mockBusinessObjectives = <BusinessObjective>[
  BusinessObjective(
    id: 'obj_onboard_terminal',
    title: 'Onboard terminal débutant',
    description: 'Prendre en main navigation + listing en moins de 10 min.',
    intentId: 'intent_list_files',
    targetDifficulty: DifficultyLevel.beginner,
  ),
  BusinessObjective(
    id: 'obj_cleanup_logs_safe',
    title: 'Nettoyer des logs sans risque',
    description:
        'Identifier, vérifier et supprimer proprement les fichiers inutiles.',
    intentId: 'intent_safe_delete',
    targetDifficulty: DifficultyLevel.intermediate,
  ),
  BusinessObjective(
    id: 'obj_support_find_error',
    title: 'Trouver une erreur dans des logs',
    description: 'Rechercher un motif critique rapidement dans des fichiers.',
    intentId: 'intent_find_text',
    targetDifficulty: DifficultyLevel.intermediate,
  ),
  BusinessObjective(
    id: 'obj_ops_check_process',
    title: 'Contrôler un process applicatif',
    description: 'Inspecter l’état des processus avant intervention.',
    intentId: 'intent_view_processes',
    targetDifficulty: DifficultyLevel.intermediate,
  ),
  BusinessObjective(
    id: 'obj_file_delivery',
    title: 'Préparer une livraison fichier',
    description: 'Créer, copier puis déplacer un artefact sans perte.',
    intentId: 'intent_copy_move',
    targetDifficulty: DifficultyLevel.intermediate,
  ),
  BusinessObjective(
    id: 'obj_ps_admin_basics',
    title: 'Routine admin PowerShell',
    description: 'Variables et commandes de base pour tâches Windows.',
    intentId: 'intent_powershell_variables',
    shellType: ShellType.powershell,
    targetDifficulty: DifficultyLevel.advanced,
  ),
  BusinessObjective(
    id: 'obj_workspace_setup',
    title: 'Préparer un workspace dev',
    description: 'Créer structure de fichiers et vérifier le contexte.',
    intentId: 'intent_create_file',
    targetDifficulty: DifficultyLevel.beginner,
  ),
  BusinessObjective(
    id: 'obj_move_release',
    title: 'Déplacer une release',
    description: 'Copier puis déplacer des fichiers de build vers archive.',
    intentId: 'intent_copy_move',
    targetDifficulty: DifficultyLevel.intermediate,
  ),
];
