# Internationalization & Translations (slang)

All UI strings across the application are managed by [slang](https://pub.dev/packages/slang) inside this directory.

## Core Rules

- The `base_locale` is **`id`** (Indonesian). Original copywriting is written in `*_id.i18n.json`, and `*_en.i18n.json` mirrors the exact same structure.
- One file per feature (namespace), following the `lib/features/` directory layout: `home_id.i18n.json` + `home_en.i18n.json`, and so forth.
- `strings*.g.dart` files are **generated** — never edit them manually, but **always commit them** so builds and CI pipelines do not need to run codegen.
- Content strings originating from JSON files or the database (`exercises.json`, `foods.json`, Supabase) are **not** stored here. Those continue to use the `LocalizedString` domain model (`lib/features/exercises/domain/models/exercise.dart`).

## Adding / Updating Strings

1. Edit `<namespace>_id.i18n.json`, then replicate the matching structure in `<namespace>_en.i18n.json`.
2. Run:

   ```bash
   dart run slang
   ```

3. Consume in widgets:

   ```dart
   final t = Translations.of(context); // Automatically rebuilds when locale changes
   Text(t.core.actions.save);
   ```

   Or via context extension: `context.t.core.actions.save`.

## Useful Commands

```bash
dart run slang analyze --full   # Check for missing or unused translation keys
dart run slang normalize        # Sort keys to match the base locale
dart run slang edit move a b    # Move or rename a namespace
```

## Changing Language at Runtime

Always use the Riverpod provider instead of calling `LocaleSettings` directly:

```dart
ref.read(appLocaleProvider.notifier).setLocale(AppLocale.en);
```

`AppLocaleController` persists the selected language to `SharedPreferences` (`app_locale`) while simultaneously synchronizing slang's `LocaleSettings`. The language selector in **Settings → Language** is already wired to this provider.

## Migration Status

| Namespace      | Status                                                                                                           |
| -------------- | ---------------------------------------------------------------------------------------------------------------- |
| `core`         | Partial (actions, state, badge, language, units)                                                                 |
| `onboarding`   | Completed (welcome, goal, about, body target, level, schedule, equipment, limitations, creating, ready, preview) |
| Other features | In progress / partially hardcoded                                                                                |

## Notes

- `flutter_localizations` is still required for built-in Material widget localization (tooltips, date pickers, etc.). Slang only handles custom application text.
- iOS: Run `dart run slang configure` when introducing a new locale so that `CFBundleLocalizations` in `Info.plist` is properly updated.
