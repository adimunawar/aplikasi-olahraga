import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/core/theme/app_theme.dart';
import 'package:workout_app/core/theme/home_theme.dart';
import 'package:workout_app/core/theme/app_colors.dart';

void main() {
  testWidgets('HomeTheme resolves surfaces from the active dark theme', (tester) async {
    late Color surface;
    late Color background;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: Builder(
          builder: (context) {
            surface = HomeTheme.surface(context);
            background = HomeTheme.background(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(surface, AppColors.darkSurface);
    expect(background, AppColors.darkScaffoldBackground);
  });

  testWidgets('HomeTheme resolves surfaces from the active light theme', (tester) async {
    late Color surface;
    late Color background;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: Builder(
          builder: (context) {
            surface = HomeTheme.surface(context);
            background = HomeTheme.background(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(surface, AppColors.surface);
    expect(background, AppColors.background);
  });
}
