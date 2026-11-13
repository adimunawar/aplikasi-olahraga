import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Bootstrap Firebase untuk Crashlytics & Analytics.
///
/// Konfigurasi native yang dipakai:
/// - Android: `android/app/google-services.json`
/// - iOS: `ios/Runner/GoogleService-Info.plist`
///
/// Sengaja tanpa `firebase_options.dart`: kedua file native di atas sudah
/// menjadi sumber konfigurasi resmi FlutterFire, sehingga tidak perlu
/// menjalankan ulang `flutterfire configure`.
///
/// Inisialisasi hanya dilakukan di Android/iOS. Di web & desktop
/// `Firebase.initializeApp()` tanpa options akan melempar error, sedangkan
/// aplikasi ini memang menargetkan mobile.
class FirebaseConfig {
  FirebaseConfig._();

  static bool _isInitialized = false;

  /// True jika Firebase sudah berhasil diinisialisasi pada sesi ini.
  static bool get isInitialized => _isInitialized;

  /// Hanya platform yang punya file konfigurasi native.
  static bool get _isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Collection Crashlytics aktif secara default (termasuk debug) supaya
  /// crash test langsung terlihat di console. Matikan saat development dengan:
  ///
  /// `flutter run --dart-define=FIREBASE_CRASHLYTICS_ENABLED=false`
  static const bool _crashlyticsCollectionEnabled = bool.fromEnvironment(
    'FIREBASE_CRASHLYTICS_ENABLED',
    defaultValue: true,
  );

  /// Inisialisasi Firebase + pasang handler error global.
  ///
  /// Idempotent dan tidak pernah memblokir startup: jika konfigurasi belum
  /// lengkap, aplikasi tetap berjalan dalam mode tanpa monitoring.
  static Future<void> initialize() async {
    if (_isInitialized) return;

    if (!_isSupportedPlatform) {
      debugPrint(
        '[Firebase] Dilewati: platform ini tidak memakai konfigurasi Firebase native.',
      );
      return;
    }

    try {
      await Firebase.initializeApp();
      _isInitialized = true;
      await _configureCrashlytics();

      if (kDebugMode) {
        debugPrint('[Firebase] Siap (Crashlytics + Analytics).');
      }
    } catch (error) {
      // Local-first: monitoring tidak boleh menggagalkan app.
      debugPrint('[Firebase] Gagal inisialisasi: $error');
    }
  }

  static Future<void> _configureCrashlytics() async {
    final crashlytics = FirebaseCrashlytics.instance;

    await crashlytics.setCrashlyticsCollectionEnabled(
      _crashlyticsCollectionEnabled,
    );

    if (!_crashlyticsCollectionEnabled) return;

    // Error framework (build, layout, gesture) -> Crashlytics.
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      crashlytics.recordFlutterFatalError(details);
    };

    // Error async / di luar framework (root zone) -> Crashlytics.
    PlatformDispatcher.instance.onError = (error, stack) {
      crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Null jika Firebase tidak aktif (platform non-mobile atau init gagal).
  static FirebaseAnalytics? get analytics =>
      _isInitialized ? FirebaseAnalytics.instance : null;

  /// Null jika Firebase tidak aktif (platform non-mobile atau init gagal).
  static FirebaseCrashlytics? get crashlytics =>
      _isInitialized ? FirebaseCrashlytics.instance : null;

  /// Menambahkan breadcrumb non-fatal ke laporan crash berikutnya.
  static Future<void> log(String message) async {
    final instance = crashlytics;
    if (instance == null) return;
    try {
      await instance.log(message);
    } catch (error) {
      debugPrint('[Firebase] Gagal menulis log: $error');
    }
  }
}
