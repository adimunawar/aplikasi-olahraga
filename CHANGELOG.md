# Changelog

All notable user-visible changes to Workout Coach are recorded here.

This changelog starts with the documentation baseline for the current portfolio hardening effort. It does not attempt to reconstruct an unverified release history.

## Unreleased

### Added

- Added `WorkoutPrescriptionResolver` to dynamically resolve exercise prescriptions (target sets, rep ranges, target duration, and rest intervals) from program day items and explicit program configurations.
- Added duration-based exercise tracking support (`TrackingType.duration`), displaying target seconds and duration units instead of repetition counts for isometric exercises.
- Added `WorkoutSessionEmptyState` to present an honest, recoverable empty state when an active workout is opened with no exercises, eliminating fake dummy exercise generation.

### Changed

- Updated `RestTimerScreen` back navigation: the top-left back button now safely exits the session (`onExitSession`) while preserving the `in_progress` state for later resumption, separating it from the "Skip Rest" action.
- Added responsive layout scaling to `RestTimerScreen` using adaptive progress ring sizing and scrollable layout to prevent vertical overflows on small viewports and large accessibility text scaling.

### Fixed

- Added generation token guard to `ActiveWorkoutVideoCard` to prevent stale asynchronous video initializations from overwriting newer video state or leaking audio during rapid exercise transitions.
- Resolved dynamic localization for workout session program titles (`_programTitle`), respecting the active user locale with domain and Slang translation fallbacks.
- Keep the active workout screen open when session finalization fails, with a localized retry action that reuses the same session.
- Prevent "Finish Workout Now" from finalizing a session until preparation succeeds and a real in-progress session ID is available; disable the options menu while preparation is pending or failed.
- Keep profile lookup optional and time-bounded, snapshot early-finish counts before finalization, and prevent duplicate completion or session abandonment races.

### Documentation

- Added AGENTS.md as the mandatory engineering and contributor contract.
- Replaced the legacy README with a portfolio-oriented project overview.
- Aligned architecture documentation with the current Flutter, Riverpod, SQLite, Supabase, media, and CI implementation.
- Added development, data synchronization, testing, security, release, and contribution guides.
- Added architecture decision records and a pull request template.
