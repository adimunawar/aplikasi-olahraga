import '../models/exercise.dart';

/// Helper memilih teks sesuai bahasa aktif, dengan fallback ke bahasa lain
/// bila terjemahan yang dipilih kosong.
///
/// Tanpa fallback ini, data yang hanya punya satu bahasa akan tampil kosong
/// ketika bahasa aplikasi berbeda.
extension LocalizedStringExtension on LocalizedString {
  String localized(String langCode) {
    final isEn = langCode.toLowerCase().startsWith('en');
    final preferred = isEn ? en : id;
    final fallback = isEn ? id : en;
    return preferred.isNotEmpty ? preferred : fallback;
  }
}
