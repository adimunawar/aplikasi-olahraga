# Android release signing

The CI pipeline builds a **signed release APK** and distributes it through Firebase App Distribution. Release builds must use a dedicated, persistent signing key. Do not use the ephemeral Android debug key for releases.

## 1. Generate the signing keystore (one time)

Run this from PowerShell with JDK 17 available:

```powershell
keytool -genkeypair -v `
  -keystore .\upload-keystore.p12 `
  -storetype PKCS12 `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000 `
  -alias home-bulking-coach
```

Keep the keystore and its passwords in a secure password manager and make an offline backup. **Do not regenerate this key for future releases.** Losing it means you may no longer be able to publish updates signed with the same certificate.

## 2. Add GitHub Actions secrets

In the repository, open **Settings → Secrets and variables → Actions → Secrets → New repository secret**.

Create these four secrets:

| Secret name | Value |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded contents of `upload-keystore.p12` |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password entered during generation |
| `ANDROID_KEY_ALIAS` | `home-bulking-coach` |
| `ANDROID_KEY_PASSWORD` | Key password entered during generation |

To copy the keystore as one Base64 line in PowerShell:

```powershell
$encoded = [Convert]::ToBase64String([IO.File]::ReadAllBytes(".\upload-keystore.p12"))
Set-Clipboard -Value $encoded
```

Paste the clipboard contents into the `ANDROID_KEYSTORE_BASE64` secret. Never paste the keystore or passwords into a commit, issue, pull request, chat, or workflow log.

The workflow validates the keystore and alias before Gradle builds the APK. It writes the decoded keystore only to the temporary GitHub Actions runner directory.

## 3. Local release builds (optional)

For local release builds, place the keystore somewhere outside the repository and create `android/key.properties`:

```properties
storeFile=C:/secure/path/upload-keystore.p12
storePassword=YOUR_KEYSTORE_PASSWORD
keyAlias=home-bulking-coach
keyPassword=YOUR_KEY_PASSWORD
```

The `android/key.properties` file and keystore files are ignored by Git. Never force-add them.

Then build with:

```bash
flutter build apk --release
```

## 4. Firebase distribution

The workflow continues to use these Firebase settings:

- GitHub secret `FIREBASE_APP_ID`
- GitHub secret `FIREBASE_SERVICE_ACCOUNT_JSON`
- GitHub Actions repository variable `FIREBASE_TESTER_GROUPS`

A push or manual workflow run on `develop` runs Analyze → Tests → signed Release APK → Firebase App Distribution. Pull requests run Analyze and Tests only.

Missing Android signing or Firebase configuration now fails the relevant job instead of reporting a successful skipped distribution.

## 5. Important: installing the first signed release

Earlier Firebase builds were signed with the runner's debug key. The first APK signed with this new release keystore has a different certificate, so Android may reject it as an in-place update.

Before installing the first release-signed APK, uninstall the earlier debug-signed app from the test device and then install the new release. Uninstalling removes local app data, so back up any test data that needs to be kept first. All future releases must use the same keystore.
