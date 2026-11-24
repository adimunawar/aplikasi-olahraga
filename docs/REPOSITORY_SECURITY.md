# Repository Security and Branch Protection

This document records the repository-level controls verified for the current portfolio hardening effort. Re-check GitHub settings before relying on them for a future release.

## 1. Protected branches

The following repository rulesets were observed as active on 17 November 2026:

| Ruleset | Branch | Status |
|---|---|---|
| Develop | develop | Active |
| Main | main | Active |
| Stg | staging | Active |

Each ruleset requires a pull request, conversation resolution, required status checks, linear history, and protection against deletion and force-push/non-fast-forward updates. The rulesets have no bypass actors.

Required status checks:

- Analyze Dart & Flutter
- Run Flutter tests

The approval requirement is currently zero. This is consistent with a single-maintainer workflow: a pull request is still required, but an independent human approval is not enforced. Add a required approval if the project gains additional trusted reviewers.

The Develop ruleset also includes a code-quality rule with error severity.

These controls are GitHub repository configuration, not source files. Verify their current status in Settings → Rules → Rulesets.

## 2. CI trigger and branch relationship

The repository contains two workflows:

- .github/workflows/flutter-ci.yml
  - Pull requests targeting develop, staging, and main run analysis and tests.
  - Pushes to main run analysis and tests.
  - Manual workflow dispatch on develop can run the configured signed APK path.
- .github/workflows/build-staging.yml
  - Pushes to staging build a signed Android APK and distribute it through Firebase App Distribution.

A feature branch does not receive a PR-triggered check until a pull request targets one of the configured branches.

## 3. Personal-data authorization

SQLite is the local persistence baseline.

Remote personal-data synchronization is permitted only when:

1. A non-anonymous Supabase Auth session exists.
2. The user explicitly enabled Cloud Sync for that account.

The consent is associated with the authenticated user ID rather than a global boolean. Signing in alone must never enable personal-data sync. Disabling Cloud Sync keeps local SQLite records.

Remote personal-data operations must never use placeholder local identifiers such as default_user as a cloud owner ID.

## 4. Supabase RLS and migrations

The repository includes these security-related migrations:

- supabase/migrations/20261113_secure_rls_and_owner_isolation.sql
- supabase/migrations/20261114_harden_rls_and_cloud_sync.sql

The 14 November migration:

- Enables RLS on personal-data and catalog tables.
- Defines owner-scoped policies for users, profiles, workout sessions, workout sets, progression decisions, training programs, settings, and measurements.
- Allows public catalog reads subject to the published/standard-record policies in the migration.
- Restricts client-side catalog writes; trusted CMS writes need a server-side path with server-only credentials.

**A migration file in Git is not proof that it has been applied to the hosted Supabase project.** Before a production change:

1. Inspect the live schema, grants, policies, and existing rows.
2. Back up the database.
3. Apply to staging first.
4. Verify active policies and grants after application.
5. Test as anon, authenticated user A, and authenticated user B.
6. Confirm user A cannot read or modify user B's personal records.
7. Confirm anon can read only intended public catalog content and cannot access personal records.
8. Confirm mobile authenticated clients cannot mutate the published CMS catalog.

Useful policy inspection query:

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

## 5. Secrets and configuration

Never commit:

- Supabase secret/service-role keys.
- Firebase service-account JSON.
- Android keystores or signing passwords.
- Local environment files containing secrets.
- Private signed media URLs or authorization headers.

The Flutter client may contain a Supabase publishable/anon key. It is not a secret authorization mechanism; RLS and grants must enforce access.

CI configuration is supplied through GitHub Actions secrets and variables. See docs/RELEASE.md, docs/FIREBASE_SETUP.md, and docs/android-release-signing.md.

## 6. Secret-scanning limitations

The repository ignore rules cover common local credential/configuration files. A filename scan or clean working tree does not prove that Git history is free of credentials.

Maintainers should review GitHub secret-scanning alerts and rotate any credential that may have been committed. If a secret is exposed, revoke/rotate it first; deleting the current file is not sufficient.

For vulnerability reporting, follow SECURITY.md.
