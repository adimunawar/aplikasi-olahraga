# Mobile Release Workflow

This repository uses the following promotion flow:

`feature/*` → `develop` → `staging` → `release/*` → `main`

## 1. Prepare a release

1. Promote the tested `staging` branch into a new `release/*` branch using the team's normal release-branch process.
2. Before opening the PR to `main`, open **Actions → Prepare Mobile Release → Run workflow**.
3. Select the release branch (the branch name must start with `release/`).
4. Choose the SemVer increment:
   - `patch`: bug fixes, e.g. 1.0.1 → 1.0.2
   - `minor`: backward-compatible features, e.g. 1.0.1 → 1.1.0
   - `major`: breaking changes, e.g. 1.0.1 → 2.0.0
5. The workflow updates `pubspec.yaml` on that release branch and increments the Flutter build number by one.
6. Verify the generated version, then open the PR from the release branch to `main`.

Run the preparation workflow once per release. Each additional run intentionally increments the version and build number again.

## 2. Publish production release

When the release PR is merged into `main`, the `Publish Mobile Release` workflow runs because `pubspec.yaml` changed. It validates that the version is newer than the latest release, then creates the matching Git tag (for example, `v1.0.2`) and GitHub Release.

The Flutter version format is `x.y.z+build`:
- `x.y.z` is the public app version.
- `build` is the monotonically increasing mobile build number used by Android/iOS.

## 3. Sync development

After production release, sync `main` back into `develop` through a PR. This carries the released `pubspec.yaml` version forward so development does not fall behind the production version.

Continue the normal promotion flow for the next release. Do not manually bump the production version on `develop` for every feature or commit.

## Important safeguards

- Both workflows require repository Actions permissions that allow the workflow token to write repository contents/releases.
- Release preparation only runs on a branch named `release/*`.
- Production tags are created only from `main`.
- A tag cannot be reused, and the published version must be greater than the latest release.
- Keep build numbers increasing for every mobile store upload. If staging builds are uploaded to a store or testing track, give those builds their own unique, increasing build numbers.
