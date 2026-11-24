import 'package:flutter/foundation.dart';

/// MediaUrlResolver: Mengalihkan URL media Cloudflare R2 (*.r2.dev) ke API proxy backend Next.js
/// agar gambar dan video tidak terkena blokir Internet Positif / ISP Indonesia (Telkomsel, Indihome, FirstMedia, dll.)
class MediaUrlResolver {
  MediaUrlResolver._();

  static const String baseUrl = 'https://workout-coach-admin-m3vp.vercel.app';

  /// 1:1 port dari fungsi web Next.js resolveMediaUrl:
  ///
  /// ```ts
  /// export function resolveMediaUrl(url: string | undefined | null): string {
  ///   if (!url) return "";
  ///   if (url.includes(".r2.dev/")) {
  ///     const key = url.split(".r2.dev/")[1];
  ///     return `/api/media/${key}`;
  ///   }
  ///   return url;
  /// }
  /// ```
  ///
  /// Di Flutter Mobile, relatif URL `/api/media/...` digabungkan dengan base URL:
  /// `https://workout-coach-admin-m3vp.vercel.app/api/media/${key}`
  static String? resolve(String? url) {
    if (url == null) return null;
    final trimmed = url.trim();
    if (trimmed.isEmpty) return trimmed;

    if (trimmed.contains('.r2.dev/')) {
      final key = trimmed.split('.r2.dev/')[1];
      final resolved = '$baseUrl/api/media/$key';
      if (kDebugMode) {
        debugPrint('[MediaUrlResolver] 🔄 Mengalihkan R2 ke Proxy Vercel:');
        debugPrint('  From: $trimmed');
        debugPrint('  Key : $key');
        debugPrint('  To  : $resolved');
      }
      return resolved;
    }

    return trimmed;
  }
}
