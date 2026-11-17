# Architecture

This document describes the architecture that exists today, the target boundaries for new code, and the legacy areas that must be improved incrementally. **AGENTS.md is the mandatory implementation contract.**

## 1. Architectural goals

Workout Coach uses a feature-first structure with layered boundaries. The goal is to keep workout rules testable, data access replaceable, and screens focused on user interaction.

The architecture is guided by:

- Separation of concerns.
- Dependency inversion at repository boundaries.
- Local persistence for reliable workout experiences.
- Explicit ownership and consent for personal cloud data.
- Deterministic domain logic.
- Observable failures and testable state transitions.

This is a pragmatic architecture. Do not introduce interfaces, services, or layers that do not protect a real responsibility.

## 2. High-level dependency flow

Presentation (screens/widgets) → Riverpod state/controllers → Application services/use cases → Domain models and repository contracts → Data repository implementations → SQLite and Supabase.

Media is delivered through remote storage/CDN URLs. Firebase provides optional crash reporting and analytics on supported native platforms.

Expected dependency direction:

1. Presentation invokes controller/provider state and application/domain abstractions.
2. Application coordinates use cases and repository contracts.
3. Domain defines rules and contracts without depending on Flutter or infrastructure.
4. Data implements contracts and maps infrastructure records to domain models.

Legacy exceptions exist and are listed in Section 9. New code MUST NOT extend those exceptions.

## 3. Feature-first structure

The primary application code lives under lib/features/. A feature should own its presentation, domain, application, and data code where those layers are needed.

Example:

    lib/features/workout_session/
    ├── application/              # Session orchestration and calculations
    ├── data/
    │   ├── datasources/           # Local/remote I/O
    │   └── repositories/          # Repository implementation
    ├── domain/
    │   ├── models/                # Session and prescription models
    │   └── repositories/          # Repository contracts
    └── presentation/
        ├── controllers/           # Riverpod state and UI orchestration
        ├── screens/
        └── widgets/

Shared cross-feature concerns belong under lib/core/ only when they are genuinely shared. Do not move a feature-specific rule into core merely to make it globally accessible.

## 4. Current technology and responsibilities

| Technology | Responsibility |
|---|---|
| Flutter / Dart | Mobile UI and application logic |
| Riverpod 2.x | State management and dependency providers |
| GoRouter | Declarative navigation and nested shell navigation |
| sqflite | Native local relational persistence |
| SharedPreferences | Small device preferences, onboarding and consent support |
| Supabase | Exercise/program catalog and consent-controlled personal cloud operations |
| video_player | Remote exercise video playback |
| Firebase Crashlytics | Crash reporting on supported native platforms |
| Firebase Analytics | Product analytics on supported native platforms |
| slang | Indonesian/English localization resources |

The dependency versions and SDK constraints are defined in pubspec.yaml. CI currently pins Flutter 3.47.9.

## 5. Data ownership and flows

### 5.1 Exercise catalog

- Supabase is the remote catalog source.
- Exercise records include structured instruction fields and media URLs such as video_url.
- The application maps remote records to domain models and persists catalog records into SQLite.
- UI screens should read the repository/local catalog rather than issue direct Supabase queries.
- First-install behavior must account for an empty SQLite cache and unavailable network. Do not assume a local catalog exists.

### 5.2 Personal profile and workout data

- SQLite is the local persistence baseline.
- A non-anonymous Supabase Auth session is required for personal cloud identity.
- Cloud Sync additionally requires explicit per-account user consent.
- Remote reads/writes must be owner-scoped and protected by RLS.
- Disabling Cloud Sync leaves local data intact.

### 5.3 Active workout lifecycle

The active workout flow coordinates:

- A scheduled program/session and exercise prescriptions.
- An in-progress session record.
- Set-by-set records such as target/actual reps, duration, load, RIR, and completion status.
- Elapsed time and session recovery after interruption.
- Completion or early-ending semantics.
- Progression evaluation from the recorded performance.

These rules belong in domain/application/repository code, not in widget build methods.

### 5.4 Media

- Exercise records contain media URLs; video binaries are delivered remotely.
- MediaUrlResolver currently resolves supported R2 public URLs through the configured media proxy and passes other URLs through.
- ActiveWorkoutVideoCard uses VideoPlayerController.networkUrl for HTTP(S) sources and disposes its controller.
- A bounded local media cache is a future hardening task; do not claim full offline video availability until implemented and tested.

## 6. State management and navigation

- Riverpod 2.x is the project's state and dependency-management system.
- Existing modules use providers and StateNotifier patterns. New code must follow the chosen feature convention and keep state immutable.
- Async state must distinguish loading, data, empty, and failure.
- Navigation is centralized in lib/core/router/app_router.dart and uses GoRouter.
- Screens should receive dependencies through providers rather than instantiate concrete repositories or global database singletons.

## 7. Persistence and schema evolution

The current native database is home_bulking_coach.db, accessed through AppDatabase and SQL definitions in DatabaseTables.

**Current implementation gap:** the database is opened at version 1 and compatibility columns are added through ad-hoc ALTER TABLE calls. This is not the target migration strategy.

Target strategy:

1. Keep a single explicit schema version.
2. Increment the version for every schema change.
3. Implement ordered, forward-only migrations.
4. Enable SQLite foreign-key enforcement during database configuration.
5. Test fresh creation and every supported upgrade path.
6. Never discard user workout data during upgrades.

The existing web fallback stores data in in-memory collections. It is useful for preview/test scenarios but is not durable persistence.

## 8. Observability and platform configuration

- Firebase initialization is optional at runtime and is guarded so monitoring setup failure does not block app startup.
- Crashlytics and Analytics collection are configured to be enabled by default in Release and disabled by default in Debug/Profile, with Dart defines available for local verification.
- Android release signing and Firebase App Distribution are handled by GitHub Actions workflows.
- Current CI validates Flutter code and tests; Android staging distribution is the established delivery path.

See Development, Testing, Security, and Release documentation under docs/.

## 9. Known architectural debt

These are explicit refactoring targets, not patterns to copy into new code:

1. **Large persistence class:** AppDatabase combines schema setup, migrations, queries, fallback storage, and multiple entity operations. Extract cohesive DAOs/repositories as features are touched.
2. **Direct data access from screens:** some legacy screens construct ExerciseRepositoryImpl or call AppDatabase.instance. Move new and touched flows behind Riverpod providers/controllers.
3. **Duplicated catalog refresh:** catalog refresh can be triggered by multiple screens. Centralize freshness, in-flight de-duplication, and retry ownership.
4. **Sample values in production paths:** remove fake progress/analytics fallback values. A real empty state must be zero/empty; demo fixtures must be explicit.
5. **Migration hardening:** replace swallowed ALTER errors with versioned migrations and tests.
6. **Sync reliability:** remote write failures must be visible and recoverable. A durable outbox/retry queue is not assumed to exist.
7. **Theme preference behavior:** ensure persisted theme preference is actually applied by the app root before describing light/dark mode as supported.
8. **Domain purity:** media URL rewriting and other infrastructure-specific concerns should remain outside domain models.

Refactor incrementally. Each migration should include characterization tests or behavior tests before removing the legacy path.

## 10. Decision records

Material technical decisions are recorded under docs/adr/. Add an ADR when a decision changes data ownership, synchronization, security, state management, media delivery, persistence, or a cross-feature contract.
