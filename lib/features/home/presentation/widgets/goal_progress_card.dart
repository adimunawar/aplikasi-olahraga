import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';

/// Kartu Progres Target Utama Pengguna (Mockup 1:1)
class GoalProgressCard extends StatelessWidget {
  final String goalTitle;
  final double targetWeightKg;
  final double currentWeightKg;
  final int totalWeeks;
  final int currentWeek;
  final VoidCallback? onTap;

  const GoalProgressCard({
    super.key,
    required this.goalTitle,
    required this.targetWeightKg,
    required this.currentWeightKg,
    this.totalWeeks = 12,
    this.currentWeek = 1,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final clampedCurrentWeek = currentWeek.clamp(1, totalWeeks);
    final progressPercent = (clampedCurrentWeek / totalWeeks).clamp(0.0, 1.0);

    final normalizedGoal = goalTitle.toLowerCase();
    final isGainGoal = normalizedGoal.contains('gain') ||
        normalizedGoal.contains('naik') ||
        normalizedGoal.contains('bulk');
    final isLossGoal = normalizedGoal.contains('loss') ||
        normalizedGoal.contains('fat') ||
        normalizedGoal.contains('turun');
    final hasReachedTarget = isGainGoal
        ? currentWeightKg >= targetWeightKg
        : isLossGoal
            ? currentWeightKg <= targetWeightKg
            : (currentWeightKg - targetWeightKg).abs() <= 0.5;
    final remainingToTargetKg = isGainGoal
        ? (targetWeightKg - currentWeightKg).clamp(0.0, double.infinity).toDouble()
        : isLossGoal
            ? (currentWeightKg - targetWeightKg).clamp(0.0, double.infinity).toDouble()
            : (currentWeightKg - targetWeightKg).abs();
    final isIndonesian = Localizations.localeOf(context).languageCode == 'id';
    final targetStatusLabel = hasReachedTarget
        ? (isIndonesian ? 'Target tercapai' : 'Target reached')
        : isIndonesian
            ? '${remainingToTargetKg.toStringAsFixed(1)} kg lagi'
            : '${remainingToTargetKg.toStringAsFixed(1)} kg to go';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFCFDF9), Color(0xFFF7FAF1)],
          ),
          border: Border.all(color: const Color(0xFFD4EBA8), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF84CC16).withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Soft lime glow behind the coach. Keep it subtle so it
              // supports the hero image without creating visible green blocks.
              Positioned(
                right: -36,
                top: 2,
                width: 232,
                height: 232,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFDDF2B4).withValues(alpha: 0.72),
                        const Color(0xFFDDF2B4).withValues(alpha: 0.28),
                        const Color(0xFFDDF2B4).withValues(alpha: 0.0),
                      ],
                      stops: [0.0, 0.58, 1.0],
                    ),
                  ),
                ),
              ),

              // 2. Foto Karakter Coach Presisi (Besar, Kepala Menyentuh Atas, Lengan Bersedekap)
              Positioned(
                right: -2,
                top: 0,
                bottom: 0,
                width: 152,
                child: Image.asset(
                  'assets/images/coach_crossed_arms.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),

              // 3. Konten Teks & Progress di Sisi Kiri
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // A. Header Chip: Goal
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFD4EBA8),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.track_changes_rounded,
                            size: 15,
                            color: Color(0xFF65A30D),
                          ),
                          const SizedBox(width: 6),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 160),
                            child: Text(
                              goalTitle,
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 11.5,
                                color: AppColors.darkCharcoal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // B. Target & Current Row
                    Row(
                      children: [
                        // Target
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.home.goalCard.target,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.neutral500,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${targetWeightKg.toStringAsFixed(1)} kg',
                              style: AppTypography.titleLarge.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: AppColors.darkCharcoal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 22),

                        // Current weight and honest distance-to-target status.
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.home.goalCard.current,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.neutral500,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${currentWeightKg.toStringAsFixed(1)} kg',
                              style: AppTypography.titleLarge.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: AppColors.darkCharcoal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    hasReachedTarget
                                        ? Icons.check_circle_rounded
                                        : Icons.track_changes_rounded,
                                    size: 12,
                                    color: const Color(0xFF15803D),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    targetStatusLabel,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF15803D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // C. Linear Progress Bar
                    SizedBox(
                      width: 175,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progressPercent,
                          minHeight: 7,
                          backgroundColor: const Color(0xFFE2EAD6),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF84CC16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // D. Program Timeline Info
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: Color(0xFF65A30D),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          t.home.goalCard.programDuration(weeks: totalWeeks),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.neutral600,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          t.home.goalCard.weekOf(
                            current: clampedCurrentWeek,
                            total: totalWeeks,
                          ),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.darkCharcoal,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
