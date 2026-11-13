import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/cloud_sync_consent.dart';

/// Konfigurasi Supabase untuk CMS & Cloud Sync (Local-First Architecture):
/// - Mendukung multi-environment via `--dart-define` (Development, Staging, Production).
/// - Fallback default mengamankan flow testing & local build tanpa argumen CLI tambahan.
/// - Menegakkan standar keamanan Mobile Auth (PKCE Flow).
class SupabaseConfig {
  SupabaseConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://wacmyyrruxusztwqyntr.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_2qpIcaoloKN-joznYZsyGw__j5GRrtL',
  );

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// Inisialisasi aman Supabase client:
  /// - Idempotent (mencegah double-initialization pada hot restart / multi-entry).
  /// - Menggunakan PKCE flow untuk autentikasi mobile yang aman.
  /// - Mode offline-resilient: jika key kosong/tidak valid, aplikasi tetap berjalan 100% via SQLite.
  static Future<void> initialize({
    String? url,
    String? anonKey,
  }) async {
    if (_isInitialized) return;

    final targetUrl = url ?? supabaseUrl;
    final targetKey = anonKey ?? supabaseAnonKey;

    if (targetKey.isEmpty || targetKey == 'YOUR_SUPABASE_ANON_KEY_HERE') {
      debugPrint('[Supabase] Info: Anon key belum diisi. Berjalan dalam mode Offline Local Cache (SQLite).');
      return;
    }

    try {
      await Supabase.initialize(
        url: targetUrl,
        anonKey: targetKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
        debug: kDebugMode,
      );
      _isInitialized = true;
      if (kDebugMode) {
        debugPrint('[Supabase] Terhubung ke: $targetUrl');
      }
    } catch (e) {
      debugPrint('[Supabase] Gagal inisialisasi: $e');
    }
  }

  /// Restore explicit Cloud Sync consent after Supabase session restoration.
  /// Call once during application bootstrap, before repositories are used.
  static Future<void> initializeCloudSyncConsent() =>
      CloudSyncConsent.initialize();

  /// Supabase Client instance (null jika offline/belum diinisialisasi)
  static SupabaseClient? get client {
    if (!_isInitialized) return null;
    return Supabase.instance.client;
  }

  /// Mendapatkan user auth yang sedang login (null jika belum login / guest)
  static User? get currentUser {
    if (!_isInitialized) return null;
    try {
      return Supabase.instance.client.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Cloud Sync requires BOTH:
  /// 1. A persisted, explicit user consent decision.
  /// 2. A real Supabase Auth session (anonymous sessions are rejected).
  ///
  /// Login alone never enables personal-data sync. Local SQLite remains the
  /// default source of truth until the user explicitly enables Cloud Sync.
  static bool get canSyncToCloud {
    if (!_isInitialized || !CloudSyncConsent.isEnabled) return false;
    final user = currentUser;
    return user != null && !user.isAnonymous && user.id.isNotEmpty;
  }

  /// The identity of a non-anonymous authenticated user.
  /// This is deliberately independent of Cloud Sync consent.
  static String? get currentAuthUserId {
    final user = currentUser;
    if (user == null || user.isAnonymous || user.id.isEmpty) return null;
    return user.id;
  }

  /// Enable Cloud Sync only after a non-anonymous account has signed in and
  /// the user has explicitly accepted the Cloud Sync terms in the UI.
  static Future<void> enableCloudSync() async {
    if (!_isInitialized) {
      throw StateError('Supabase is not initialized.');
    }

    final user = currentUser;
    if (user == null || user.isAnonymous || user.id.isEmpty) {
      throw StateError('Sign in with a non-anonymous account before enabling Cloud Sync.');
    }

    await CloudSyncConsent.setEnabled(true);
  }

  /// Disable future cloud reads/writes while keeping local SQLite data intact.
  static Future<void> disableCloudSync() =>
      CloudSyncConsent.setEnabled(false);
}


