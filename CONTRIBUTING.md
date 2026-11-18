# Contributing

Thank you for improving Workout Coach. The repository is maintained as an engineering portfolio project, so every change should demonstrate clear reasoning, maintainable design, and verifiable behavior.

## 1. Read before changing code

All contributors MUST follow:

1. AGENTS.md — mandatory engineering rules.
2. ARCHITECTURE.md — current boundaries and known architectural debt.
3. Relevant guides under docs/.
4. Existing code and tests for the feature being changed.

If a documented rule conflicts with the current implementation, do not silently copy the legacy implementation. Explain the discrepancy and follow AGENTS.md.

## 2. Branch workflow

Use focused branches:

- feat/<short-description>
- fix/<short-description>
- refactor/<short-description>
- test/<short-description>
- docs/<short-description>
- chore/<short-description>

The normal contribution path is:

1. Branch from the current develop branch.
2. Make one focused change.
3. Push the branch.
4. Open a pull request targeting develop.
5. Resolve review feedback and ensure required checks pass.
6. Merge through the repository's protected-branch workflow.

Do not push directly to protected branches.

## 3. Commit messages

Use a clear type and scope:

- feat(workout): add session recovery
- fix(progress): remove fabricated empty-state metrics
- refactor(database): isolate exercise queries
- test(progression): cover regression decisions
- docs(architecture): clarify catalog ownership
- chore(ci): pin Flutter toolchain

Keep commits focused and avoid mixing generated files or unrelated formatting.

## 4. Implementation expectations

- Inspect all callers before changing a public model, repository, route argument, or database method.
- Prefer small, cohesive changes.
- Preserve backward compatibility or provide a migration when changing persisted data.
- Add regression tests for bug fixes.
- Keep domain logic pure and deterministic.
- Keep persistence/networking out of widgets.
- Expose loading, empty, error, and offline states.
- Avoid mock/sample values in production code paths.
- Update localization resources for user-visible text.
- Update documentation and changelog when behavior or architecture changes.

## 5. Pull request checklist

A pull request should include:

- Problem statement and expected behavior.
- Summary of implementation and design choices.
- Data/schema/API impact.
- Security and privacy impact.
- Screenshots or screen recordings for UI changes where useful.
- Tests added or updated.
- Commands run and their actual results.
- Known limitations and follow-up work.

Use the repository pull-request template.

## 6. Quality checks

Run:

    dart format --output=none --set-exit-if-changed lib test
    flutter analyze
    flutter test

For significant changes, also run:

    flutter test --coverage

If a check cannot be run, state the reason and risk. Do not weaken tests, analyzer rules, or CI to hide a failure.

## 7. Database and Supabase changes

- Add a new forward-only migration.
- Never edit a migration that may already have been applied to a shared environment.
- Test migrations on a disposable/staging project.
- Verify RLS as anon, user A, and user B.
- Update docs/REPOSITORY_SECURITY.md.
- Never include real user data or service-role credentials in the PR.

## 8. Review standard

A change is ready when another developer can understand why it exists, follow the code path, reproduce its behavior, run relevant tests, and safely extend it later.
