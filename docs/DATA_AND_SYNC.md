# Data Ownership and Synchronization

This document defines which system owns each class of data and the intended behavior when the device is offline. AGENTS.md contains the mandatory implementation rules.

## 1. Data ownership matrix

| Data | Primary role | Local behavior | Remote behavior |
|---|---|---|---|
| Standard exercise catalog | Supabase catalog | Cached in SQLite | Public catalog read, subject to RLS |
| Published workout programs | Supabase catalog | Local program/session data may be stored for use | Read published catalog content |
| Exercise media | Object storage/CDN | Poster assets may be bundled; remote videos are not bundled by default | URL stored in exercise metadata |
| User profile and preferences | Local SQLite baseline | Available on device | Sync only with authenticated user and explicit consent |
| Workout sessions and set logs | Local SQLite baseline | Persisted locally | Optional consent-controlled sync |
| Body measurements and progression decisions | Local SQLite baseline | Persisted locally | Optional consent-controlled sync |
| App locale/onboarding preference | Device preferences | Stored locally | Not treated as workout cloud data |

The precise implementation of each repository must be inspected before extending it. Do not infer that all tables or all data types are currently synchronized just because a migration or model exists.

## 2. Exercise catalog flow

Intended flow:

1. The application requests the exercise catalog through ExerciseRepository.
2. The remote data source reads public exercise records from Supabase.
3. The remote mapper converts the response into ExerciseEntity/domain data.
4. The local data source persists the catalog in SQLite.
5. Screens read a consistent catalog through repositories/providers.
6. When remote fetch fails, the repository uses the valid local catalog.

Important constraints:

- An empty remote response is not automatically permission to erase a previously valid local catalog.
- A first installation can have an empty local catalog. The app must provide a clear initial-sync/loading/error/retry path.
- Do not make every screen independently fetch the full catalog. Cache freshness and in-flight request de-duplication should have one owner.
- Catalog versioning, deletion propagation, and partial-update semantics must be defined before implementing incremental sync.
- Custom exercises and standard catalog records have different ownership and RLS rules.

## 3. Personal Cloud Sync authorization

Personal cloud synchronization is allowed only when both conditions are true:

1. A real, non-anonymous Supabase Auth user is available.
2. The user explicitly accepted Cloud Sync for that account.

The application restores explicit consent during startup. The consent is associated with the user identity so one account does not automatically inherit another account's consent on the same device.

Disabling Cloud Sync must:

- Disable future remote personal-data reads and writes.
- Preserve local SQLite data.
- Not silently delete remote or local records.
- Produce a clear state if a pending synchronization operation cannot be completed.

Do not enable sync merely because a user signed in. The current repository has consent enforcement, but the complete in-app sign-in experience and all end-to-end sync paths must be verified before claiming the feature is fully available.

## 4. Local-first write behavior

For personal workout actions:

1. Validate the command.
2. Persist the local result first.
3. Update UI state from the local result.
4. Attempt remote synchronization only when the account and consent conditions permit it.
5. Surface a pending/failed-sync state when a remote operation fails.

A network error must not erase a successful local workout.

The current code contains remote calls guarded by Cloud Sync checks, but remote failure handling and durable retry/outbox behavior are not yet centralized. Do not describe this as guaranteed eventual consistency until an outbox, retry policy, conflict policy, and tests exist.

## 5. Conflict and identity rules

Before implementing bidirectional synchronization, define:

- Stable record identity and idempotency keys.
- Which side wins when local and remote values differ.
- How deletion is represented and propagated.
- How timestamps and time zones are normalized.
- How account switching affects local data ownership.
- How pending operations are handled on sign-out or consent revocation.
- How duplicate uploads are prevented.
- How retries are bounded and observable.

Never use a placeholder local ID such as default_user as a remote authenticated owner ID.

## 6. Media delivery

Exercise metadata may contain:

- Start/end pose image URLs.
- Animation metadata or legacy asset references.
- A video_url used by the active workout media card.

Video files should live in object storage/CDN, not in the exercise table or the APK. The database stores metadata and URL references.

Current video playback uses video_player with network URLs. The media URL resolver supports a configured R2 proxy path and passes other HTTP(S) URLs through.

A complete media caching strategy should define:

- Cache size and eviction policy.
- Retry and cancellation behavior.
- Cache key/version invalidation.
- Whether a video can be played before download completes.
- What offline users see when media has never been cached.
- Whether signed URLs can expire while a cache entry remains valid.

Do not log signed URLs or private storage tokens.

## 7. Operational verification checklist

Before changing data or synchronization behavior, verify:

- Fresh install with internet.
- Fresh install without internet.
- Existing install with a populated SQLite catalog.
- Offline workout start and completion.
- Network loss during media loading.
- Cloud Sync disabled.
- Cloud Sync enabled with an eligible user.
- Consent revoked.
- Account A followed by account B on the same device.
- Duplicate/retried remote writes.
- Supabase access as anon, user A, and user B.

Record any unsupported scenario as a known limitation rather than implying it is covered.
