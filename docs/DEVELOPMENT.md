# Development Setup

This guide describes how to prepare a local development environment for Workout Coach. The repository's mandatory coding rules are in AGENTS.md.

## 1. Toolchain

Use the same Flutter version as CI unless a version upgrade is being proposed:

| Tool | Repository baseline |
|---|---|
| Flutter | 3.50.0 (pinned in GitHub Actions) |
| Dart | Compatible with pubspec.yaml constraint ^3.13.7 |
| Gradle Wrapper | 9.3.1 (minimum required by the Flutter 3.50 Gradle plugin) |
| Android Gradle Plugin | 8.11.1 |
| Kotlin Gradle Plugin | 2.4.0 |
| Java | JDK 17 for Android Gradle builds |
| Android | Android SDK / Android Studio |
| Package manager | Flutter Pub |
| Git | Required |

If your local Flutter version differs from CI, resolve the version mismatch before debugging dependency or analyzer failures.

## 2. Get the code and dependencies

From the repository root:

    flutter doctor -v
    flutter pub get

Do not edit pubspec.lock manually. Let Flutter resolve dependencies and commit the lockfile when dependency changes are intentional.

## 3. Environment configuration

### Supabase

SupabaseConfig reads compile-time Dart defines:

- SUPABASE_URL
- SUPABASE_ANON_KEY

For a non-default Supabase project, provide both values at launch:

    flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLISHABLE_KEY

The application currently has fallback public-client configuration in source. Dart defines are the supported way to select another environment without changing source code.

A publishable/anon key is intended for client use. It is NOT authorization by itself. RLS, table grants, and owner-scoped policies remain mandatory. Never place a service-role/secret key in the client.

### Firebase on Android

The Android project applies Google Services and Crashlytics Gradle plugins. The repository's documented Android release path expects a valid file at:

    android/app/google-services.json

Obtain it from the Firebase Console for the Android application configured in the project. The file is ignored by Git and MUST NOT be committed.

See [Firebase setup](FIREBASE_SETUP.md) for collection defaults, local debug flags, CI configuration, and troubleshooting.

FirebaseConfig is guarded at runtime: a Firebase initialization failure is logged and must not prevent local-first startup. The Android Gradle build still needs its native Google Services configuration when the plugin is applied.

### Android release signing

A distributable release APK must use the persistent release keystore. Never use the Android debug signing key for release distribution.

See [Android release signing](android-release-signing.md). Do not put keystore files or passwords in the repository.

## 4. Run the app

After dependencies and required Android native configuration are available:

    flutter run

For an alternate Supabase environment, add the Dart defines from Section 3.

The current CI and documented distribution pipeline are Android-focused. iOS and desktop should be treated as unverified until their build and runtime paths have been exercised on the appropriate machines.

## 5. Useful local commands

Format-check Dart sources:

    dart format --output=none --set-exit-if-changed lib test

Apply formatting intentionally:

    dart format lib test

Run static analysis:

    flutter analyze

Run all tests:

    flutter test

Run tests and generate coverage:

    flutter test --coverage

Inspect dependency changes before committing:

    flutter pub deps

## 6. Localization

The app uses slang and slang_flutter. User-visible strings MUST use the localization resources and follow the repository's current translation conventions. Keep Indonesian and English copy semantically aligned.

Do not hand-edit generated localization output unless the generated-file workflow explicitly requires it. When adding or changing translation keys, update the source localization files and use the project's established generation workflow.

## 7. Database and Supabase environment

The SQLite database is created locally by AppDatabase. Supabase SQL migrations live under supabase/migrations/.

Before changing schema or RLS:

1. Read AGENTS.md and docs/REPOSITORY_SECURITY.md.
2. Inspect all related migrations and current data contracts.
3. Create a new forward-only migration; do not rewrite an already-applied migration.
4. Test against a disposable/staging Supabase project.
5. Verify both allowed and denied access using representative roles.
6. Document rollback/recovery considerations. Prefer a forward corrective migration for production data.

A migration file in Git is not proof that it has been applied to a hosted Supabase project.

## 8. Platform notes

- Native Android uses sqflite for SQLite persistence.
- AppDatabase contains an in-memory fallback for web; it is not durable storage and must not be treated as equivalent to native SQLite.
- FirebaseConfig initializes only on Android/iOS.
- Current GitHub release/distribution workflows build Android APKs. Do not advertise iOS, web, or desktop production support without successful platform-specific verification.
