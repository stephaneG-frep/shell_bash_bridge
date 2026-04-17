import 'package:go_router/go_router.dart';

import '../core/utils/enums.dart';
import '../features/commands/presentation/command_detail_screen.dart';
import '../features/commands/presentation/commands_screen.dart';
import '../features/compare/presentation/compare_screen.dart';
import '../features/favorites/presentation/favorites_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/progress/presentation/progress_screen.dart';
import '../features/quiz/presentation/quiz_result_screen.dart';
import '../features/quiz/presentation/quiz_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/shells/presentation/bash_screen.dart';
import '../features/shells/presentation/powershell_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import 'widgets/main_scaffold.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/bash', builder: (context, state) => const BashScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/compare', builder: (context, state) => const CompareScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/favorites', builder: (context, state) => const FavoritesScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/progress', builder: (context, state) => const ProgressScreen()),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/powershell',
      builder: (context, state) => const PowerShellScreen(),
    ),
    GoRoute(
      path: '/commands',
      builder: (context, state) {
        final shellName = state.uri.queryParameters['shell'];
        final shell = ShellType.values.where((e) => e.name == shellName).firstOrNull;
        return CommandsScreen(initialShell: shell);
      },
    ),
    GoRoute(
      path: '/command/:id',
      builder: (context, state) => CommandDetailScreen(commandId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/quiz',
      builder: (context, state) {
        final shellName = state.uri.queryParameters['shell'];
        final shell = ShellType.values.where((e) => e.name == shellName).firstOrNull;
        return QuizScreen(shellType: shell);
      },
    ),
    GoRoute(
      path: '/quiz-result',
      builder: (context, state) {
        final score = int.tryParse(state.uri.queryParameters['score'] ?? '0') ?? 0;
        final total = int.tryParse(state.uri.queryParameters['total'] ?? '0') ?? 0;
        return QuizResultScreen(score: score, total: total);
      },
    ),
    GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
  ],
);

extension _IterableFirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
