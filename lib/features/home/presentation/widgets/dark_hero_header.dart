import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';

/// Header Atas Gelap dengan Karakter Coach Adi (Referensi Baru 1:1)
class DarkHeroHeader extends StatelessWidget {
  final String userName;
  final String programName;
  final VoidCallback? onProgramTap;
  final VoidCallback? onNotificationTap;

  const DarkHeroHeader({
    super.key,
    required this.userName,
    required this.programName,
    this.onProgramTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF141718),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Aksen Glow Hijau Neon di Kanan Belakang Coach
          Positioned(
            right: -20,
            top: 40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF84CC16).withValues(alpha: .35),
                    const Color(0xFF84CC16).withValues(alpha: .0),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Bar: Brand Kiri & Notifikasi Kanan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Logo + Title
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF84CC16),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.fitness_center_rounded,
                            color: Color(0xFF141718),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Home Bulking',
                              style: AppTypography.labelLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              'Coach',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white70,
                                fontSize: 11,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Tombol Notifikasi
                    InkWell(
                      onTap: onNotificationTap,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF232729),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .08),
                            width: 1,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            Positioned(
                              top: 8,
                              right: 9,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF84CC16),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // 2. Baris Utama: Teks Sapaan & Karakter Coach Adi
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Sapaan & Pill Program di Kiri
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, $userName 👋',
                            style: AppTypography.headlineLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Ready to build\nmuscle at home?',
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 14,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Pill Capsule: "Your Program: Muscle Gain (Bulking)"
                          InkWell(
                            onTap: onProgramTap,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x18000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEAF8D2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.track_changes_rounded,
                                      color: Color(0xFF4D7C0F),
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Your Program',
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                                color: const Color(0xFF6B7280),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        Text(
                                          programName,
                                          style: AppTypography.bodyMedium
                                              .copyWith(
                                                color: const Color(0xFF141718),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Color(0xFF9CA3AF),
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Foto Coach Adi Bersedekap di Kanan
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: 170,
                        child: Image.asset(
                          'assets/images/coach_crossed_arms.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 80,
                                  color: Colors.white24,
                                ),
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
