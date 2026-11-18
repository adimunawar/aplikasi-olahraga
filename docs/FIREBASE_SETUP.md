# Firebase Configuration — Crashlytics & Analytics

This document explains how Firebase is configured in this repository, how to verify the integration, and what is still required to enable iOS support.

## Overview

| Item | Value |
|---|---|
| Firebase project | `home-workout-coach-9c799` |
| Android package | `com.homefitness.workout_app` |
| iOS bundle ID | `com.homefitness.workoutApp` |
| Flutter packages | `firebase_core`, `firebase_crashlytics`, `firebase_analytics` |
| Gradle plugins | `com.google.gms.google-services` 4.6.0, `com.google.firebase.crashlytics` 3.0.8 |

Firebase is initialized once in `lib/main.dart`, before `runApp`:

```dart
await FirebaseConfig.initialize();
```

The bootstrap implementation is located at `lib/core/config/firebase_config.dart`:

- It runs only on Android and iOS. Web and desktop platforms are skipped because they do not have the required native Firebase configuration.
- Initialization is idempotent and must never block application startup. If Firebase configuration is unavailable, the app continues to run normally in local-first mode without monitoring.
- Global error handlers are registered: `FlutterError.onError` captures framework errors, and `PlatformDispatcher.instance.onError` captures asynchronous errors. When Crashlytics collection is enabled, these errors are reported as fatal.

The Analytics wrapper is located at `lib/core/services/analytics_service.dart`. It is safe to call at any time and automatically becomes a no-op when Firebase is unavailable or Analytics collection is disabled.

## Android

### Configuration file

`android/app/google-services.json` is **not committed to the repository**. It is listed in `.gitignore` as part of the repository's security controls. The file contains project identifiers rather than service-account credentials, but it is still treated as local project configuration.

To download or update the file:

1. Open the [Firebase Console](https://console.firebase.google.com/) and select the `home-workout-coach-9c799` project.
2. Open **Project settings** → **Your apps**, then select the Android app `com.homefitness.workout_app`.
3. Download `google-services.json` and place it in `android/app/`.
4. Confirm that the package name in the file matches the `applicationId` in `android/app/build.gradle.kts`.

### Gradle configuration

The `android/settings.gradle` file declares both plugins with `apply false`:

```groovy
id "com.google.gms.google-services" version "4.6.0" apply false
id "com.google.firebase.crashlytics" version "3.0.8" apply false
```

The plugins are applied in `android/app/build.gradle.kts`:

```kotlin
id("com.google.gms.google-services")
id("com.google.firebase.crashlytics")
```

If `google-services.json` is missing, the Android build fails with the message `File google-services.json is missing`. This is intentional: a release APK must not silently omit Crashlytics or Analytics configuration.

### CI configuration

The `.github/workflows/flutter-ci.yml` workflow writes the Firebase configuration file from a repository secret before building a release APK:

- Secret name: **`GOOGLE_SERVICES_JSON`**
- Secret value: the complete raw JSON contents of `android/app/google-services.json`.

Without this secret, the **Build Android release APK** job fails with the message `Missing GitHub secret GOOGLE_SERVICES_JSON`.

## Data Collection Behavior (Debug vs. Release)

Crashlytics and Analytics collection are **enabled by default in Release builds** and **disabled by default in Debug and Profile builds**. This prevents routine development crashes and test events from being uploaded from a developer's device.

To temporarily enable Crashlytics during a local test:

```bash
flutter run --dart-define=FIREBASE_CRASHLYTICS_ENABLED=true
```

To enable Analytics for Firebase DebugView:

```bash
flutter run --dart-define=FIREBASE_ANALYTICS_ENABLED=true
```

Before production release, provide an appropriate privacy notice and obtain any consent required by the product privacy policy and applicable law. Do not send email addresses, names, body measurements, workout notes, or other directly identifying or sensitive information as Analytics event parameters.

## Verifying Crashlytics

To test crash reporting, run the app in Debug mode with Crashlytics collection enabled:

1. Run the app on an Android device or emulator:
   ```bash
   flutter run --dart-define=FIREBASE_CRASHLYTICS_ENABLED=true
   ```
2. Temporarily trigger a crash from the code, for example, from a button:
   ```dart
   FirebaseCrashlytics.instance.crash();
   ```

   Alternatively, test framework error reporting with:
   ```dart
   throw StateError('Crashlytics test');
   ```
3. Close the app and open it again so the report can be sent.
4. Open Firebase Console → **Crashlytics** and allow 1–5 minutes for the report to appear.

Check the connection logs in Logcat:

```powershell
adb logcat | Select-String "Firebase|Crashlytics"
```

## Verifying Analytics

Analytics automatically collects basic events such as `first_open` and `session_start`. A `screen_view` event is available when it is logged manually.

To view events in real time:

1. Run the app with `FIREBASE_ANALYTICS_ENABLED=true`, then enable DebugView for the Android app on the device:
   ```bash
   adb shell setprop debug.firebase.analytics.app com.homefitness.workout_app
   ```
2. Launch the application:
   ```bash
   flutter run --dart-define=FIREBASE_ANALYTICS_ENABLED=true
   ```
3. Open Firebase Console → **Analytics** → **DebugView**.
4. Disable DebugView when you are finished:
   ```bash
   adb shell setprop debug.firebase.analytics.app .none.
   ```

Example usage:

```dart
import 'core/services/analytics_service.dart';

AnalyticsService.instance.logEvent('workout_started', parameters: {
  'program_id': programId,
  'day_number': dayNumber,
});

AnalyticsService.instance.logScreenView(screenName: 'home');

AnalyticsService.instance.setUserId(userId);
```

## iOS (Not Yet Verified)

A macOS machine with Xcode is required. The following setup steps still need to be completed and verified:

1. In Firebase Console, add an iOS app with the bundle ID `com.homefitness.workoutApp`. Note the uppercase `A`; this differs from the Android package name.
2. Download `GoogleService-Info.plist`.
3. Add the file to the **Runner** target through Xcode. Drag it into the Project Navigator and make sure **Runner** is selected. Placing the file in a directory without adding it to the target is not sufficient.
4. Generate the `Podfile` (it is not currently present in the repository) by running the first iOS build:
   ```bash
   flutter build ios --no-codesign
   ```
5. Ensure that `platform :ios, '13.0'` or a later version is set in `ios/Podfile`, then run:
   ```bash
   cd ios && pod install
   ```
6. To upload Crashlytics dSYM files, add a **Run Script** phase to the Runner target in **Build Phases**, after the **Embed Frameworks** phase:
   ```text
   "${PODS_ROOT}/FirebaseCrashlytics/run"
   ```

   Add the following input files:
   ```text
   ${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}
   ${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}
   ```
7. If iOS builds are later automated in CI, add the `GOOGLE_SERVICES_PLIST` secret in base64 format.

## Important Notes

- Android Release builds use a dedicated upload keystore. Configure it locally through `android/key.properties` and in CI through GitHub Actions Secrets. The Gradle configuration intentionally does not fall back to the Android debug signing key.
- Crashlytics collection is enabled by default only for Release builds. Analytics collection follows the same Release-first default.
- The current `minSdk` follows Flutter's default (24), which meets the Firebase Android requirement.
- Crashlytics symbol/mapping files are uploaded automatically by the `com.google.firebase.crashlytics` plugin during release builds. Do not remove this plugin even when using Analytics only.
- To add other Firebase products (Firestore, Auth, Messaging, and so on), add their Flutter packages. Android native configuration continues to use the same `google-services.json` file.

## Troubleshooting

| Symptom | Cause and resolution |
|---|---|
| `File google-services.json is missing` | The file is missing from `android/app/`. Download it from Firebase Console and place it in that directory. |
| `[Firebase] Initialization failed: ...` appears in the logs | The package/bundle ID may not match the configuration file, or the file may be corrupted. |
| Crashes do not appear in the console | Collection may be disabled, the app may not have been reopened, or the report may still be processing. Allow a few minutes. |
| Analytics events do not appear | DebugView may not be enabled, or `setAnalyticsCollectionEnabled(false)` may have been called. |
| CI build fails with `Missing GitHub secret GOOGLE_SERVICES_JSON` | Add a repository secret containing the complete contents of `google-services.json`. |
