# Release Process

This document describes the release paths currently defined in GitHub Actions. The established automated distribution target is Android.

## 1. Branch and workflow overview

| Workflow | Trigger | Behavior |
|---|---|---|
| Flutter CI | Pull request to develop, staging, or main | Analyze and test |
| Flutter CI | Push to main | Analyze and test |
| Flutter CI | Manual dispatch on develop | Analyze/test, then configured signed develop APK build |
| Build & Distribute Staging | Push to staging | Build signed Android release APK and distribute through Firebase App Distribution |

The workflow files are:

- .github/workflows/flutter-ci.yml
- .github/workflows/build-staging.yml

A feature branch does not automatically receive a CI result merely because a workflow exists. Open a pull request to a configured target branch to run the required checks.

## 2. Versioning

The application version is maintained in pubspec.yaml using Flutter's version/build-number convention.

Before a release:

1. Confirm the release scope and user-visible changes.
2. Update version/build number according to the release plan.
3. Update CHANGELOG.md.
4. Verify Android package identity and signing configuration.
5. Run analyzer and tests.
6. Build and install the release artifact on a test device.
7. Execute the smoke-test checklist.
8. Record the commit SHA and artifact used for distribution.

Do not reuse a build number that has already been distributed to a channel that requires monotonically increasing version codes.

## 3. Android signing

The release Gradle configuration intentionally does not fall back to the Android debug key.

Use the documented signing procedure:

- Local key setup: docs/android-release-signing.md
- CI secrets: ANDROID_KEYSTORE_BASE64, ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_ALIAS, ANDROID_KEY_PASSWORD

Keep the keystore and passwords in a secure password manager with a separate backup. Never commit them.

## 4. Staging distribution

A push to staging runs the staging workflow.

Required GitHub configuration:

| Name | Type | Purpose |
|---|---|---|
| ANDROID_KEYSTORE_BASE64 | Secret | Base64-encoded release keystore |
| ANDROID_KEYSTORE_PASSWORD | Secret | Keystore password |
| ANDROID_KEY_ALIAS | Secret | Signing alias |
| ANDROID_KEY_PASSWORD | Secret | Key password |
| GOOGLE_SERVICES_JSON | Secret | Raw Android google-services.json content |
| FIREBASE_APP_ID | Secret | Firebase Android app identifier |
| FIREBASE_SERVICE_ACCOUNT_JSON | Secret | Firebase distribution service account JSON |
| FIREBASE_TESTER_GROUPS | Repository variable | Firebase App Distribution tester groups |

The staging workflow validates required configuration, builds the APK, and distributes it through Firebase App Distribution. A missing required secret should fail the relevant job.

## 5. Develop build

The Flutter CI workflow contains a manual develop build path. It runs only when workflow_dispatch is initiated for develop and the required analysis/test jobs succeed.

The build uses the same Android signing and Firebase configuration expectations as the workflow.

## 6. Release smoke test

Before distributing an APK, verify at minimum:

- App launches from a clean install.
- Onboarding completes and persists.
- Exercise catalog loads or shows a recoverable first-sync state.
- Exercise detail displays correct metadata and media fallback.
- Workout can start, complete sets, enter rest, and continue.
- App can be interrupted and an active workout can be resumed.
- Completing a workout updates local history and progress.
- Empty progress does not display sample values.
- Offline behavior is understandable and does not discard local workout records.
- Cloud Sync remains disabled unless account and consent conditions are met.
- App does not crash when Firebase monitoring is unavailable.
- Release signing certificate is the expected persistent certificate.

Record device model, Android version, build number, commit SHA, and any known defects.

## 7. Platform support

The current automated build/distribution workflows are Android APK workflows. Do not announce an iOS, web, desktop, or Play Store release based only on source folders being present. A platform requires its own build, signing, runtime, and release verification.
