import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workout_app/core/router/app_router.dart';
import 'package:workout_app/core/theme/app_theme.dart';
import 'package:workout_app/features/profile/presentation/screens/help_about_screen.dart';

void main() {
  testWidgets('HelpAboutScreen opens and closes Help Center dialog', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: AppRoutes.helpAbout,
      routes: [
        GoRoute(
          path: AppRoutes.helpAbout,
          builder: (_, _) => const HelpAboutScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Help Center'));
    await tester.pumpAndSettle();
    expect(find.text('Tutup'), findsOneWidget);

    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
    expect(find.text('Tutup'), findsNothing);
  });
}
