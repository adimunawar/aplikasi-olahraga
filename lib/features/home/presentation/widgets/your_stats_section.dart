import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';

/// Bagian "Your Stats" dengan 3 Metrik (Workouts, Duration, Streak) (Referensi Baru 1:1)
class YourStatsSection extends StatelessWidget {
  final int workoutsThisWeek;
  final int totalDurationMinutes;
  final int dayStreak;
  final VoidCallback? onViewProgress;

  const YourStatsSection({
    super.key,
    required this.workoutsThisWeek,
    required this.totalDurationMinutes,
    required this.dayStreak,
    this.onViewProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Your Stats & View Progress >
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Stats',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: const Color(0xFF141718),
              ),
            ),
            InkWell(
              onTap: onViewProgress,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Progress',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Color(0xFF16A34A),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Row 3 Kotak Metrik
        Row(
          children: [
            // Kotak 1: Workouts This Week
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFEFF1F4),
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: Color(0xFFF97316),
                          size: 19,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$workoutsThisWeek',
                          style: AppTypography.headlineSmall.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: const Color(0xFF141718),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 28,
                      child: Text(
                        'Workouts\nThis Week',
                        style: AppTypography.bodySmall.copyWith(
                          color: const Color(0xFF6B7280),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Kotak 2: Total Duration
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFEFF1F4),
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          color: Color(0xFF16A34A),
                          size: 19,
                        ),
                        const SizedBox(width: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '$totalDurationMinutes ',
                                style: AppTypography.headlineSmall.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: const Color(0xFF141718),
                                ),
                              ),
                              TextSpan(
                                text: 'min',
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  color: const Color(0xFF141718),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 28,
                      child: Text(
                        'Total\nDuration',
                        style: AppTypography.bodySmall.copyWith(
                          color: const Color(0xFF6B7280),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Kotak 3: Day Streak (Aksen Hijau Lembut)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F9EA),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFDCFCE7),
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.trending_up_rounded,
                          color: Color(0xFF16A34A),
                          size: 19,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$dayStreak',
                          style: AppTypography.headlineSmall.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: const Color(0xFF141718),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 28,
                      child: Text(
                        'Day\nStreak',
                        style: AppTypography.bodySmall.copyWith(
                          color: const Color(0xFF15803D),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
