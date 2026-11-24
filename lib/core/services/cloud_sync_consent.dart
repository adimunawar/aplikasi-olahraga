import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists explicit Cloud Sync consent for one authenticated account.
///
/// Consent defaults to disabled and is bound to a Supabase user ID so a
/// different person signing in on the same device does not inherit it.
class CloudSyncConsent {
  CloudSyncConsent._();

  static const String _preferenceKey = 'cloud_sync_consent_user_id';
  static String? _consentedUserId;

  static bool get isEnabled => _consentedUserId != null;

  static bool isEnabledFor(String userId) =>
      userId.isNotEmpty && _consentedUserId == userId;

  /// Restore consent during application bootstrap.
  /// Any storage error fails closed: cloud sync remains disabled.
  static Future<void> initialize() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final storedUserId = preferences.getString(_preferenceKey);
      _consentedUserId =
          storedUserId == null || storedUserId.isEmpty ? null : storedUserId;
    } catch (error) {
      _consentedUserId = null;
      debugPrint(
        '[CloudSync] Could not restore consent; sync remains disabled: $error',
      );
    }
  }

  /// Persist the account ID for which the user explicitly enabled Cloud Sync.
  /// SupabaseConfig performs the authenticated/non-anonymous session check.
  static Future<void> enableForUser(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'Must not be empty.');
    }

    try {
      final preferences = await SharedPreferences.getInstance();
      final persisted = await preferences.setString(_preferenceKey, userId);
      if (!persisted) {
        throw StateError('Could not persist Cloud Sync consent.');
      }
      _consentedUserId = userId;
    } catch (_) {
      _consentedUserId = null;
      rethrow;
    }
  }

  /// Clear consent. Local SQLite data is not changed or deleted.
  static Future<void> disable() async {
    // Fail closed immediately, even if persistence subsequently fails.
    _consentedUserId = null;
    final preferences = await SharedPreferences.getInstance();
    final removed = await preferences.remove(_preferenceKey);
    if (!removed) {
      throw StateError('Could not clear Cloud Sync consent.');
    }
  }

  @visibleForTesting
  static void resetForTesting() {
    _consentedUserId = null;
  }
}
