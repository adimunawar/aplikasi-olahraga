# Terjemahan (slang)

Semua teks UI aplikasi dikelola oleh [slang](https://pub.dev/packages/slang) di folder ini.

## Aturan dasar

- `base_locale` adalah **`id`** (Bahasa Indonesia). Copywriting asli ditulis di `*_id.i18n.json`,
  lalu `*_en.i18n.json` mengikuti struktur yang sama.
- Satu file per feature (namespace), mengikuti struktur `lib/features/`:
  `home_id.i18n.json` + `home_en.i18n.json`, dan seterusnya.
- File `strings*.g.dart` **generated** — jangan diedit manual, tapi **harus di-commit**
  supaya build/CI tidak perlu menjalankan codegen.
- String konten yang berasal dari JSON/DB (`exercises.json`, `foods.json`, Supabase)
  **tidak** masuk ke sini. Itu tetap memakai model `LocalizedString`
  (`lib/features/exercises/domain/models/exercise.dart`).

## Menambah / mengubah teks

1. Edit `<namespace>_id.i18n.json`, lalu samakan strukturnya di `<namespace>_en.i18n.json`.
2. Jalankan:

   ```bash
   dart run slang
   ```

3. Pakai di widget:

   ```dart
   final t = Translations.of(context); // rebuild otomatis saat bahasa berubah
   Text(t.core.actions.save);
   ```

   Atau lewat extension: `context.t.core.actions.save`.

## Perintah bantuan

```bash
dart run slang analyze --full   # cek key yang hilang / tidak terpakai
dart run slang normalize        # urutkan key mengikuti base locale
dart run slang edit move a b    # pindah/rename namespace
```

## Ganti bahasa saat runtime

Gunakan provider, jangan panggil `LocaleSettings` langsung:

```dart
ref.read(appLocaleProvider.notifier).setLocale(AppLocale.en);
```

`AppLocaleController` menyimpan pilihan ke `SharedPreferences` (`app_locale`)
sekaligus menyinkronkan `LocaleSettings` slang. Pilihan bahasa di
Pengaturan → Bahasa sudah terhubung ke provider ini.

## Catatan

- `flutter_localizations` tetap dipakai untuk localization bawaan Material
  (tooltip, date picker, dll). Slang hanya menggantikan teks milik aplikasi.
- iOS: jalankan `dart run slang configure` bila menambah locale baru,
  agar `CFBundleLocalizations` ikut terupdate.
