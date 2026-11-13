import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's explicit Cloud Sync consent.
///
/// Consent defaults to false. Authentication alone must never enable cloud
/// reads or writes. SupabaseConfig additionally verifies the active session
/// before allowing sync.
class CloudSyncConsent {
  CloudSyncConsent._();

  static const String _preferenceKey = 'cloud_sync_consent';
  static bool _isEnabled = false;

  static bool get isEnabled => _isEnabled;

  /// Restore consent during application bootstrap.
  /// Any storage error fails closed: cloud sync remains disabled.
  static Future<void> initialize() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      _isEnabled = preferences.getBool(_preferenceKey) ?? false;
    } catch (error) {
      _isEnabled = false;
      debugPrint('[CloudSync] Could not restore consent; sync remains disabled: $error');
    }
  }

  /// Persist a consent decision. Enabling must be performed through
  /// SupabaseConfig.enableCloudSync(), which checks authenticated identity.
  static Future<void> setEnabled(bool enabled) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final persisted = await preferences.setBool(_preferenceKey, enabled);
      if (!persisted) {
        throw StateError('Could not persist Cloud Sync consent.');
      }
      _isEnabled = enabled;
    } catch (error) {
      // Fail closed on an unsuccessful enable operation.
      if (enabled) _isEnabled = false;
      rethrow;
    }
  }

  @visibleForTesting
  static void resetForTesting() {
    _isEnabled = false;
  }
}
