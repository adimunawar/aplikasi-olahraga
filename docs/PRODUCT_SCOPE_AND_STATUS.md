# Product Scope & Delivery Status

> **Document type:** Product scope, delivery inventory, and implementation status  
> **Product:** Workout Coach  
> **Status snapshot:** 17 November 2026  
> **Platform baseline:** Flutter / Android-focused  
> **Source of truth:** Current repository implementation and automated tests

## 1. Purpose

This document defines the product direction of Workout Coach and provides a transparent checklist of what is implemented, partially implemented, and not yet delivered.

It is a living delivery document, not a statement that the application is production-ready. A feature is marked as implemented only when its implementation can be found in the repository. Relevant automated tests are referenced where available. A checked item does not, by itself, guarantee release readiness, complete platform coverage, or successful production operation.

### Status legend

- [x] **Implemented** — an application flow or capability exists in the current codebase.
- [ ] **Partially implemented** — some code or UI exists, but known gaps remain before the requirement can be considered complete.
- [ ] **Not implemented** — no working implementation has been verified in the current codebase.

## 2. Product Overview

Workout Coach is a home-workout application designed to help users build strength and muscle through structured training programs, exercise guidance, guided workout sessions, and measurable progress.

The product aims to make training easier to start, execute, and evaluate. It combines a beginner-friendly workout experience with a foundation for performance-based progression.

### Product vision

Build a reliable home-workout coach that helps users understand what to train, perform exercises with confidence, record their performance, and make informed decisions about future training.

### Product positioning

A guided home-workout application focused on structured programs, practical exercise education, consistent workout execution, and explainable progression.

### Primary audience

- People who want to build strength and muscle at home.
- Beginners who need clear exercise guidance and structured training.
- Returning exercisers who want a consistent and measurable workout routine.
- Users training with bodyweight or limited equipment.

### Core product principles

1. **Guided training:** make the next workout action clear and understandable.
2. **Progressive development:** use recorded performance to inform progression recommendations.
3. **Training safety:** account for limitations, fatigue, and reported pain before recommending increased difficulty.
4. **Reliable session tracking:** preserve workout records and recover active sessions where supported.
5. **Offline resilience:** keep essential workout data available locally after it has been downloaded or saved.
6. **Honest feedback:** show actual user activity; never present sample values as personal results.
7. **Maintainable engineering:** keep workout rules testable and separate from presentation and persistence concerns.

## 3. Current Delivery Status

The following status reflects the repository snapshot identified above. Review the relevant code and tests before using this document as a release checklist.

### 3.1 Implemented

#### Onboarding and user preferences

- [x] Multi-step onboarding screens for fitness goals, experience level, body profile, equipment, training limitations, weekly schedule, and preferred session duration.
- [x] Plan preview and plan-ready experiences.
- [x] User profile model and onboarding state used by the program creation flow.

#### Program planning and lifecycle

- [x] Program generation for supported weekly frequencies using predefined workout templates.
- [x] Program preview with overview and workout-split sections.
- [x] Program lifecycle calculation for not-started, active, completed, and expired states.
- [x] Unit tests for dynamic program generation and program lifecycle calculations.

#### Exercise catalog and guidance

- [x] Exercise domain model and repository boundary.
- [x] Supabase exercise-catalog retrieval with local SQLite persistence when remote catalog data is available.
- [x] Exercise list and exercise-detail screens.
- [x] Exercise guidance UI for movement demonstrations, execution steps, target muscle groups, metrics, tips, and common mistakes.
- [x] Video playback through the Flutter video player for supported media URLs.
- [x] Image-based demonstration fallback when a video URL is unavailable or cannot be played.

#### Workout execution

- [x] Active workout screen with exercise-by-exercise progression.
- [x] Set and repetition recording, including time-based exercise targets.
- [x] Rest timer and configurable per-exercise rest duration.
- [x] RIR-related set input and persistence fields.
- [x] Workout pause/resume controls and session completion flow.
- [x] Local SQLite persistence for workout sessions and set-level records.
- [x] Recovery of an existing in-progress session, including previously recorded sets.
- [x] Conflict handling when another in-progress session exists.
- [x] Automated tests for workout-session resume, set-save failure handling, and related session state behavior.

#### Progression logic and workout summary

- [x] Deterministic progression domain service.
- [x] Progression outcomes for progress, maintain, regress, recover, and reassess decisions.
- [x] Safety guards for missing performance data, reported pain/injury, and severe fatigue.
- [x] Progression decision and reason presentation in the workout-summary experience.
- [x] Unit tests for progression rules and safety guards.

#### Engineering foundation

- [x] Riverpod-based state management and GoRouter navigation are present in the application.
- [x] Indonesian and English localization infrastructure.
- [x] GitHub Actions workflow for Dart/Flutter analysis and automated tests on configured pull requests.
- [x] Android staging build and Firebase App Distribution workflow configuration.

### 3.2 Partially implemented

These capabilities have code or user-facing screens, but known limitations prevent them from being considered complete.

#### Program personalization

- [ ] Program generation uses predefined templates. It is not yet a fully validated program-design engine that consistently optimizes exercise selection, movement-pattern balance, equipment compatibility, recovery, and the user's available time.
- [ ] Equipment and limitation data are collected, but end-to-end validation that every generated workout is compatible with every selected profile still needs to be completed.
- [ ] Preferred duration influences some template selections, but the generator is not yet a robust duration optimizer with validated weekly-volume constraints.
- [ ] Initial assessment UI exists, but its end-to-end persistence, validation, and influence on subsequent program adaptation require further verification.

#### Exercise catalog and media delivery

- [ ] Supabase catalog data can be cached in SQLite, but first-install behavior when the device is offline and the local catalog is empty still needs a complete, recoverable experience.
- [ ] Video and image fallback behavior exists, but deliberate offline media caching, eviction, and guaranteed offline demonstration availability are not established.
- [ ] Exercise-content quality review, media attribution, and usage-rights verification must be completed before public distribution.

#### Progress and analytics

- [ ] Progress, workout-history, weight, activity, movement-volume, and milestone screens are present.
- [ ] Progress data is not yet reliable enough to be presented as a complete record of user performance. The repository still contains hard-coded sample values and fallback workout-history entries in production data paths.
- [ ] Some program progress indicators use fixed values rather than being derived from persisted workout history.
- [ ] Analytics calculations, empty states, error handling, and data consistency need further validation against real user records.

#### Profile, settings, and nutrition

- [ ] Profile and workout-preference screens exist, but preference behavior must be verified end to end. In particular, the saved theme selection is not yet applied consistently by the application root.
- [ ] Reminder-related screens exist, but reliable notification scheduling and lifecycle behavior require additional verification.
- [ ] Basic protein tracking and a recommendation engine are present. The experience is not yet fully integrated with the app's data architecture, user dietary preferences, and complete validation requirements.

#### Persistence, synchronization, and security

- [ ] Supabase is used for remote catalog access, and personal Cloud Sync has account-eligibility and explicit-consent checks.
- [ ] A complete in-app authentication journey and a durable synchronization workflow with retry/outbox handling have not been verified. Cloud Sync must not be described as fully end-to-end.
- [ ] Supabase migration files and row-level security policies exist in the repository, but the presence of a migration file does not prove that it has been deployed and verified in the hosted project.
- [ ] The SQLite schema still needs a formal, versioned migration sequence. The current database implementation contains legacy schema-update logic that must be replaced incrementally.
- [ ] Foreign-key enforcement and migration behavior require explicit verification and automated tests.
- [ ] Some screens and controllers still access the database singleton or construct concrete repositories directly. Dependency injection boundaries need further refactoring.
- [ ] Some repository paths still swallow errors or fall back to sample values. Failure states must become observable and actionable.

#### Quality and platform coverage

- [ ] Unit and widget tests cover selected onboarding, program, progression, and workout-session behavior, but they do not establish complete feature or integration coverage.
- [ ] Device-level verification is still required for interruption recovery, media playback, permissions, and release installation.
- [ ] Android is the established CI/distribution target. Web persistence currently has an in-memory fallback, and production-ready iOS, web, and desktop release paths are not established.

### 3.3 Not implemented

The following items are product opportunities, not current application capabilities.

#### Advanced coaching and computer vision

- [ ] Camera-based exercise pose analysis.
- [ ] Automatic repetition counting from camera input.
- [ ] Real-time exercise-form feedback.
- [ ] On-device AI assistant or natural-language workout planning.
- [ ] AI-generated workout recommendations that operate beyond the existing deterministic progression rules.

#### Advanced training intelligence

- [ ] Fully adaptive program regeneration based on longitudinal performance, recovery feedback, and validated training constraints.
- [ ] A comprehensive recovery model that adjusts training load across the complete program.
- [ ] Validated exercise substitution across equipment availability and movement-pattern requirements.

#### Extended platform capabilities

- [ ] Production-grade durable local persistence for web.
- [ ] Verified release and distribution pipelines for iOS and desktop platforms.
- [ ] Wearable and external fitness-device integrations.

## 4. Recommended Delivery Priorities

The following priorities address the most important gaps between the current implementation and a dependable product.

### P0 — Product correctness and data reliability

- [ ] Remove all hard-coded sample metrics and mock workout-history fallbacks from production data paths.
- [ ] Ensure progress screens display accurate values and explicit empty states when no workout history exists.
- [ ] Complete the first-install exercise-catalog flow, including offline, empty-cache, and remote-failure states.
- [ ] Introduce explicit, versioned SQLite migrations and verify foreign-key behavior.
- [ ] Verify that generated programs respect equipment, limitations, schedule, duration, and recovery constraints.
- [ ] Make persistence and synchronization failures observable; do not silently discard errors.
- [ ] Verify Supabase RLS policies and deployment state against a staging project.

### P1 — Architecture and experience hardening

- [ ] Move remaining direct database and concrete repository access behind Riverpod providers and repository boundaries.
- [ ] Complete authenticated Cloud Sync with per-account consent, durable retry/outbox behavior, and account-isolation tests.
- [ ] Derive progress and program-completion indicators from persisted session data.
- [ ] Apply saved theme preferences consistently at the application root.
- [ ] Complete and test reminder scheduling.
- [ ] Define bounded media-caching behavior and reliable offline demonstration fallbacks.
- [ ] Expand integration and device testing for workout recovery, persistence, and media lifecycle.

### P2 — Advanced capabilities

- [ ] Evaluate camera-based movement analysis and automatic repetition counting.
- [ ] Evaluate on-device coaching only after deterministic training rules and core product behavior are reliable.
- [ ] Consider wearable integrations and additional platform release targets based on validated user demand.

## 5. Out of Scope for the Current Core Product

The following are not required to establish the current Workout Coach product foundation:

- Social feeds, follower systems, and public workout competitions.
- Medical diagnosis, treatment, or rehabilitation recommendations.
- Guaranteed muscle-growth or body-transformation claims.
- Cloud-dependent AI as a requirement for starting or completing a workout.

Any change to this scope should be supported by a product decision and reflected in this document.

## 6. Status Maintenance Rules

- Update this checklist in the same pull request that changes feature delivery status.
- Mark an item as implemented only after the relevant code path has been reviewed.
- Add or update automated tests for important business behavior before marking it complete.
- Keep partially implemented items visible until their documented gaps are resolved.
- Do not treat a screen, mock response, migration file, or static data source as proof of a complete production feature.
- Record material changes to product scope and engineering constraints in the relevant documentation and, where appropriate, an Architecture Decision Record.

For mandatory implementation rules, see [AGENTS.md](../AGENTS.md). For current technical boundaries and known architectural debt, see [ARCHITECTURE.md](../ARCHITECTURE.md).
