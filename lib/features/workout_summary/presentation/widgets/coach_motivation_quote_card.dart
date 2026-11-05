import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

/// Card Kutipan Motivasi Coach Adi pada Akhir Sesi (Mockup 1:1):
/// - Sisi kiri: Foto Coach Adi menunjuk ke depan dengan blob hijau lime
/// - Sisi kanan: Tanda kutip hijau "“", teks motivasi italic, dan garis hijau bawah
class CoachMotivationQuoteCard extends StatelessWidget {
  final String quoteText;

  const CoachMotivationQuoteCard({
    super.key,
    this.quoteText =
        'Latihan yang konsisten seperti ini akan membantu kamu membangun massa otot dan tubuh yang lebih kuat. Pertahankan!',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Foto Coach Adi Menunjuk dengan Blob Hijau
          SizedBox(
            width: 105,
            height: 115,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  left: 6,
                  bottom: 6,
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE2F9A3),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(44),
                        topRight: Radius.circular(40),
                        bottomLeft: Radius.circular(38),
                        bottomRight: Radius.circular(50),
                      ),
                    ),
                  ),
                ),
                Image.asset(
                  'assets/images/coach_pointing_pose.png',
                  height: 110,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/coach_pointing.png',
                    height: 110,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Kutipan Motivasi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tanda Kutip Hijau Besar
                const Text(
                  '““',
                  style: TextStyle(
                    color: Color(0xFF84CC16),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 0.8,
                  ),
                ),
                const SizedBox(height: 4),

                // Teks Motivasi Italic
                Text(
                  quoteText,
                  style: AppTypography.bodySmall.copyWith(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    fontSize: 12.5,
                    height: 1.4,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),

                // Garis Aksen Hijau di Bawah
                Container(
                  width: 60,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF84CC16),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

