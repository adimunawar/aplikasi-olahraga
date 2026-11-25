import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workout_app/core/theme/app_theme.dart';
import 'package:workout_app/core/widgets/core_widgets.dart';

void main() {
  group('AppEmptyState', () {
    testWidgets('renders card and non-card variants in Light and Dark Mode', (
      tester,
    ) async {
      var actionTapped = false;

      for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: Scaffold(
              body: Column(
                children: [
                  const AppEmptyState(
                    icon: Icons.history_rounded,
                    title: 'Belum ada riwayat',
                    message: 'Aktivitas akan muncul di sini.',
                  ),
                  AppEmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'Tidak ditemukan',
                    useCard: false,
                    compact: true,
                    neutralBadge: true,
                    action: TextButton(
                      onPressed: () => actionTapped = true,
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Belum ada riwayat'), findsOneWidget);
        expect(find.text('Aktivitas akan muncul di sini.'), findsOneWidget);
        expect(find.text('Tidak ditemukan'), findsOneWidget);
      }

      await tester.tap(find.text('Reset'));
      expect(actionTapped, isTrue);
    });
  });

  group('AppErrorState', () {
    testWidgets('renders card and full-screen variants and triggers retry', (
      tester,
    ) async {
      var retryCount = 0;

      for (final useCard in [false, true]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            home: Scaffold(
              body: AppErrorState(
                title: 'Gagal memuat',
                message: 'Periksa koneksi Anda.',
                retryLabel: 'Coba Lagi',
                useCard: useCard,
                onRetry: () => retryCount++,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Gagal memuat'), findsOneWidget);
        expect(find.text('Periksa koneksi Anda.'), findsOneWidget);

        await tester.tap(find.text('Coba Lagi'));
        await tester.pumpAndSettle();
      }

      expect(retryCount, 2);
    });
  });
}
