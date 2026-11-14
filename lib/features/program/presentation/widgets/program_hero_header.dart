import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_smart_image.dart';
import '../../domain/models/workout_program.dart';

/// Hero Card Header untuk Program Detail (Mockup Referensi 1:1)
class ProgramHeroHeader extends StatelessWidget {
  final WorkoutProgram program;

  const ProgramHeroHeader({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF16241B),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Gambar Background Atlet Push-Up di sebelah kanan
            Positioned(
              right: -20,
              top: 0,
              bottom: 0,
              width: 220,
              child: Opacity(
                opacity: 0.9,
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.transparent, Colors.black],
                      stops: [0.0, 0.45],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: const AppSmartImage(
                    imagePathOrUrl: 'assets/images/exercises/push_up.webp',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Aksen Lengkungan Hijau Neon di Sudut Kanan Bawah
            Positioned(
              right: -30,
              bottom: -40,
              child: Container(
                width: 140,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.limeAccent.withValues(alpha: 0.9),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.elliptical(120, 80),
                  ),
                ),
              ),
            ),

            // Konten Teks & Metadata Program
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge Difficulty (e.g. Beginner)
                  AppBadge(
                    label: program.difficulty.label,
                    variant: AppBadgeVariant.limeAccent,
                    fontSize: 11.5,
                  ),
                  const SizedBox(height: 12),

                  // Judul Program
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.62,
                    child: Text(
                      program.title.en,
                      style: AppTypography.displayMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 23,
                        height: 1.15,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Deskripsi Singkat
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.58,
                    child: Text(
                      program.description.en,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Baris Metadata Program: 8 Weeks | 4 Days/Week | ~30 Min/Session
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMetaItem(
                          icon: Icons.calendar_today_rounded,
                          title: '${program.totalWeeks}',
                          subtitle: 'Weeks',
                        ),
                        _buildMetaDivider(),
                        _buildMetaItem(
                          icon: Icons.date_range_rounded,
                          title: '${program.daysPerWeek}',
                          subtitle: 'Days/Week',
                        ),
                        _buildMetaDivider(),
                        _buildMetaItem(
                          icon: Icons.timer_outlined,
                          title: '~30',
                          subtitle: 'Min/Session',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.limeAccent),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: AppTypography.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
                height: 1.1,
              ),
            ),
            Text(
              subtitle,
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 10,
                height: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetaDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: 1,
      height: 24,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}
