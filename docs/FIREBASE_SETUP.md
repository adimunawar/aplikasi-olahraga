# Firebase Setup — Crashlytics & Analytics

Dokumen ini menjelaskan konfigurasi Firebase di project ini, cara verifikasi,
dan langkah yang masih diperlukan untuk iOS.

## Ringkasan

| Item | Nilai |
|---|---|
| Firebase project | `home-workout-coach-9c799` |
| Android package | `com.homefitness.workout_app` |
| iOS bundle ID | `com.homefitness.workoutApp` |
| Package Flutter | `firebase_core`, `firebase_crashlytics`, `firebase_analytics` |
| Gradle plugin | `com.google.gms.google-services` 4.6.0, `com.google.firebase.crashlytics` 3.0.8 |

Firebase diinisialisasi sekali di `lib/main.dart` sebelum `runApp`:

```dart
await FirebaseConfig.initialize();
```

Bootstrap-nya ada di `lib/core/config/firebase_config.dart`:

- Hanya berjalan di Android/iOS. Web & desktop dilewati karena tidak punya
  konfigurasi native.
- Idempotent dan tidak pernah memblokir startup. Kalau konfigurasi belum ada,
  app tetap jalan normal (local-first) tanpa monitoring.
- Memasang handler global: `FlutterError.onError` (error framework) dan
  `PlatformDispatcher.instance.onError` (error async) dilaporkan sebagai fatal
  ke Crashlytics.

Wrapper Analytics ada di `lib/core/services/analytics_service.dart` dan aman
dipanggil kapan saja (otomatis no-op kalau Firebase tidak aktif).

## Android

### File konfigurasi

`android/app/google-services.json` **tidak di-commit** — sudah masuk
`.gitignore` sebagai bagian dari audit keamanan. File ini berisi identifier
project, bukan service account, tapi tetap diperlakukan sebagai konfigurasi
lokal.

Untuk mendapatkan / memperbarui file tersebut:

1. Buka [Firebase Console](https://console.firebase.google.com/) → project
   `home-workout-coach-9c799`.
2. **Project settings** → tab **Your apps** → pilih app Android
   `com.homefitness.workout_app`.
3. Download `google-services.json`, letakkan di `android/app/`.
4. Pastikan package di file sama dengan `applicationId` di
   `android/app/build.gradle.kts`.

### Gradle

`android/settings.gradle` mendeklarasikan kedua plugin dengan `apply false`:

```groovy
id "com.google.gms.google-services" version "4.6.0" apply false
id "com.google.firebase.crashlytics" version "3.0.8" apply false
```

`android/app/build.gradle.kts` mengaplikasikannya:

```kotlin
id("com.google.gms.google-services")
id("com.google.firebase.crashlytics")
```

Kalau `google-services.json` tidak ada, build Android akan gagal dengan pesan
`File google-services.json is missing`. Itu disengaja supaya APK release tidak
diam-diam kehilangan Crashlytics/Analytics.

### CI

Workflow `.github/workflows/flutter-ci.yml` menulis file konfigurasi dari
repository secret sebelum build release:

- Secret: **`GOOGLE_SERVICES_JSON`**
- Isi: seluruh isi `android/app/google-services.json` (JSON mentah).

Tanpa secret tersebut, job **Build Android release APK** akan gagal dengan
pesan `Missing GitHub secret GOOGLE_SERVICES_JSON`.

## Verifikasi Crashlytics

Collection Crashlytics aktif secara default, termasuk di debug, supaya test
langsung terlihat. Matikan bila tidak diperlukan:

```bash
flutter run --dart-define=FIREBASE_CRASHLYTICS_ENABLED=false
```

Untuk menguji pelaporan crash:

1. Jalankan app di device/emulator Android:
   ```bash
   flutter run
   ```
2. Picu crash dari kode (sementara), misalnya di sebuah tombol:
   ```dart
   FirebaseCrashlytics.instance.crash();
   ```
   atau untuk menguji error framework:
   ```dart
   throw StateError('Crashlytics test');
   ```
3. Tutup app, buka lagi agar laporan terkirim.
4. Buka Firebase Console → **Crashlytics** → tunggu 1–5 menit.

Cek log koneksi di logcat:

```bash
adb logcat | Select-String "Firebase|Crashlytics"
```

## Verifikasi Analytics

Analytics otomatis mengumpulkan event dasar (`first_open`, `session_start`,
`screen_view` bila dipanggil manual). Untuk melihat event real-time:

1. Jalankan app dengan `FIREBASE_ANALYTICS_ENABLED=true`, lalu aktifkan
   DebugView di device:
   ```bash
   adb shell setprop debug.firebase.analytics.app com.homefitness.workout_app
   ```
2. Jalankan app dengan `flutter run`.
3. Buka Firebase Console → **Analytics** → **DebugView**.
4. Matikan kembali setelah selesai:
   ```bash
   adb shell setprop debug.firebase.analytics.app .none.
   ```

Contoh pemakaian:

```dart
import 'core/services/analytics_service.dart';

AnalyticsService.instance.logEvent('workout_started', parameters: {
  'program_id': programId,
  'day_number': dayNumber,
});

AnalyticsService.instance.logScreenView(screenName: 'home');

AnalyticsService.instance.setUserId(userId);
```

## iOS (belum diverifikasi)

Butuh macOS + Xcode. Langkahnya:

1. Di Firebase Console, tambahkan app iOS dengan bundle ID
   `com.homefitness.workoutApp` (perhatikan huruf besar `A` — beda dari
   Android).
2. Download `GoogleService-Info.plist`.
3. Tambahkan file tersebut ke target **Runner** lewat Xcode (drag ke project
   navigator, pastikan **Runner** tercentang). Jangan hanya menaruhnya di
   folder tanpa menambahkan ke target.
4. Generate `Podfile` (belum ada di repo) dengan menjalankan build iOS pertama:
   ```bash
   flutter build ios --no-codesign
   ```
5. Pastikan `platform :ios, '13.0'` atau lebih baru di `ios/Podfile`, lalu:
   ```bash
   cd ios && pod install
   ```
6. Untuk upload dSYM Crashlytics, tambahkan **Run Script** phase di target
   Runner (Build Phases) setelah phase "Embed Frameworks":
   ```
   "${PODS_ROOT}/FirebaseCrashlytics/run"
   ```
   dengan input files:
   ```
   ${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}
   ${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}
   ```
7. Tambahkan secret `GOOGLE_SERVICES_PLIST` (base64) di CI bila nanti build
   iOS dijalankan otomatis.

## Catatan penting

- Android Release uses the dedicated upload keystore configured through
  `android/key.properties` locally and GitHub Actions Secrets in CI. The
  Gradle configuration intentionally never falls back to the debug signing key.
- Crashlytics collection is enabled by default only for Release builds.
  Analytics collection follows the same Release-first default.
- `minSdk` mengikuti default Flutter (24), sudah memenuhi requirement Firebase
  Android.
- Simbol/mapping Crashlytics di-upload otomatis oleh plugin
  `com.google.firebase.crashlytics` saat build release. Jangan hapus plugin
  tersebut meski hanya memakai Analytics.
- Kalau ingin menambahkan Firebase lain (Firestore, Auth, Messaging), cukup
  tambah package-nya. Konfigurasi native Android tetap memakai
  `google-services.json` yang sama.

## Troubleshooting

| Gejala | Penyebab & solusi |
|---|---|
| `File google-services.json is missing` | File belum ada di `android/app/`. Download dari Firebase Console. |
| `[Firebase] Gagal inisialisasi: ...` di log | Package/bundle ID tidak cocok dengan file konfigurasi, atau file rusak. |
| Crash tidak muncul di console | Collection dimatikan, app belum dibuka ulang, atau butuh beberapa menit. |
| Event Analytics tidak muncul | DebugView belum aktif, atau `setAnalyticsCollectionEnabled(false)` dipanggil. |
| Build CI gagal `Missing GitHub secret GOOGLE_SERVICES_JSON` | Tambahkan secret berisi isi `google-services.json`. |
