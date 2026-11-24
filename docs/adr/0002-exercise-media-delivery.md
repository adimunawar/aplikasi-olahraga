# ADR-0002: Remote Exercise Media and Local Catalog Cache

- **Status:** Accepted
- **Date:** 2026-11-17
- **Decision owners:** Workout Coach maintainers

## Context

The exercise catalog contains structured metadata and references to demonstration media. Video files can be substantially larger and change more frequently than the metadata used to generate a workout. Bundling all videos in the application package increases installation size and forces a mobile release for content-only updates.

The active workout UI already uses video_player to initialize HTTP(S) video URLs and can fall back to a poster when media is missing or playback fails.

## Decision

1. Store exercise metadata in the Supabase exercise catalog.
2. Store video binaries in object storage/CDN, not in PostgreSQL rows or Flutter source.
3. Store media URLs (for example video_url) in exercise metadata.
4. Cache catalog metadata in SQLite for local reads.
5. Bundle only the static image assets that are required for the initial application experience.
6. Use the shared media URL resolver for supported media proxy transformations.
7. Keep video playback and controller lifecycle inside a reusable media component, not inside workout business logic.

## Consequences

### Positive

- Exercise videos can be updated without shipping a new APK.
- The app package does not need to contain the full video library.
- Catalog metadata is available from local storage after a successful sync.
- Media loading failures can degrade to a poster instead of blocking the workout UI.

### Trade-offs

- First-time playback requires network access unless a local media cache is added.
- Media URLs must be validated and may expire if signed URLs are used.
- CDN/proxy availability and caching policy become operational concerns.
- Posters and metadata still need a predictable fallback for offline use.

## Known implementation gaps

- A bounded disk cache for exercise video is not established as a complete feature.
- Cache invalidation, signed URL expiry, and retry policy need explicit design before being advertised.
- First-install empty catalog behavior needs a recoverable path.
- The exercise JSON asset fallback has been removed from the current feature branch; any required initial offline seed must be designed explicitly rather than reintroduced accidentally.

## Alternatives considered

- **Bundle all MP4 videos in the APK:** rejected due to app size and content-release coupling.
- **Use GIF as the primary demonstration format:** rejected for the main exercise player because the existing product uses controllable network video playback.
- **Store binary video in a database row:** rejected; object storage/CDN is the appropriate media delivery boundary.
