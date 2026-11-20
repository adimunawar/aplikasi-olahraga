# Workout Coach

A personalized home-workout application built with Flutter. The project combines workout planning, exercise guidance, active training sessions, progression logic, and progress tracking with a local-first data foundation.

> **Project status:** Active portfolio project. The repository contains working product flows and engineering foundations, while several areas are still being hardened. Read the documentation and current code before treating any capability as production-ready.

## Product overview

Workout Coach is designed to help people train consistently at home with structured programs and useful feedback after each session.

The current implementation includes:

- Personalized onboarding and workout preferences.
- Dynamic workout-program generation from a user profile and exercise catalog.
- Exercise catalog and exercise-detail experiences.
- Exercise demonstration playback from remote video URLs.
- Active workout sessions with sets, repetitions/time targets, rest periods, and session recovery.
- Set-level training records, including RIR-related fields.
- A rule-based progression engine that evaluates training performance and produces explainable progression decisions.
- Workout history, body measurements, progress metrics, and nutrition guidance screens.
- Indonesian and English localization infrastructure.
- Optional Firebase Analytics and Crashlytics integration.

The list describes implemented areas in the repository; it is not a claim that every flow is complete on every platform. See [Known limitations](#known-limitations).

## Engineering highlights

| Concern | Current approach |
|---|---|
| Client | Flutter / Dart |
| State management | Riverpod 2.x |
| Navigation | GoRouter |
| Local persistence | SQLite through sqflite |
| Remote catalog and optional cloud data | Supabase |
| Media delivery | Remote media URLs, including R2 proxy resolution |
| Video playback | video_player |
| Crash reporting and analytics | Firebase Crashlytics and Analytics |
| Localization | slang / slang_flutter |
| CI | GitHub Actions |
| Android tester distribution | Firebase App Distribution |

### Architecture at a glance

**Flutter Screens and Widgets** → **Riverpod Controllers and State** → **Application Services / Use Cases** → **Domain Models and Repository Contracts** → **Repository Implementations** → **SQLite and Supabase**

Media is delivered through remote storage/CDN URLs. Firebase provides optional crash reporting and analytics on supported native platforms.

The flow describes intended dependency boundaries. Some legacy screens still construct repositories or access the database directly; those areas are documented as refactoring work in [ARCHITECTURE.md](ARCHITECTURE.md).

### Data ownership

- The exercise and published-program catalog is remote-managed through Supabase and cached locally for application use.
- SQLite is the local persistence baseline for personal profile, workout, and progress data.
- Personal cloud synchronization requires a non-anonymous Supabase Auth session and explicit Cloud Sync consent for that account.
- Exercise videos are referenced by URL; large media files are not intended to be bundled into the application.
- The web database fallback is in-memory and is not equivalent to durable SQLite persistence.

See [Data and synchronization](docs/DATA_AND_SYNC.md) and [Security](SECURITY.md).

## Repository layout

```
.
├── AGENTS.md                 # Mandatory engineering rules for contributors and agents
├── ARCHITECTURE.md           # Current architecture and known boundaries
├── README.md                 # Project overview and entry point
├── CONTRIBUTING.md           # Branch, commit, and pull-request workflow
├── CHANGELOG.md              # User-visible change history
├── SECURITY.md               # Vulnerability reporting and security baseline
├── lib/
│   ├── core/                 # Shared configuration, database, routing, theme, services
│   ├── features/             # Feature-first application modules
│   └── i18n/                 # Generated localization resources
├── assets/                   # Bundled images and required static assets
├── supabase/
│   ├── migrations/           # Forward-only database and RLS migrations
│   └── seed_exercises.sql    # Exercise catalog seed data
├── test/                     # Unit, widget, and feature tests
├── docs/                     # Development, data, testing, release, and ADR documents
└── .github/workflows/        # CI and Android staging distribution
```

## Getting started

### Prerequisites

- Flutter **3.50.0** (the version pinned in GitHub Actions).
- Dart SDK compatible with the constraint in pubspec.yaml (currently ^3.13.7).
- Android Studio / Android SDK for Android development.
- JDK 17 for Android Gradle builds.
- Supabase project access for remote catalog functionality.
- Android Firebase configuration for builds that apply the Google Services Gradle plugin.

### Install dependencies

```bash
flutter pub get
```

### Configure Supabase

The app reads these compile-time values:

- SUPABASE_URL
- SUPABASE_ANON_KEY

The repository currently contains fallback public-client configuration in SupabaseConfig. For another environment, pass values with Dart defines rather than editing source:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLISHABLE_KEY
```

A publishable/anon key is a client key, not a server secret. Database security MUST come from correct RLS policies and grants. Never use a Supabase service-role or secret key in the Flutter app.

### Configure Firebase on Android

The Firebase bootstrap is optional at runtime, but the Android Gradle plugin is configured for Google Services and the repository CI expects the native configuration file for release builds.

1. Obtain the Android app's google-services.json from the Firebase project.
2. Place it at android/app/google-services.json.
3. Keep it out of Git; the repository ignores this file.
4. Follow [Firebase setup](docs/FIREBASE_SETUP.md) for CI secrets and collection behavior.

For Android release signing, follow [Android release signing](docs/android-release-signing.md).

### Run the application

After local Android configuration is ready:

```bash
flutter run
```

For a clean environment setup and platform caveats, read [Development setup](docs/DEVELOPMENT.md).

## Quality checks

Run these commands before opening a pull request:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Generate local test coverage:

```bash
flutter test --coverage
```

The CI pipeline runs static analysis and tests on pull requests to develop, staging, and main. See [Testing and quality gates](docs/TESTING.md).

## CI/CD

- .github/workflows/flutter-ci.yml runs analysis and tests for pull requests targeting develop, staging, and main; it also validates pushes to main.
- .github/workflows/build-staging.yml builds and distributes a signed Android staging APK when changes are pushed to staging.
- Manual workflow dispatch on develop can run the configured signed APK build path.

Release signing and Firebase distribution require repository secrets. See [Release process](docs/RELEASE.md).

## Documentation

| Document | Purpose |
|---|---|
| [AGENTS.md](AGENTS.md) | Mandatory rules for every feature, fix, refactor, and documentation change |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Layers, data flow, ownership, and known technical debt |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Branching, commits, pull requests, and review expectations |
| [Development setup](docs/DEVELOPMENT.md) | Toolchain, environment, local setup, and run commands |
| [Data and synchronization](docs/DATA_AND_SYNC.md) | Local persistence, catalog caching, Cloud Sync, and media |
| [Testing](docs/TESTING.md) | Test strategy and required quality checks |
| [Security](SECURITY.md) | Vulnerability reporting and security rules |
| [Repository security](docs/REPOSITORY_SECURITY.md) | RLS, branch protections, and CI security configuration |
| [Release](docs/RELEASE.md) | Android signing, staging, and distribution |
| [ADRs](docs/adr/) | Records of important technical decisions |
| [Firebase setup](docs/FIREBASE_SETUP.md) | Crashlytics and Analytics configuration |
| [Product Scope & Delivery Status](docs/PRODUCT_SCOPE_AND_STATUS.md) | Product direction and implementation checklist, including current gaps |
| [Code of Conduct](CODE_OF_CONDUCT.md) | Collaboration and participation expectations |

## Known limitations and active hardening areas

The following are known from the repository snapshot and MUST NOT be hidden in a project demonstration:

- AppDatabase is a large legacy persistence class. Its schema is still opened at version 1 and contains ad-hoc compatibility ALTER statements; a formal versioned migration sequence is needed.
- Some screens still construct concrete repositories or call AppDatabase.instance directly. Dependency boundaries are being improved incrementally.
- Progress-related code contains fallback/sample values. Those values must be removed from production data paths before presenting analytics as real user activity.
- Exercise catalog first-install behavior needs an explicit, tested path for an empty local cache when the network is unavailable.
- Cloud Sync has consent and account checks, but a complete in-app authentication journey and durable retry/outbox behavior must be verified before describing cloud synchronization as fully end-to-end.
- The web persistence fallback is in-memory; native SQLite behavior must not be assumed on web.
- iOS and desktop release pipelines are not established by the current Android-focused CI workflows.

## Project status and licensing

This repository is maintained as a portfolio and engineering showcase. Product scope, implementation status, and known gaps are documented rather than implied.

No open-source license is currently declared in this repository. Unless a license is added by the maintainer, do not assume permission to redistribute, modify, or use this code in another product.

## Flutter Web database setup

The Web target uses `sqflite_common_ffi_web`, which stores the SQLite database in browser IndexedDB. Before running or building the Web app, install dependencies and generate the required SQLite WebAssembly and worker assets:

```bash
flutter pub get
dart run sqflite_common_ffi_web:setup
flutter run -d chrome --web-port 8080
```

The setup command creates `web/sqlite3.wasm` and `web/sqflite_sw.js`. Keep both files in the project or run the setup command in your Web build pipeline before `flutter build web`. Browser data is scoped to the site origin (including its port); changing the local development port uses a separate IndexedDB store. Web support in `sqflite_common_ffi_web` is experimental.
