import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';

/// Hero Card Kurikulum & Roadmap Program (1:1 Sesuai Referensi Desain dengan Frosted Glass Samar-samar)
class RoadmapHeaderCard extends StatelessWidget {
  final String programTitle;
  final int currentWeek;
  final int totalWeeks;
  final int progressPercent;
  final int weeklySessions;
  final VoidCallback onSwitchProgram;

  const RoadmapHeaderCard({
    super.key,
    required this.programTitle,
    required this.currentWeek,
    this.totalWeeks = 4,
    this.progressPercent = 25,
    this.weeklySessions = 3,
    required this.onSwitchProgram,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF141718),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 1. Bentuk Melengkung Hijau Neon Organik di Kanan Belakang Coach (Persis Referensi)
          Positioned(
            right: -20,
            top: 25,
            bottom: 0,
            width: 150,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(130),
                  bottomLeft: Radius.circular(50),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    const Color(0xFF84CC16).withOpacity(0.95),
                    const Color(0xFF84CC16).withOpacity(0.70),
                    const Color(0xFF4D7C0F).withOpacity(0.35),
                  ],
                ),
              ),
            ),
          ),

          // 2. Foto Coach Adi Bersedekap di Kanan
          Positioned(
            right: -5,
            bottom: 0,
            top: 10,
            width: 155,
            child: Image.asset(
              'assets/images/coach_crossed_arms.png',
              fit: BoxFit.contain,
              alignment: Alignment.bottomRight,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),

          // 3. Konten Teks & Frosted Glass Samar-samar di Atas Gambar
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tag Atas
                Text(
                  'Kurikulum & Roadmap',
                  style: AppTypography.labelSmall.copyWith(
                    color: const Color(0xFF84CC16),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),

                // Judul Program (Membatasi lebar agar tidak menabrak foto)
                SizedBox(
                  width: 195,
                  child: Text(
                    programTitle,
                    style: AppTypography.headlineLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 10),

                // Meta Info Row
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$totalWeeks Minggu Total',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white70,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.fitness_center_rounded,
                      size: 12,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$weeklySessions Sesi / Minggu',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white70,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.track_changes_rounded,
                      size: 12,
                      color: Color(0xFF84CC16),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Double Progression',
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFF84CC16),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 4. Inner Progress Box dengan Efek FROSTED GLASS SAMAR-SAMAR (BackdropFilter Blur)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Target Program Keseluruhan',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          'Week $currentWeek dari $totalWeeks ',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '($progressPercent%)',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: const Color(0xFF84CC16),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: (progressPercent / 100).clamp(0.05, 1.0),
                              minHeight: 6,
                              backgroundColor: Colors.white.withOpacity(0.15),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF84CC16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
