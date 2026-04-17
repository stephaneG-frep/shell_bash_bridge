import '../domain/package_action.dart';

const mockServiceActions = <PackageAction>[
  PackageAction(
    id: 'svc_status',
    action: 'Vérifier le statut d’un service',
    description: 'Voir si un service est actif, inactif ou en échec.',
    commands: {
      'Systemd (Debian/Ubuntu/Fedora/openSUSE/Arch)':
          'sudo systemctl status <service>',
      'SysV (anciens systèmes)': 'sudo service <service> status',
    },
  ),
  PackageAction(
    id: 'svc_start',
    action: 'Démarrer un service',
    description: 'Démarre immédiatement un service.',
    commands: {
      'Systemd': 'sudo systemctl start <service>',
      'SysV': 'sudo service <service> start',
    },
  ),
  PackageAction(
    id: 'svc_stop',
    action: 'Arrêter un service',
    description: 'Stoppe immédiatement un service.',
    commands: {
      'Systemd': 'sudo systemctl stop <service>',
      'SysV': 'sudo service <service> stop',
    },
  ),
  PackageAction(
    id: 'svc_restart',
    action: 'Redémarrer un service',
    description: 'Relance le service (utile après modif de config).',
    commands: {
      'Systemd': 'sudo systemctl restart <service>',
      'SysV': 'sudo service <service> restart',
    },
  ),
  PackageAction(
    id: 'svc_reload',
    action: 'Recharger la configuration',
    description: 'Recharge la conf sans restart complet si supporté.',
    commands: {
      'Systemd': 'sudo systemctl reload <service>',
      'SysV': 'sudo service <service> reload',
    },
    tip: 'Tous les services ne supportent pas reload.',
  ),
  PackageAction(
    id: 'svc_enable',
    action: 'Activer au démarrage',
    description: 'Démarre automatiquement le service au boot.',
    commands: {
      'Systemd': 'sudo systemctl enable <service>',
      'SysV (Debian/Ubuntu)': 'sudo update-rc.d <service> defaults',
      'SysV (RHEL/CentOS)': 'sudo chkconfig <service> on',
    },
  ),
  PackageAction(
    id: 'svc_disable',
    action: 'Désactiver au démarrage',
    description: 'Empêche le démarrage auto du service.',
    commands: {
      'Systemd': 'sudo systemctl disable <service>',
      'SysV (Debian/Ubuntu)': 'sudo update-rc.d -f <service> remove',
      'SysV (RHEL/CentOS)': 'sudo chkconfig <service> off',
    },
  ),
  PackageAction(
    id: 'svc_list_running',
    action: 'Lister services en cours',
    description: 'Affiche les services actuellement actifs.',
    commands: {
      'Systemd': 'systemctl list-units --type=service --state=running',
      'SysV': 'service --status-all',
    },
  ),
  PackageAction(
    id: 'svc_failed',
    action: 'Lister services en échec',
    description: 'Repère rapidement les services qui ont planté.',
    commands: {
      'Systemd': 'systemctl --failed',
      'Alternative': 'journalctl -p err -b',
    },
  ),
  PackageAction(
    id: 'svc_logs',
    action: 'Voir logs d’un service',
    description: 'Consulter les logs liés au service ciblé.',
    commands: {
      'Journalctl': 'journalctl -u <service> -n 100',
      'Suivi temps réel': 'journalctl -u <service> -f',
      'Fichiers logs classiques': 'tail -f /var/log/<service>.log',
    },
  ),
  PackageAction(
    id: 'svc_boot_logs',
    action: 'Voir logs du dernier boot',
    description: 'Utile pour diagnostiquer un démarrage problématique.',
    commands: {
      'Journalctl': 'journalctl -b -p warning',
      'Kernel': 'journalctl -k -b',
    },
  ),
  PackageAction(
    id: 'svc_reload_daemon',
    action: 'Recharger les unités systemd',
    description: 'À faire après ajout/modif de fichier .service.',
    commands: {
      'Systemd': 'sudo systemctl daemon-reload',
      'Puis restart': 'sudo systemctl restart <service>',
    },
  ),
];
