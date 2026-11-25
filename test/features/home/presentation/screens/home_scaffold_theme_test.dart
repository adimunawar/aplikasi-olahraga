import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workout_app/core/theme/app_theme.dart';
import 'package:workout_app/features/home/presentation/screens/home_scaffold.dart';

void main() {
  testWidgets(
    'HomeScaffold renders bottom nav and switches branches in both themes',
    (tester) async {
      for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
        final router = GoRouter(
          initialLocation: '/home',
          routes: [
            StatefulShellRoute.indexedStack(
              builder: (_, _, shell) => HomeScaffold(navigationShell: shell),
              branches: [
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/home',
                      builder: (_, _) => const Scaffold(body: Text('Tab Home')),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/workouts',
                      builder: (_, _) =>
                          const Scaffold(body: Text('Tab Workouts')),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/progress',
                      builder: (_, _) =>
                          const Scaffold(body: Text('Tab Progress')),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/profile',
                      builder: (_, _) =>
                          const Scaffold(body: Text('Tab Profile')),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp.router(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Tab Home'), findsOneWidget);
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();
        expect(find.text('Tab Profile'), findsOneWidget);
      }
    },
  );
}
