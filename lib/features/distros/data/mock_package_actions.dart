import '../domain/package_action.dart';

const mockPackageActions = <PackageAction>[
  PackageAction(
    id: 'update_index',
    action: 'Mettre à jour l’index des paquets',
    description: 'Récupère la dernière liste de paquets disponibles.',
    commands: {
      'APT (Debian/Ubuntu)': 'sudo apt update',
      'Pacman (Arch)': 'sudo pacman -Sy',
      'DNF (Fedora/RHEL)': 'sudo dnf check-update',
      'Zypper (openSUSE)': 'sudo zypper refresh',
    },
  ),
  PackageAction(
    id: 'upgrade_all',
    action: 'Mettre à jour tous les paquets',
    description: 'Applique les mises à jour système disponibles.',
    commands: {
      'APT (Debian/Ubuntu)': 'sudo apt upgrade -y',
      'Pacman (Arch)': 'sudo pacman -Syu',
      'DNF (Fedora/RHEL)': 'sudo dnf upgrade -y',
      'Zypper (openSUSE)': 'sudo zypper update -y',
    },
    tip: 'Sur Arch, `-Syu` est la séquence standard complète.',
  ),
  PackageAction(
    id: 'install_package',
    action: 'Installer un paquet',
    description: 'Installe un logiciel depuis les dépôts.',
    commands: {
      'APT (Debian/Ubuntu)': 'sudo apt install <paquet>',
      'Pacman (Arch)': 'sudo pacman -S <paquet>',
      'DNF (Fedora/RHEL)': 'sudo dnf install <paquet>',
      'Zypper (openSUSE)': 'sudo zypper install <paquet>',
    },
  ),
  PackageAction(
    id: 'remove_package',
    action: 'Supprimer un paquet',
    description: 'Désinstalle un logiciel.',
    commands: {
      'APT (Debian/Ubuntu)': 'sudo apt remove <paquet>',
      'Pacman (Arch)': 'sudo pacman -R <paquet>',
      'DNF (Fedora/RHEL)': 'sudo dnf remove <paquet>',
      'Zypper (openSUSE)': 'sudo zypper remove <paquet>',
    },
  ),
  PackageAction(
    id: 'remove_with_deps',
    action: 'Supprimer paquet + dépendances inutiles',
    description: 'Nettoie plus en profondeur les paquets orphelins.',
    commands: {
      'APT (Debian/Ubuntu)': 'sudo apt autoremove -y',
      'Pacman (Arch)': 'sudo pacman -Rns <paquet>',
      'DNF (Fedora/RHEL)': 'sudo dnf autoremove -y',
      'Zypper (openSUSE)': 'sudo zypper remove --clean-deps <paquet>',
    },
  ),
  PackageAction(
    id: 'search_package',
    action: 'Rechercher un paquet',
    description: 'Trouve un paquet par nom ou mot-clé.',
    commands: {
      'APT (Debian/Ubuntu)': 'apt search <mot-cle>',
      'Pacman (Arch)': 'pacman -Ss <mot-cle>',
      'DNF (Fedora/RHEL)': 'dnf search <mot-cle>',
      'Zypper (openSUSE)': 'zypper search <mot-cle>',
    },
  ),
  PackageAction(
    id: 'show_info',
    action: 'Afficher infos d’un paquet',
    description: 'Montre version, description et détails.',
    commands: {
      'APT (Debian/Ubuntu)': 'apt show <paquet>',
      'Pacman (Arch)': 'pacman -Si <paquet>',
      'DNF (Fedora/RHEL)': 'dnf info <paquet>',
      'Zypper (openSUSE)': 'zypper info <paquet>',
    },
  ),
  PackageAction(
    id: 'list_installed',
    action: 'Lister les paquets installés',
    description: 'Affiche tous les paquets présents sur le système.',
    commands: {
      'APT (Debian/Ubuntu)': 'apt list --installed',
      'Pacman (Arch)': 'pacman -Q',
      'DNF (Fedora/RHEL)': 'dnf list installed',
      'Zypper (openSUSE)': 'zypper se --installed-only',
    },
  ),
  PackageAction(
    id: 'clean_cache',
    action: 'Nettoyer le cache des paquets',
    description: 'Libère de l’espace disque utilisé par les caches.',
    commands: {
      'APT (Debian/Ubuntu)': 'sudo apt clean',
      'Pacman (Arch)': 'sudo pacman -Scc',
      'DNF (Fedora/RHEL)': 'sudo dnf clean all',
      'Zypper (openSUSE)': 'sudo zypper clean -a',
    },
    tip: 'Sur Pacman, `-Scc` supprime agressivement le cache.',
  ),
  PackageAction(
    id: 'reinstall_package',
    action: 'Réinstaller un paquet',
    description:
        'Réinstalle un paquet pour corriger une installation corrompue.',
    commands: {
      'APT (Debian/Ubuntu)': 'sudo apt install --reinstall <paquet>',
      'Pacman (Arch)': 'sudo pacman -S <paquet>',
      'DNF (Fedora/RHEL)': 'sudo dnf reinstall <paquet>',
      'Zypper (openSUSE)': 'sudo zypper install --force <paquet>',
    },
  ),
  PackageAction(
    id: 'rollback_version',
    action: 'Downgrade (si disponible)',
    description: 'Revenir à une version précédente lorsque possible.',
    commands: {
      'APT (Debian/Ubuntu)': 'sudo apt install <paquet>=<version>',
      'Pacman (Arch)':
          'sudo pacman -U /var/cache/pacman/pkg/<pkg-old>.pkg.tar.zst',
      'DNF (Fedora/RHEL)': 'sudo dnf downgrade <paquet>',
      'Zypper (openSUSE)': 'sudo zypper install --oldpackage <paquet>',
    },
  ),
];
