import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Konfigurasi Supabase untuk CMS Program Latihan:
/// - Project ID: wacmyyrruxusztwqyntr
/// - URL: https://wacmyyrruxusztwqyntr.supabase.co
class SupabaseConfig {
  SupabaseConfig._();

  static const String projectId = 'wacmyyrruxusztwqyntr';
  static const String supabaseUrl = 'https://$projectId.supabase.co';

  // Anon / Publishable Key (Client Key)
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_2qpIcaoloKN-joznYZsyGw__j5GRrtL',
  );

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// Inisialisasi aman Supabase client:
  /// Jika kunci anon belum diisi, aplikasi tetap berjalan normal menggunakan fallback local SQLite
  static Future<void> initialize({String? anonKey}) async {
    final key = anonKey ?? supabaseAnonKey;
    if (key.isEmpty || key == 'YOUR_SUPABASE_ANON_KEY_HERE') {
      debugPrint('[Supabase] Warning: Anon key belum diisi. Aplikasi berjalan dalam mode Offline Local Cache.');
      return;
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: key,
      );
      _isInitialized = true;
      debugPrint('[Supabase] Berhasil terhubung ke project: $projectId');
    } catch (e) {
      debugPrint('[Supabase] Gagal inisialisasi: $e');
    }
  }

  static SupabaseClient? get client {
    if (!_isInitialized) return null;
    return Supabase.instance.client;
  }
}

