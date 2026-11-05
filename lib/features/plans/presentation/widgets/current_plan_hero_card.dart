import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_widgets.dart';

/// Hero Card "Current Plan" pada Halaman Plans (Mockup Baru 1:1):
/// - Kiri: Coach Adi bersedekap dengan blob lime di belakangnya & 3 garis aksen
/// - Kanan: Badge "Current Plan", tombol '...', Judul, Deskripsi,
///   serta "Week X of Y" dengan progress bar.
class CurrentPlanHeroCard extends StatelessWidget {
  final String title;
  final String description;
  final int currentWeek;
  final int totalWeeks;
  final double progressPercent;
  final VoidCallback? onOptions;

  const CurrentPlanHeroCard({
    super.key,
    this.title = 'Upper Body Strength',
    this.description =
        'Build a stronger chest, back, arms, and shoulders at home.',
    this.currentWeek = 3,
    this.totalWeeks = 8,
    this.progressPercent = 0.37,
    this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: AppColors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Blob Hijau Lime & Garis Aksen di Balik Coach
            Positioned(
              left: -15,
              bottom: -20,
              child: CustomPaint(
                size: const Size(160, 190),
                painter: _CoachLimeBlobPainter(),
              ),
            ),

            // Foto Coach Adi Bersedekap di Kiri (DRY via AppSmartImage)
            Positioned(
              left: 4,
              bottom: 0,
              top: 14,
              width: 140,
              child: AppSmartImage(
                imagePathOrUrl: 'assets/images/coach_crossed_arms.png',
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
                errorWidget: const AppSmartImage(
                  imagePathOrUrl: 'assets/images/coach_character.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),

            // Konten Teks & Progres di Kanan
            Padding(
              padding: const EdgeInsets.only(
                left: 148,
                right: 16,
                top: 16,
                bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baris 1: Badge "Current Plan" & Tombol '...'
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Badge "Current Plan" (DRY via AppBadge)
                      AppBadge.currentPlan(),
                      GestureDetector(
                        onTap: onOptions,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: AppColors.neutral100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.more_horiz_rounded,
                            size: 18,
                            color: AppColors.neutral500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Baris 2: Icon Dumbbell & Judul
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.limeSurface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.fitness_center_rounded,
                          size: 15,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: AppColors.darkCharcoal,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Baris 3: Deskripsi Singkat
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.neutral500,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Baris 4: "Week X of Y" & "Z%"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Week $currentWeek of $totalWeeks',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.neutral600,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${(progressPercent * 100).round()}%',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.darkCharcoal,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Baris 5: Progress Bar Hijau Lime Tebal
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progressPercent,
                      minHeight: 8,
                      backgroundColor: AppColors.neutral200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
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
}

class _CoachLimeBlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final blobPaint = Paint()
      ..color = AppColors.limeAccent.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.05,
        size.height * 0.35,
        size.width * 0.45,
        size.height * 0.2,
      )
      ..quadraticBezierTo(
        size.width * 0.95,
        size.height * 0.05,
        size.width * 0.9,
        size.height * 0.55,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.95,
        size.width * 0.4,
        size.height * 0.9,
      )
      ..close();

    canvas.drawPath(path, blobPaint);

    final accentPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.22, size.height * 0.18),
      Offset(size.width * 0.16, size.height * 0.13),
      accentPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.29, size.height * 0.12),
      Offset(size.width * 0.28, size.height * 0.05),
      accentPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.38, size.height * 0.15),
      Offset(size.width * 0.44, size.height * 0.09),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
