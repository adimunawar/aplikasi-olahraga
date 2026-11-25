import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workout_app/core/theme/app_theme.dart';
import 'package:workout_app/core/widgets/core_widgets.dart';

void main() {
  group('AppCard', () {
    testWidgets('renders surface and tinted variants in Light and Dark Mode', (
      tester,
    ) async {
      for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: Scaffold(
              body: Column(
                children: [
                  const AppCard(child: Text('Surface Card')),
                  AppCard.tinted(child: const Text('Tinted Card')),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Surface Card'), findsOneWidget);
        expect(find.text('Tinted Card'), findsOneWidget);
      }
    });
  });

  group('AppSectionHeader', () {
    testWidgets('renders title, optional subtitle, and action in both themes', (
      tester,
    ) async {
      var tapped = false;

      for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: Scaffold(
              body: Column(
                children: [
                  const AppSectionHeader(
                    title: 'Ringkasan',
                    subtitle: '8 minggu terakhir',
                  ),
                  AppSectionHeader.withAction(
                    icon: Icons.fitness_center_rounded,
                    title: 'Latihan',
                    actionText: 'Lihat Semua',
                    onActionTap: () => tapped = true,
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Ringkasan'), findsOneWidget);
        expect(find.text('8 minggu terakhir'), findsOneWidget);
        expect(find.text('Latihan'), findsOneWidget);
        expect(find.text('Lihat Semua'), findsOneWidget);
      }

      await tester.tap(find.text('Lihat Semua'));
      expect(tapped, isTrue);
    });
  });
}
