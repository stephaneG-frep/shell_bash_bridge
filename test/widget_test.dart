import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shell_bash_bridge/app/app.dart';

void main() {
  testWidgets('App renders splash title', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ShellBashBridgeApp()));
    expect(find.text('Shell-Bash-Bridge'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1500));
  });
}
