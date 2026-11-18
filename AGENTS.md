# AGENTS.md

> **Authoritative engineering contract for this repository.**
> Every human contributor, coding agent, and automated implementation tool MUST follow this file before changing application code, tests, database schema, CI, or documentation.

## 1. Mandatory workflow

Before making any change:

1. Read this file completely.
2. Read the relevant sections of README.md, ARCHITECTURE.md, and applicable guides under docs/.
3. Inspect the current implementation, callers, providers, routes, persistence paths, and tests. Never implement from a filename or assumption alone.
4. Identify behavior that must remain unchanged and the failure cases the change must handle.
5. Make the smallest coherent change that solves the requirement. Do not combine unrelated refactors with a feature or bug fix.
6. Add or update tests for the behavior.
7. Run the applicable quality checks in Section 11.
8. Update documentation when architecture, data contracts, setup, configuration, behavior, or operations change.
9. In the final change summary, state what changed, what was tested, and what was not tested. Never claim a check passed unless it was actually run and passed.

If repository code and documentation disagree, inspect code and tests, record the discrepancy, and update the documentation in the same change. Do not silently preserve contradictory guidance.

## 2. Product and engineering principles

Workout Coach is a Flutter home-workout application with personalized programs, an exercise catalog, active workout sessions, training progression, and progress tracking.

All changes MUST prioritize:

- Correctness of workout, profile, and progress data.
- Predictable behavior across app restarts and network failures.
- Clear separation of UI, business rules, and infrastructure.
- Privacy by default for personal user data.
- Testability and maintainability over clever abstractions.
- Accessible, responsive, and consistent interaction design.
- Honest product states: never present placeholder values as real user data.

Do not add a feature merely to make the project appear more complex. Improve an existing capability when that provides more product value.

## 3. Architecture and dependency rules

Use feature-first, layered architecture. Follow existing feature boundaries and improve them incrementally.

### 3.1 Layer responsibilities

- **Presentation:** screens, widgets, UI state, and user interaction. MUST NOT contain SQL, Supabase queries, filesystem access, networking, or business calculations.
- **Application:** use cases and orchestration that coordinate business operations or multiple repositories.
- **Domain:** business entities, value objects, rules, and repository contracts. Keep this layer framework-independent and free of Flutter, SQLite, Supabase, and widget dependencies.
- **Data:** repository implementations, DTO/entity mapping, local/remote data sources, persistence, and synchronization mechanics.

Expected dependency direction:

- Presentation may depend on application and domain abstractions.
- Application may depend on domain abstractions.
- Data implements domain repository contracts.
- Domain MUST NOT depend on presentation, application infrastructure, or data implementations.

Do not introduce an application/use-case class for a trivial one-line operation. Add an abstraction when it protects a real boundary or removes repeated orchestration.

### 3.2 Dependency injection

- Use Riverpod providers for dependency construction and access.
- UI widgets MUST NOT instantiate concrete repositories or data sources.
- Avoid direct calls to global singletons from screens/controllers when a provider can inject the dependency.
- Keep constructors explicit and dependencies replaceable in tests.
- Do not create a service locator or a second dependency-injection framework.

The application currently uses Riverpod 2.x (flutter_riverpod 2.6.1) and includes StateNotifierProvider patterns. Follow the established provider lifecycle in touched features. Do not mix state-management styles in the same feature without a documented migration decision.

### 3.3 Screen and class size

- Keep screens focused on composition, rendering, and event forwarding.
- Extract independent sections, dialogs, and reusable interactions into widgets.
- Move orchestration out of build methods and large StatefulWidget classes.
- Split classes when they have multiple reasons to change; do not split solely to hit an arbitrary line count.
- Avoid adding new responsibilities to large legacy files such as AppDatabase, WorkoutsScreen, PlansScreen, and WorkoutSessionScreen. Prefer extracting a cohesive component or service first.

## 4. State, navigation, and UI requirements

### 4.1 State management

- UI state MUST be explicit and immutable.
- Do not mutate lists, maps, or objects already held by state. Create new values and publish a new state.
- Keep loading, success, empty, error, and offline/degraded states distinguishable.
- Avoid storing values in state that can be derived reliably from other state.
- Prevent stale asynchronous responses from overwriting newer state.
- Check lifecycle/mounted status before updating a disposed widget or notifier.
- Dispose timers, stream subscriptions, animation controllers, and media controllers deterministically.

### 4.2 UI behavior

Every screen that loads data MUST define relevant states:

- Initial/loading.
- Success with data.
- Empty/no data.
- Error with a meaningful retry path where retry is possible.
- Offline or stale-cache state where network availability affects freshness.
- Disabled, submitting, and validation states for relevant interactions.

Never display sample workout counts, calories, streaks, progress, or history as if they belonged to the current user. Demo fixtures MUST live in test/demo-only code and MUST be selected explicitly.

### 4.3 Navigation

- Use GoRouter through the central router/provider.
- Keep route names, paths, and typed route arguments centralized.
- Do not introduce ad-hoc MaterialPageRoute navigation.
- Use Navigator only for local route-owned UI such as dialogs, menus, or bottom sheets when appropriate.
- Validate route arguments and provide a safe fallback/error state for invalid input.

### 4.4 Design system and accessibility

- Reuse tokens from lib/core/theme/ instead of introducing arbitrary colors, typography, spacing, or radii.
- Reuse shared components where they already express the required behavior.
- Do not duplicate shared button, card, badge, or image-loading patterns with slightly different styling.
- Keep tap targets comfortable for workout use; use at least 48 logical pixels where practical.
- Support text scaling, screen sizes, semantic labels, and sufficient contrast.
- User-facing text MUST use the localization system. Do not add hard-coded UI copy when a translation key is appropriate.
- Do not change the product design system implicitly. Update design documentation when the system intentionally changes.

## 5. Data ownership, persistence, and synchronization

### 5.1 Data ownership

Use this distinction:

- **Exercise and published program catalog:** Supabase is the remote catalog source; SQLite is the on-device cache used by the app.
- **Personal user data:** SQLite is the local persistence baseline. Remote personal-data synchronization is allowed only for a non-anonymous Supabase Auth user who explicitly enabled Cloud Sync for that account.
- **Workout media:** store media files in object storage/CDN and store URLs/metadata in exercise records. Do not bundle every video in the application package.
- **Small local preferences:** use existing preference/localization mechanisms where suitable; do not place structured workout history in key-value storage.

Do not assume a successful cloud fetch means the local cache is updated. Verify both the write and mapping path.

### 5.2 Offline-first behavior

- User-facing workout actions MUST remain usable without a network connection when required data is already stored locally.
- UI reads SHOULD use the local repository/cache first where freshness permits.
- Remote refresh MUST have timeout/error handling and MUST NOT erase valid local data on an empty or failed response.
- First-install behavior MUST be explicit. If a required catalog is unavailable and no local seed/cache exists, show a recoverable setup state; do not generate a broken program from an empty list.
- Do not fetch the same catalog independently from every screen. Centralize freshness policy and synchronization ownership.
- Failed writes MUST be observable. Never silently discard an error with an empty catch block.
- Do not claim that a durable outbox/retry queue exists unless it has actually been implemented and tested.

### 5.3 Cloud Sync consent and account isolation

- A login alone MUST NOT enable personal-data synchronization.
- Require an authenticated, non-anonymous Supabase user AND explicit per-account Cloud Sync consent.
- Disabling Cloud Sync MUST stop future remote reads/writes without deleting local data.
- Never send local placeholder identities such as default_user to personal cloud tables.
- Every personal-data query/write MUST be scoped to the authenticated user and protected by Supabase RLS.
- Do not trust client-side filtering as an authorization boundary.
- Never put Supabase secret/service-role credentials in Flutter code, assets, build arguments committed to source, or Git history. A publishable/anon key is not a server secret and does not replace RLS.

### 5.4 SQLite and migrations

- All schema changes MUST be versioned and implemented as explicit, forward-only migrations.
- Increment the database version when schema changes.
- Do not use broad try/catch blocks around migration statements to hide failures.
- Preserve existing user data. Do not drop/recreate a production database to simplify a migration.
- Enable and test foreign-key behavior, including cascade rules.
- Use parameterized queries; never interpolate user input into SQL.
- Keep database access behind repository/data-source boundaries.
- Add tests for migration paths and important constraints.
- Web/desktop in-memory fallbacks MUST NOT be described as durable offline persistence. Document platform limitations accurately.

## 6. Domain and workout correctness

- Keep calculation rules deterministic and independent of widgets.
- Put workout prescriptions, set/repetition rules, progression decisions, BMI/weight calculations, schedule calculations, and similar rules in pure Dart domain/application services.
- Use explicit units in model names and APIs (for example, durationSeconds, weightKg, heightCm).
- Validate minimum/maximum values and invalid state transitions at the boundary.
- Persist enough information to restore an active workout after interruption.
- Make start, pause/resume, complete, incomplete, and abandon semantics explicit and idempotent where possible.
- Do not recompute historical results from mutable current settings when a persisted snapshot is required for consistency.
- Keep progression decisions explainable: persist relevant inputs/previous prescription, next prescription, decision, and user-readable reason where the product requires an audit trail.

## 7. Media and resource lifecycle

- Keep video/image URLs as data; do not embed large media binaries in Dart source or JSON metadata.
- Validate empty/invalid URLs and provide poster/error fallbacks.
- Dispose VideoPlayerController and other media resources when the owning widget/controller is disposed or the media source changes.
- Handle initialization failure, network interruption, buffering, and retry without leaving stale controllers attached.
- Use the central media URL resolver or a provider/service abstraction; do not duplicate URL rewriting rules in widgets.
- Do not log signed URLs, authorization headers, or private media tokens.
- Cache media deliberately, with bounds/eviction and clear offline behavior. Do not create an unbounded cache.

## 8. Error handling and observability

- Never use an empty catch block for an operation whose failure affects correctness, persistence, sync, or user experience.
- Convert infrastructure errors into meaningful failures at repository/application boundaries.
- Preserve original errors and stack traces for diagnostics where useful.
- UI messages MUST be actionable and user-safe; do not show raw SQL, tokens, or stack traces to users.
- Debug logs MUST NOT expose secrets, personal identifiers, private profile data, measurements, or signed media URLs.
- Crashlytics/Analytics events MUST NOT contain sensitive personal data.
- Avoid excessive logging in hot paths and per-frame media callbacks.

## 9. Security and privacy

- Treat all Supabase rows and remote responses as untrusted input.
- Enforce RLS on every personal table and validate owner relationships in policies.
- Never put service-role keys, Firebase service account JSON, Android keystores, signing passwords, or private API credentials in the repository.
- Keep native client configuration separate from server credentials.
- Request only permissions a feature needs and explain why.
- Do not upload body measurements, workout history, names, or other personal data without documented account/consent conditions.
- For SQL/RLS/migration changes, update SECURITY.md and docs/REPOSITORY_SECURITY.md and include a verification plan.

## 10. Documentation requirements

Update relevant documentation in the same change:

- Product behavior or feature scope: README.md and relevant product documentation.
- Layer boundaries/data flow: ARCHITECTURE.md.
- Setup, dependencies, environment variables: docs/DEVELOPMENT.md.
- Test coverage/quality gates: docs/TESTING.md.
- Auth, RLS, privacy, secrets: SECURITY.md and/or docs/REPOSITORY_SECURITY.md.
- Build/signing/distribution: docs/RELEASE.md.
- A material architectural choice: add an ADR under docs/adr/.
- User-visible behavior change: update CHANGELOG.md.

Do not update documentation with claims that have not been verified in code or CI.

## 11. Required quality checks

Before requesting review, run from the repository root:

- dart format --output=none --set-exit-if-changed lib test
- flutter analyze
- flutter test

For coverage, run flutter test --coverage.

The current GitHub Actions workflow pins Flutter 3.47.9 and runs:

- flutter analyze --no-pub --no-fatal-infos
- flutter test --no-pub --coverage

If a change touches Android/native configuration, build the affected Android variant when local credentials/configuration permit. If a check cannot be run, state the reason and remaining risk.

Do not weaken analyzer rules, delete/skip tests, suppress lints broadly, or change CI to make a failing change appear green. Any justified exception MUST be narrow, documented, and reviewed.

## 12. Change and pull-request discipline

- Use a focused branch: feat/<name>, fix/<name>, refactor/<name>, docs/<name>, test/<name>, or chore/<name>.
- Use clear commit messages such as feat(workout): add session recovery.
- Keep a pull request focused and explain motivation, implementation, user impact, migration impact, and verification.
- Include screenshots/video for UI changes when practical.
- Include a regression test for a bug fix.
- Call out known limitations, behavior changes, and follow-ups explicitly.
- Do not commit generated build output, local machine paths, credentials, or unrelated formatting churn.

## 13. Definition of done

A change is complete only when:

- The acceptance behavior is implemented.
- Existing behavior and data are preserved unless intentionally changed.
- Error, empty, loading, and offline states are handled where relevant.
- Code follows the dependency and ownership rules above.
- Relevant tests are added/updated and pass, or unrun checks are clearly disclosed.
- No secrets or personal data are exposed.
- Documentation and changelog are updated where required.
- The pull request summary accurately reports the work and verification.

**When uncertain, stop and inspect the real call path and data contract. Do not guess.**
