# Mobile Release Workflow

## Branch promotion

Use this flow:

`feature/*` → `develop` → `staging` → `release/*` → `main`

- `develop`: integration branch for completed features.
- `staging`: QA/testing branch. Complete QA and approve the candidate here before preparing a production release.
- `release/*`: production release candidate created from the tested `staging` branch. Only release-specific fixes and version preparation belong here.
- `main`: production source. Production tags and GitHub Releases are created only from this branch.

## 1. Prepare a release

1. After QA passes on `staging`, create a new `release/*` branch from the tested `staging` commit.
2. Open **Actions → Prepare Mobile Release → Run workflow**.
3. Select the `release/*` branch in the workflow's branch selector. The workflow definition lives on the default branch, while the selected release branch is the target of the version update.
4. Choose the SemVer increment:
   - `patch`: bug fixes, e.g. 1.0.1 → 1.0.2
   - `minor`: backward-compatible features, e.g. 1.0.1 → 1.1.0
   - `major`: breaking changes, e.g. 1.0.1 → 2.0.0
5. The workflow updates `pubspec.yaml` on that release branch, increments the build number by one, and commits the change.
6. Verify the generated version and run final release validation. Then open a PR from `release/*` to `main`.

Run the preparation workflow once per release candidate. Each additional run intentionally increments the version and build number again; do not rerun it just to retry unrelated checks.

## 2. Publish the production release

When the release PR is merged into `main` and `pubspec.yaml` changes, **Publish Mobile Release** runs automatically. It validates that the SemVer version is newer than the latest release tag, then creates the matching Git tag (for example, `v1.0.2`) and GitHub Release from the merge commit.

The Flutter version format is `x.y.z+build`:
- `x.y.z` is the public app version and is used for the Git tag.
- `build` is the monotonically increasing mobile build number used by Android/iOS.

Do not manually create production tags or GitHub Releases. **Publish Mobile Release** is the single production publishing path.

## 3. Sync development

After the production release, sync `main` back into `develop` through a PR. Then promote the updated development branch through the normal QA flow when appropriate. This carries the released `pubspec.yaml` version forward so development does not fall behind production.

Do not manually bump the production version on `develop` for every feature or commit.

## Important safeguards

- The workflow token needs permission to write repository contents and create releases.
- `Prepare Mobile Release` only runs when the selected ref starts with `release/`.
- QA remains on `staging`; the release branch is created only after the staging candidate passes QA.
- Production tags and GitHub Releases are created only from `main`, by `Publish Mobile Release`.
- A tag cannot be reused, and the published SemVer version must be greater than the latest release.
- Keep build numbers increasing for every mobile store upload. If staging builds are uploaded to a store or testing track, give those builds their own unique, increasing build numbers.
