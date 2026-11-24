import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import '../config/firebase_config.dart';

/// Pembungkus tipis Firebase Analytics.
///
/// Semua method aman dipanggil kapan saja: jika Firebase belum aktif
/// (mis. desktop/web atau inisialisasi gagal), pemanggilan diabaikan dan
/// aplikasi tetap berjalan normal.
class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics? get _analytics => FirebaseConfig.analytics;

  /// True jika Firebase Analytics siap menerima event.
  bool get isAvailable => _analytics != null;

  /// Event custom. Nama event maksimal 40 karakter, parameter maksimal 25
  /// dan hanya mendukung tipe String/num.
  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    final analytics = _analytics;
    if (analytics == null) return;

    try {
      await analytics.logEvent(name: name, parameters: parameters);
    } catch (error) {
      debugPrint('[Analytics] Gagal mencatat "$name": $error');
    }
  }

  /// Standar Firebase: `screen_view`.
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    final analytics = _analytics;
    if (analytics == null) return;

    try {
      await analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (error) {
      debugPrint('[Analytics] Gagal mencatat screen_view: $error');
    }
  }

  /// Mengaitkan event dengan user (mis. ID Supabase yang sudah login).
  Future<void> setUserId(String? id) async {
    final analytics = _analytics;
    if (analytics == null) return;

    try {
      await analytics.setUserId(id: id);
    } catch (error) {
      debugPrint('[Analytics] Gagal set user id: $error');
    }
  }

  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    final analytics = _analytics;
    if (analytics == null) return;

    try {
      await analytics.setUserProperty(name: name, value: value);
    } catch (error) {
      debugPrint('[Analytics] Gagal set property "$name": $error');
    }
  }

  /// Berguna saat user logout / meminta data analytics dihapus.
  Future<void> reset() async {
    final analytics = _analytics;
    if (analytics == null) return;

    try {
      await analytics.resetAnalyticsData();
    } catch (error) {
      debugPrint('[Analytics] Gagal reset data: $error');
    }
  }
}
