import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workout_app/core/theme/app_theme.dart';
import 'package:workout_app/features/profile/presentation/widgets/app_settings_widgets.dart';

void main() {
  group('AppSettingsWidgets', () {
    testWidgets(
      'AppSettingsNavigationCard and AppSettingsSwitchCard render in Light and Dark Mode',
      (tester) async {
        var navTapped = false;
        var switchValue = false;

        for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              home: Scaffold(
                body: Column(
                  children: [
                    AppSettingsNavigationCard(
                      icon: Icons.dark_mode_outlined,
                      title: 'Theme',
                      valueText: 'Dark',
                      onTap: () => navTapped = true,
                    ),
                    AppSettingsSwitchCard(
                      icon: Icons.vibration_rounded,
                      title: 'Haptic Feedback',
                      subtitle: 'Vibrate on actions',
                      value: switchValue,
                      onChanged: (val) => switchValue = val,
                    ),
                  ],
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Theme'), findsOneWidget);
          expect(find.text('Dark'), findsOneWidget);
          expect(find.text('Haptic Feedback'), findsOneWidget);
        }

        await tester.tap(find.text('Theme'));
        await tester.tap(find.byType(Switch));
        expect(navTapped, isTrue);
        expect(switchValue, isTrue);
      },
    );

    testWidgets('showAppSettingsPickerSheet selects option and closes sheet', (
      tester,
    ) async {
      String? picked;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAppSettingsPickerSheet(
                  context: context,
                  title: 'Select Theme',
                  options: const ['Light', 'Dark', 'System Default'],
                  selectedValue: 'Light',
                  onSelected: (val) => picked = val,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Select Theme'), findsOneWidget);
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(picked, 'Dark');
      expect(find.text('Select Theme'), findsNothing);
    });
  });
}
