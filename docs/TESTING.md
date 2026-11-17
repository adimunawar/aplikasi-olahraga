# Testing and Quality Gates

Testing is a product reliability requirement, not a final cleanup step. Every behavior change must include a verification plan.

## 1. Required local checks

Run from the repository root:

    dart format --output=none --set-exit-if-changed lib test
    flutter analyze
    flutter test

Generate test coverage when validating a feature or preparing a release:

    flutter test --coverage

The coverage report is written to coverage/lcov.info.

## 2. CI behavior

The current GitHub Actions workflow is .github/workflows/flutter-ci.yml.

It pins Flutter 3.47.9 and runs:

- Dependency installation with the lockfile enforced.
- Static analysis with flutter analyze --no-pub --no-fatal-infos.
- Flutter tests with flutter test --no-pub --coverage.
- Coverage artifact upload when the report exists.

Pull requests targeting develop, staging, and main run these quality jobs. A successful run on another branch is not implied until a qualifying workflow run exists.

The repository currently uploads coverage but does not define a minimum percentage threshold. Do not claim a coverage gate exists.

## 3. Test pyramid

### Unit tests

Use unit tests for deterministic rules and mapping:

- Dynamic program generation.
- Progression Engine decisions.
- Workout schedule calculations.
- Prescription and set validation.
- BMI and weight analytics.
- Domain model parsing and serialization.
- Date/time and duration calculations.

Pure domain/application logic should not require a widget test environment.

### Repository and data-source tests

Cover:

- Remote success and response mapping.
- Empty remote response.
- Timeout/network failure.
- Local cache fallback.
- Invalid/missing fields.
- Local persistence after remote success.
- Local data preservation after remote failure.
- Cloud Sync disabled and ineligible identities.
- Duplicate and idempotent writes.
- Migration and foreign-key behavior.

Prefer fake repositories/data sources or test database instances over live production services.

### Widget tests

Cover user-visible states and interactions:

- Loading, success, empty, and error.
- Retry and pull-to-refresh.
- Form validation and disabled submit.
- Workout timer and set progression.
- Resume/abandon confirmation.
- Media loading/error/poster fallback.
- Accessibility semantics and layout at representative screen sizes.

Avoid tests that only assert that a widget exists without verifying meaningful behavior.

### Integration tests

Use integration/device tests for flows whose correctness depends on platform behavior:

- SQLite persistence across app restart.
- Start, interrupt, resume, and complete a workout.
- Video playback on supported devices.
- Android permission and lifecycle behavior.
- Signed release installation/update.
- Firebase Crashlytics/Analytics configuration.
- Supabase RLS and authenticated account isolation.

Integration tests requiring external services must use a staging/test project and test identities. Never point destructive tests at production user data.

## 4. High-risk regression suites

The following areas deserve dedicated tests before major refactors:

| Area | Required guarantees |
|---|---|
| Database migration | Existing user data survives every supported upgrade |
| Exercise catalog | Remote errors do not erase local catalog |
| First installation | Empty cache produces a recoverable state |
| Progress | No demo values appear as real user activity |
| Workout recovery | Active session restores correct elapsed time, exercise, and set |
| Progression Engine | Same input produces deterministic decision |
| Cloud Sync | No cross-user read/write; consent is enforced |
| Media lifecycle | Controller is disposed and stale playback is not retained |

## 5. Test data policy

- Use fixtures with explicit names and known values.
- Keep fixtures out of production repository fallback paths.
- Do not use personal production data in tests.
- Do not place credentials, signed URLs, or private identifiers in fixtures.
- Make time-dependent tests deterministic with injected clocks or explicit dates.
- Clean up temporary files and database instances.

## 6. Failure reporting

When a test fails:

1. Reproduce the failure with the narrowest test command.
2. Identify whether the failure is test setup, environment, product behavior, or a regression.
3. Fix the product behavior or correct the test if its expectation is invalid.
4. Do not delete/skip a test merely to unblock CI.
5. If the environment prevents a test from running, explain the unverified risk in the PR.
