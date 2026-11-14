import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Bootstrap Firebase for Crashlytics and Analytics.
///
/// Native configuration:
/// - Android: android/app/google-services.json
/// - iOS: ios/Runner/GoogleService-Info.plist
///
/// Firebase monitoring is optional at startup. Missing native configuration
/// must never prevent the local-first application from starting.
class FirebaseConfig {
  FirebaseConfig._();

  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static bool get _isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Release builds collect crashes by default. Debug/Profile builds stay
  /// local unless a developer explicitly enables collection for testing.
  static const bool _crashlyticsCollectionEnabled = bool.fromEnvironment(
    'FIREBASE_CRASHLYTICS_ENABLED',
    defaultValue: kReleaseMode,
  );

  /// Analytics follows the same release-first default.
  /// Enable locally for DebugView with:
  /// --dart-define=FIREBASE_ANALYTICS_ENABLED=true
  static const bool _analyticsCollectionEnabled = bool.fromEnvironment(
    'FIREBASE_ANALYTICS_ENABLED',
    defaultValue: kReleaseMode,
  );

  static Future<void> initialize() async {
    if (_isInitialized || !_isSupportedPlatform) return;

    try {
      await Firebase.initializeApp();
      _isInitialized = true;

      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        _crashlyticsCollectionEnabled,
      );
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(
        _analyticsCollectionEnabled,
      );

      if (_crashlyticsCollectionEnabled) {
        _installCrashlyticsErrorHandlers();
      }

      if (kDebugMode) {
        debugPrint(
          '[Firebase] Initialized. '
          'Crashlytics: $_crashlyticsCollectionEnabled, '
          'Analytics: $_analyticsCollectionEnabled.',
        );
      }
    } catch (error, stackTrace) {
      // Firebase monitoring must never prevent offline/local app startup.
      _isInitialized = false;
      debugPrint('[Firebase] Initialization failed: $error');
      if (kDebugMode) debugPrintStack(stackTrace: stackTrace);
    }
  }

  static void _installCrashlyticsErrorHandlers() {
    final crashlytics = FirebaseCrashlytics.instance;

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      crashlytics.recordFlutterFatalError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Null when Firebase is not initialized or Analytics collection is off.
  static FirebaseAnalytics? get analytics =>
      _isInitialized && _analyticsCollectionEnabled
      ? FirebaseAnalytics.instance
      : null;

  /// Null when Firebase is not initialized.
  static FirebaseCrashlytics? get crashlytics =>
      _isInitialized ? FirebaseCrashlytics.instance : null;

  /// Add a non-sensitive breadcrumb to the next crash report.
  static Future<void> log(String message) async {
    final instance = crashlytics;
    if (instance == null || !_crashlyticsCollectionEnabled) return;

    try {
      await instance.log(message);
    } catch (error) {
      debugPrint('[Firebase] Failed to write Crashlytics log: $error');
    }
  }
}
