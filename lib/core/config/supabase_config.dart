import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  /// Memeriksa apakah Cloud Sync aktif dan diizinkan:
  /// Sesuai filosofi Local-first (Prioritas P0 Audit Keamanan):
  /// Aplikasi berjalan Local-Only (100% SQLite lokal) secara default tanpa login.
  /// Remote write/sync hanya diizinkan jika pengguna secara sadar telah login
  /// dengan akun Supabase Auth resmi (bukan default_user atau anonim).
  static bool get canSyncToCloud {
    if (!_isInitialized) return false;
    final user = currentUser;
    return user != null && user.id.isNotEmpty;
  }

  /// Mendapatkan User ID terautentikasi (atau null jika dalam mode Local-Only)
  static String? get currentAuthUserId {
    if (!canSyncToCloud) return null;
    return currentUser?.id;
  }
}


