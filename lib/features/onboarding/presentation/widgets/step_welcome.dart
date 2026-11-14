import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_smart_image.dart';
import '../../../../i18n/strings.g.dart';

/// Step 0: Welcome Screen Content (Mockup 1:1 Visual Match)
class StepWelcome extends StatelessWidget {
  const StepWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context).onboarding.welcome;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Logo "● ● Coach" di Kiri Atas sesuai Mockup
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dua titik/pill hijau limau khas brand
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF84CC16),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF84CC16),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Text(
                'Coach',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: -0.3,
                  color: AppColors.darkCharcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2. Hero Coach Image dengan Soft Lime Organic Card Background
          Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.46,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Latar Belakang Kartu Hijau Limau Halus dengan Sudut Melengkung
                  Positioned.fill(
                    top: 24,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFE8F7CD),
                            Color(0xFFF4FDE5),
                            Color(0xFFE2F5BE),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Hero Coach Image
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: const AppSmartImage(
                        imagePathOrUrl: 'assets/images/coach_hero.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Soft Fade Gradient di bagian bawah agar menyatu mulus ke kanvas putih
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: 0.8),
                            Colors.white,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 3. Judul 2 Warna: Baris 1 (Hitam) & Baris 2 (Lime Green) sesuai Locale
          Builder(
            builder: (context) {
              final titleParts = t.title.split('\n');
              final firstLine = titleParts.isNotEmpty ? titleParts.first : t.title;
              final secondLine = titleParts.length > 1 ? titleParts.sublist(1).join('\n') : '';

              return Text.rich(
                TextSpan(
                  style: AppTypography.displayMedium.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                    height: 1.15,
                    letterSpacing: -0.8,
                  ),
                  children: [
                    TextSpan(
                      text: '$firstLine\n',
                      style: const TextStyle(
                        color: Color(0xFF141718),
                      ),
                    ),
                    if (secondLine.isNotEmpty)
                      TextSpan(
                        text: secondLine,
                        style: const TextStyle(
                          color: Color(0xFF84CC16),
                        ),
                      ),
                  ],
                ),
              );

            },
          ),

          const SizedBox(height: 12),

          // 4. Subtitle Deskripsi
          Text(
            t.subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: const Color(0xFF475569),
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}


