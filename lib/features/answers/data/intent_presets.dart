import '../domain/answer_intent.dart';

const intentPresets = <AnswerIntent>[
  AnswerIntent(
    id: 'intent_list_files',
    label: 'Lister les fichiers',
    query: 'lister fichiers',
  ),
  AnswerIntent(
    id: 'intent_change_directory',
    label: 'Changer de dossier',
    query: 'changer dossier',
  ),
  AnswerIntent(
    id: 'intent_safe_delete',
    label: 'Supprimer sans risque',
    query: 'supprimer sans risque',
  ),
  AnswerIntent(
    id: 'intent_find_text',
    label: 'Rechercher du texte',
    query: 'rechercher texte',
  ),
  AnswerIntent(
    id: 'intent_view_processes',
    label: 'Voir les processus',
    query: 'voir processus',
  ),
  AnswerIntent(
    id: 'intent_create_file',
    label: 'Créer un fichier',
    query: 'créer fichier rapidement',
  ),
  AnswerIntent(
    id: 'intent_copy_move',
    label: 'Copier ou déplacer',
    query: 'différence copier déplacer',
  ),
  AnswerIntent(
    id: 'intent_powershell_variables',
    label: 'Variables PowerShell',
    query: 'gérer variables powershell',
  ),
];
