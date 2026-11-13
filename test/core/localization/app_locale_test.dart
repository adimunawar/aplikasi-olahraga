import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_app/core/localization/app_locale.dart';
import 'package:workout_app/i18n/strings.g.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await applyInitialLocale(AppLocale.id);
  });

  test('loadStoredLocale fallback ke id bila kosong', () async {
    final prefs = await SharedPreferences.getInstance();
    expect(loadStoredLocale(prefs), AppLocale.id);
  });

  test('loadStoredLocale membaca pilihan tersimpan', () async {
    SharedPreferences.setMockInitialValues({kAppLocalePrefsKey: 'en'});
    final prefs = await SharedPreferences.getInstance();
    expect(loadStoredLocale(prefs), AppLocale.en);
  });

  testWidgets('Widget rebuild saat bahasa diganti', (tester) async {
    late WidgetRef ref;

    await tester.pumpWidget(
      TranslationProvider(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: ProviderScope(
            child: Consumer(
              builder: (context, r, _) {
                ref = r;
                return Text(Translations.of(context).core.actions.save);
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Simpan'), findsOneWidget);

    await ref.read(appLocaleProvider.notifier).setLocale(AppLocale.en);
    await tester.pumpAndSettle();

    expect(find.text('Save'), findsOneWidget);
    expect(ref.read(appLocaleProvider), AppLocale.en);
  });
}
