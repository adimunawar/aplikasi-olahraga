# ADR-0003: Keep Workout Rules Deterministic and Independent of Widgets

- **Status:** Accepted
- **Date:** 2026-11-17
- **Decision owners:** Workout Coach maintainers

## Context

Workout Coach calculates program schedules, workout prescriptions, set targets, training progression, and progress metrics. These rules need to be consistent across screens and straightforward to test. If they live inside widget callbacks or screen state, UI refactors can accidentally change domain behavior.

## Decision

1. Put deterministic workout calculations in pure Dart domain/application services.
2. Keep UI responsible for displaying state and forwarding user actions.
3. Keep persistence and remote synchronization in repository/data implementations.
4. Evaluate progression from recorded set performance using explicit inputs.
5. Persist progression decisions and a user-readable reason where the product needs an audit trail.
6. Inject clocks or pass explicit timestamps for time-dependent calculations that need deterministic tests.

## Consequences

### Positive

- Calculation rules can be unit-tested without rendering Flutter widgets.
- UI redesigns do not need to rewrite workout formulas.
- Progression decisions can be inspected and explained.
- Different screens can reuse the same schedule and prescription rules.

### Trade-offs

- Some flows need an application service to coordinate multiple repositories.
- Input/output models must be explicit.
- Historical decisions need enough persisted context to remain explainable.

## Known implementation gaps

- Some large screens and controllers still own orchestration that should be extracted incrementally.
- Progress and analytics fallbacks must not present sample values as actual user activity.
- The progression engine's inputs, persisted decisions, and displayed explanations should remain covered by regression tests.

## Alternatives considered

- **Place all calculations in screens:** rejected because this couples business behavior to rendering and makes isolated testing difficult.
- **Move every method into a generic use-case class:** rejected because unnecessary abstractions increase navigation cost without improving boundaries.
