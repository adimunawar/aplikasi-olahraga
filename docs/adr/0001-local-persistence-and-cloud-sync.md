# ADR-0001: Local Persistence and Consent-Controlled Cloud Sync

- **Status:** Accepted
- **Date:** 2026-11-17
- **Decision owners:** Workout Coach maintainers

## Context

Workout Coach must keep core workout actions dependable when connectivity is unreliable. Profile information, workout sessions, set records, body measurements, and progression decisions are personal data. The exercise catalog, by contrast, is shared product content that can be maintained centrally.

A single storage rule does not fit both categories. Personal data needs a local-first ownership model and explicit privacy controls; shared catalog content benefits from remote updates.

## Decision

1. Use SQLite as the on-device persistence baseline for personal profile, workout, and progress data.
2. Use Supabase as the remote source for shared exercise and published-program catalog content.
3. Cache catalog records locally so screens can operate from the local repository.
4. Permit personal-data Cloud Sync only when the user has a non-anonymous Supabase Auth session and has explicitly enabled Cloud Sync for that account.
5. Disabling Cloud Sync preserves local data and prevents further personal remote reads/writes.
6. Enforce owner isolation with Supabase RLS. Client-side checks are not an authorization boundary.
7. Keep server/service-role credentials out of the Flutter client.

## Consequences

### Positive

- A workout can be persisted locally before any optional remote synchronization.
- Catalog content can be centrally maintained and cached.
- Cloud Sync is an explicit user choice rather than an automatic side effect of login.
- User data is not shared across local placeholder identities.

### Trade-offs

- Local and remote data can diverge when a network operation fails.
- The application needs clear sync status and retry semantics.
- Account switching requires careful ownership behavior for local records.
- A first installation may have no catalog cache yet.

## Known implementation gaps

- Remote write retry/outbox behavior is not yet centralized or proven durable.
- The complete in-app authentication journey must be verified before Cloud Sync is represented as end-to-end available.
- First-install offline behavior needs a defined seed/download experience.
- Migration and conflict behavior must be tested before adding bidirectional sync.

## Alternatives considered

- **Cloud-only personal data:** rejected because core workout operations should remain available without connectivity.
- **Automatic sync after login:** rejected because login is not equivalent to consent.
- **Bundling the complete exercise catalog and every media file:** rejected because media assets should be delivered independently and updated without an app release.
