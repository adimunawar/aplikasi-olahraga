import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workout_app/core/theme/app_theme.dart';
import 'package:workout_app/core/widgets/core_widgets.dart';

void main() {
  group('AppSegmentedTabs', () {
    testWidgets('renders all segment labels and invokes onChanged when tapped', (
      tester,
    ) async {
      int? selectedTab;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AppSegmentedTabs<int>(
              selectedValue: 0,
              onChanged: (value) => selectedTab = value,
              tabs: const [
                AppSegmentedTabItem(value: 0, label: 'Program Saya'),
                AppSegmentedTabItem(value: 1, label: 'Semua Latihan'),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(SegmentedButton<int>), findsOneWidget);
      expect(find.text('Program Saya'), findsOneWidget);
      expect(find.text('Semua Latihan'), findsOneWidget);

      await tester.tap(find.text('Semua Latihan'));
      await tester.pumpAndSettle();

      expect(selectedTab, 1);
    });

    testWidgets('renders 4 tabs cleanly in Light and Dark Mode', (
      tester,
    ) async {
      for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AppSegmentedTabs<int>(
                  selectedValue: 2,
                  onChanged: (_) {},
                  tabs: const [
                    AppSegmentedTabItem(value: 0, label: 'Ringkasan'),
                    AppSegmentedTabItem(value: 1, label: 'Tubuh'),
                    AppSegmentedTabItem(value: 2, label: 'Latihan'),
                    AppSegmentedTabItem(value: 3, label: 'Riwayat'),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Ringkasan'), findsOneWidget);
        expect(find.text('Tubuh'), findsOneWidget);
        expect(find.text('Latihan'), findsOneWidget);
        expect(find.text('Riwayat'), findsOneWidget);
      }
    });
  });
}
