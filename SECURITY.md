# Security Policy

## Supported versions

Security fixes are applied to the actively maintained development line. The repository does not currently publish a formal long-term support matrix.

## Reporting a vulnerability

Please do not publish exploitable details, credentials, private user data, or proof-of-concept attacks in a public issue.

Use GitHub's private vulnerability reporting / Security Advisory flow for this repository when available. Include:

- A clear description of the affected component.
- Steps to reproduce with test data.
- Impact and attack prerequisites.
- A suggested mitigation, if known.

Do not include real user records, production access tokens, service-role keys, signing credentials, or private signed media URLs in the report.

If private vulnerability reporting is unavailable, contact the repository maintainer through a private GitHub channel before publishing technical details.

## Security requirements for contributions

- Never commit secrets, API service-role keys, Firebase service-account files, keystores, or signing passwords.
- Treat Supabase publishable/anon keys as public client identifiers; enforce authorization with RLS and least-privilege grants.
- Scope personal-data operations to the authenticated owner.
- Require explicit Cloud Sync consent for personal cloud synchronization.
- Keep body measurements, workout history, and identifiers out of Analytics events and routine logs.
- Validate remote data and all navigation/user input.
- Use parameterized SQL and forward-only migrations.
- Review dependency changes and native permissions for security impact.

See docs/REPOSITORY_SECURITY.md and AGENTS.md for the repository-specific controls.
