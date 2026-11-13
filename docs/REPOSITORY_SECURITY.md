# Repository Security & Branch Protection

This document records the security expectations for the public
`adimunawar/aplikasi-olahraga` repository.

## 1. Branch protection

Create two **Active** repository rulesets under
**Settings → Rules → Rulesets**. Keep the bypass list empty.

### Ruleset: Protect develop

- Enforcement status: Active
- Target: branch `develop`
- Require a pull request before merging
- Required approvals: 0 (single-maintainer workflow; PR and status checks are
  still mandatory)
- Require conversation resolution
- Require status checks:
  - `Analyze Dart & Flutter`
  - `Run Flutter tests`
- Require branches to be up to date before merging
- Require linear history
- Restrict deletions
- Block force pushes
- Do not add actors to the bypass list

### Ruleset: Protect main

Use the same rules, but target only branch `main`.

The workflow runs Analyze and Tests for pull requests targeting both branches.
Release APK build and Firebase App Distribution are intentionally limited to
trusted pushes on `develop`; do not make those jobs required PR checks.

A required approval count of 0 is intentional for this single-maintainer
repository. It prevents direct pushes while allowing the maintainer to merge
their own PR after checks pass. Add at least one approval later if another
trusted reviewer becomes available.

### Important current state

The existing ruleset named `Develop` was observed as **disabled** during the
November 14, 2026 repository audit. The GitHub connection used for this change
can read rulesets but does not expose a ruleset mutation action. Therefore,
these rules must be activated manually in GitHub Settings; merging this PR
will not activate them automatically.

After activation, verify both rulesets show **Active** and each targets only
its intended branch.

## 2. Cloud Sync authorization

Local SQLite remains the default source of truth.

Cloud Sync is permitted only when both conditions are true:

1. A non-anonymous Supabase Auth session exists.
2. The user explicitly accepted Cloud Sync for that account.

The preference is stored as the consented Supabase user ID, not as a global
boolean. A different account on the same device does not inherit the previous
account's consent.

After a user accepts the Cloud Sync explanation in the UI, call:

```dart
await SupabaseConfig.enableCloudSync();
```

To disable Cloud Sync:

```dart
await SupabaseConfig.disableCloudSync();
```

Disabling Cloud Sync does not delete local SQLite data. The UI must not call
`enableCloudSync()` merely because a user signs in; call it only after an
explicit consent action.

## 3. Supabase migration

The new forward-only migration is:

`supabase/migrations/20261114_harden_rls_and_cloud_sync.sql`

It:
- Replaces the permissive exercise policy so public readers see standard
  exercises only, while authenticated owners can see their own custom rows.
- Restricts mobile catalog reads to published program content.
- Removes existing policies from the listed personal/catalog tables and
  recreates owner-scoped policies.
- Revokes inherited/public table privileges and grants only the required
  roles.
- Creates the `user_settings` and `body_measurements` tables used by the
  current Flutter remote datasources.

**Do not assume the migration has been applied just because the file exists
in Git.** Before applying it to the hosted Supabase project:

1. Inspect the live schema and existing rows, especially
   `user_settings`, `body_measurements`, and `user_profiles`.
2. Back up the database.
3. Review the migration and run it against a staging project first.
4. Apply it to the intended project using the Supabase CLI or SQL Editor.
5. Verify the active policies and grants in the hosted database.
6. Test as `anon`, authenticated user A, and authenticated user B:
   - anon can read standard exercises and published programs only;
   - anon cannot read or write personal data or custom exercises;
   - user A cannot read or modify user B's personal data;
   - user A can read/write only their own personal rows;
   - authenticated mobile clients cannot modify the published CMS catalog.

Useful inspection query:

```sql
SELECT
    schemaname,
    tablename,
    policyname,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```

The publishable Supabase key may be present in a public Flutter client. Never
put a Supabase secret/service-role key in the app or repository.

## 4. Firebase and GitHub Actions

- `google-services.json` is ignored locally and supplied to CI through the
  `GOOGLE_SERVICES_JSON` repository secret.
- Android keystore material is supplied only through the Android signing
  GitHub Secrets.
- `FIREBASE_SERVICE_ACCOUNT_JSON` remains a GitHub Secret and is exposed only
  to the Firebase distribution steps.
- `FIREBASE_APP_ID` and `FIREBASE_TESTER_GROUPS` are currently read from
  GitHub Secrets/Variables according to the workflow configuration.
- Firebase client config is not a service-account credential.
- Pull requests to `main` and `develop` run Analyze and Tests.
- Only pushes to `develop` that change app/build inputs create and distribute
  a release APK. Manual workflow dispatch on `develop` forces a build.

## 5. Secret scanning limitations

A repository filename scan found no tracked files with common credential
extensions/names (for example `.env`, `.pem`, `.p12`, `.jks`,
`google-services.json`, or service-account JSON) in the audited branch
snapshot. This does not prove the complete Git history is free of secrets.
Review GitHub Secret Scanning alerts and rotate any credential that was ever
committed publicly.
