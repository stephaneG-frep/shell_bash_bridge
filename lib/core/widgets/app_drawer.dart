import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const ListTile(
              title: Text(
                'Shell-Bash-Bridge',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('Navigation complète'),
            ),
            const Divider(height: 1),
            _DrawerLink(
              label: 'Accueil',
              icon: Icons.home_outlined,
              route: '/home',
            ),
            _DrawerLink(
              label: 'Bash',
              icon: Icons.terminal_outlined,
              route: '/bash',
            ),
            _DrawerLink(
              label: 'PowerShell',
              icon: Icons.flash_on_outlined,
              route: '/powershell',
            ),
            _DrawerLink(
              label: 'Commandes',
              icon: Icons.menu_book_outlined,
              route: '/commands',
            ),
            _DrawerLink(
              label: 'Compare',
              icon: Icons.compare_arrows,
              route: '/compare',
            ),
            _DrawerLink(
              label: 'Centre de réponses',
              icon: Icons.psychology_alt_outlined,
              route: '/answers',
            ),
            _DrawerLink(
              label: 'Notes+ perso',
              icon: Icons.note_alt_outlined,
              route: '/notes',
            ),
            _DrawerLink(
              label: 'Parcours guidés',
              icon: Icons.route_outlined,
              route: '/paths',
            ),
            _DrawerLink(
              label: 'Quiz',
              icon: Icons.quiz_outlined,
              route: '/quiz',
            ),
            _DrawerLink(
              label: 'Favoris',
              icon: Icons.favorite_border,
              route: '/favorites',
            ),
            _DrawerLink(
              label: 'Progression',
              icon: Icons.trending_up_outlined,
              route: '/progress',
            ),
            _DrawerLink(
              label: 'Mode d’emploi pédagogique',
              icon: Icons.school_outlined,
              route: '/guide',
            ),
            _DrawerLink(
              label: 'Paramètres',
              icon: Icons.settings_outlined,
              route: '/settings',
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerLink extends StatelessWidget {
  const _DrawerLink({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.of(context).pop();
        context.go(route);
      },
    );
  }
}
