import 'package:flutter/material.dart';

import 'router.dart';
import 'theme/app_theme.dart';

class ShellBashBridgeApp extends StatelessWidget {
  const ShellBashBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Shell-Bash-Bridge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
