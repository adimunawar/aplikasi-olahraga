import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

/// Banner Quick Access ke Perpustakaan 18 Gerakan Biomekanika (1:1 Sesuai Referensi Desain)
class ExerciseLibraryBanner extends StatelessWidget {
  final VoidCallback onOpenLibrary;

  const ExerciseLibraryBanner({
    super.key,
    required this.onOpenLibrary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF141718),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Icon Buku Hijau Neon di Kiri
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF84CC16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Color(0xFF141718),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Teks Tengah
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PERPUSTAKAAN GERAKAN',
                  style: AppTypography.labelSmall.copyWith(
                    color: const Color(0xFF84CC16),
                    fontWeight: FontWeight.w800,
                    fontSize: 9.5,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '18 Gerakan & Tangga Progresi',
                  style: AppTypography.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Cek video & biomekanika form yang benar',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white60,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Tombol Buka → di Kanan
          Material(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onOpenLibrary,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Buka',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
