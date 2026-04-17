import '../domain/command_comparison.dart';

const baseMockComparisons = <CommandComparison>[
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

final mockComparisons = <CommandComparison>[
  ...baseMockComparisons,
  ..._extraComparisons,
];

final _extraComparisons = <CommandComparison>[
  _cmp(
    'cmp_find',
    'Trouver un fichier',
    'find . -name "*.log"',
    'Get-ChildItem -Recurse -Filter *.log',
  ),
  _cmp(
    'cmp_chmod',
    'Modifier permissions',
    'chmod +x script.sh',
    'Set-ExecutionPolicy (équivalent partiel)',
  ),
  _cmp('cmp_history', 'Voir historique commandes', 'history', 'Get-History'),
  _cmp(
    'cmp_help',
    'Afficher aide commande',
    'man grep',
    'Get-Help Select-String',
  ),
  _cmp(
    'cmp_head',
    'Voir début de fichier',
    'head -n 20 log.txt',
    'Get-Content log.txt -TotalCount 20',
  ),
  _cmp(
    'cmp_tail',
    'Voir fin de fichier',
    'tail -n 20 log.txt',
    'Get-Content log.txt -Tail 20',
  ),
  _cmp(
    'cmp_count',
    'Compter lignes',
    'wc -l file.txt',
    'Get-Content file.txt | Measure-Object -Line',
  ),
  _cmp(
    'cmp_sort',
    'Trier une liste',
    'sort names.txt',
    'Get-Content names.txt | Sort-Object',
  ),
  _cmp(
    'cmp_unique',
    'Supprimer doublons',
    'sort names.txt | uniq',
    'Get-Content names.txt | Sort-Object | Get-Unique',
  ),
  _cmp(
    'cmp_extract_col',
    'Extraire colonne',
    'cut -d: -f1 /etc/passwd',
    'Import-Csv data.csv | Select-Object -ExpandProperty Name',
  ),
  _cmp(
    'cmp_replace_text',
    'Remplacer du texte',
    "sed 's/foo/bar/g' file.txt",
    "(Get-Content file.txt) -replace 'foo','bar'",
  ),
  _cmp(
    'cmp_archive',
    'Créer archive',
    'tar -czf app.tgz app/',
    'Compress-Archive -Path app -DestinationPath app.zip',
  ),
  _cmp(
    'cmp_unarchive',
    'Extraire archive',
    'unzip app.zip',
    'Expand-Archive app.zip -DestinationPath out',
  ),
  _cmp(
    'cmp_download',
    'Télécharger un fichier',
    'wget https://site/file.zip',
    'Invoke-WebRequest https://site/file.zip -OutFile file.zip',
  ),
  _cmp(
    'cmp_api',
    'Appeler API',
    'curl https://api.example.com',
    'Invoke-RestMethod https://api.example.com',
  ),
  _cmp(
    'cmp_ping',
    'Tester connectivité',
    'ping -c 4 example.com',
    'Test-Connection example.com -Count 4',
  ),
  _cmp(
    'cmp_kill',
    'Arrêter processus',
    'kill -9 1234',
    'Stop-Process -Id 1234 -Force',
  ),
  _cmp('cmp_disk_free', 'Voir espace disque', 'df -h', 'Get-PSDrive'),
  _cmp(
    'cmp_disk_usage',
    'Voir taille dossier',
    'du -sh .',
    'Get-ChildItem . -Recurse | Measure-Object -Property Length -Sum',
  ),
  _cmp(
    'cmp_alias_set',
    'Créer alias',
    "alias ll='ls -la'",
    'Set-Alias ll Get-ChildItem',
  ),
  _cmp('cmp_alias_list', 'Lister alias', 'alias', 'Get-Alias'),
  _cmp('cmp_which', 'Trouver commande', 'which python', 'Get-Command python'),
  _cmp(
    'cmp_env_set',
    'Définir variable env',
    'export APP_ENV=dev',
    r'$env:APP_ENV="dev"',
  ),
  _cmp('cmp_env_list', 'Lister variables env', 'env', 'Get-ChildItem Env:'),
  _cmp('cmp_date', 'Afficher date/heure', 'date', 'Get-Date'),
  _cmp(
    'cmp_json_to',
    'Convertir vers JSON',
    'cat data | jq .',
    'Get-Process | ConvertTo-Json',
  ),
  _cmp(
    'cmp_json_from',
    'Lire JSON en objets',
    'cat data.json | jq .name',
    'Get-Content data.json | ConvertFrom-Json',
  ),
  _cmp(
    'cmp_write_file',
    'Écrire dans un fichier',
    'echo "ok" > out.txt',
    '"ok" | Out-File out.txt',
  ),
  _cmp(
    'cmp_session_log_start',
    'Démarrer log session',
    'script session.log',
    'Start-Transcript -Path .\\session.log',
  ),
  _cmp(
    'cmp_session_log_stop',
    'Arrêter log session',
    'exit (script)',
    'Stop-Transcript',
  ),
  _cmp(
    'cmp_services',
    'Lister services',
    'systemctl list-units --type=service',
    'Get-Service',
  ),
  _cmp('cmp_ip', 'Afficher adresses IP', 'ip addr', 'Get-NetIPAddress'),
  _cmp(
    'cmp_event_logs',
    'Lire logs système',
    'journalctl -n 20',
    'Get-EventLog -LogName System -Newest 20',
  ),
  _cmp(
    'cmp_props',
    'Voir propriétés fichier',
    'stat file.txt',
    'Get-ItemProperty .\\file.txt',
  ),
  _cmp(
    'cmp_random',
    'Générer nombre aléatoire',
    r'echo $RANDOM',
    'Get-Random -Maximum 32767',
  ),
];

CommandComparison _cmp(
  String id,
  String action,
  String bash,
  String powershell,
) {
  return CommandComparison(
    id: id,
    actionTitle: action,
    bashCommand: bash,
    powershellCommand: powershell,
    explanation: 'Même intention, syntaxe adaptée au shell.',
  );
}
