---
description: Repository engineering instructions. AGENTS.md is the authoritative source.
globs: lib/**/*.dart, test/**/*.dart, supabase/**/*.sql, .github/workflows/**
---

# Repository rules

Before making any code, test, database, workflow, or documentation change:

1. Read the root AGENTS.md in full.
2. Read the relevant sections of ARCHITECTURE.md and docs/.
3. Inspect current callers, providers, routes, data sources, persistence, and tests.
4. Follow the mandatory dependency, data ownership, privacy, testing, and documentation rules in AGENTS.md.
5. Report the exact changes and checks actually performed.

AGENTS.md takes precedence over this file. This file intentionally contains no duplicate architecture rules so that instructions cannot drift.

Do not use machine-specific absolute file links. Prefer repository-relative paths.

Do not claim tests, analysis, or builds passed unless they were executed and passed. Do not bypass CI, suppress analyzer failures broadly, introduce production mock data, or silently swallow errors.
