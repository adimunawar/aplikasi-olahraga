import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../i18n/strings.g.dart';

/// Key SharedPreferences untuk menyimpan pilihan bahasa pengguna.
const kAppLocalePrefsKey = 'app_locale';

/// Locale aktif aplikasi.
///
/// Semua perubahan bahasa harus lewat provider ini agar pilihan pengguna
/// tersimpan dan [LocaleSettings] slang ikut diperbarui.
final appLocaleProvider =
    NotifierProvider<AppLocaleController, AppLocale>(AppLocaleController.new);

class AppLocaleController extends Notifier<AppLocale> {
  AppLocaleController({this.initial});

  /// Locale awal saat aplikasi dibuka (dibaca dari SharedPreferences).
  final AppLocale? initial;

  @override
  AppLocale build() => initial ?? AppLocale.id;

  /// Ganti bahasa aplikasi lalu simpan pilihannya.
  Future<void> setLocale(AppLocale locale) async {
    if (state == locale) return;

    state = locale;
    // Pakai versi async agar locale lazy/deferred (web) ikut ter-load.
    await LocaleSettings.setLocale(locale);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kAppLocalePrefsKey, locale.languageTag);
  }
}

/// Baca bahasa tersimpan. Dipanggil di `main()` sebelum `runApp`.
///
/// Selalu mengembalikan locale yang didukung; nilai tidak dikenal
/// akan jatuh ke bahasa default aplikasi.
AppLocale loadStoredLocale(SharedPreferences prefs) {
  final stored = prefs.getString(kAppLocalePrefsKey);
  if (stored == null || stored.isEmpty) return AppLocale.id;

  // `parse` otomatis fallback ke base locale bila nilainya tidak didukung.
  return AppLocaleUtils.parse(stored);
}

/// Sinkronkan [LocaleSettings] slang dengan locale awal aplikasi.
///
/// Dipanggil di `main()` setelah binding siap dan sebelum `runApp`.
Future<void> applyInitialLocale(AppLocale locale) async {
  await LocaleSettings.setLocale(locale);
}

/// Label bahasa yang dipakai pada pengaturan profil
/// (`user_settings.language`) -> [AppLocale].
AppLocale appLocaleFromProfileLanguage(String language) {
  return language.toLowerCase().startsWith('english')
      ? AppLocale.en
      : AppLocale.id;
}

/// Kebalikannya: [AppLocale] -> label pada pengaturan profil.
String profileLanguageFromAppLocale(AppLocale locale) {
  return locale == AppLocale.en ? 'English' : 'Bahasa Indonesia';
}
