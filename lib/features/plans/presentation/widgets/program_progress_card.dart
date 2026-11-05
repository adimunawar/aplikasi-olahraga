import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

/// Card Program Progress pada Tab Program:
/// - Judul: "Program Progress"
/// - Info kanan: "Week 3 of 8" + badge hijau lime "37%"
/// - Linear progress bar tebal berujung membulat
class ProgramProgressCard extends StatelessWidget {
  final int currentWeek;
  final int totalWeeks;
  final double progressPercent; // 0.0 - 1.0

  const ProgramProgressCard({
    super.key,
    this.currentWeek = 3,
    this.totalWeeks = 8,
    this.progressPercent = 0.37,
  });

  @override
  Widget build(BuildContext context) {
    final percentInt = (progressPercent * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Program Progress',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: const Color(0xFF141718),
              ),
            ),
            Row(
              children: [
                Text(
                  'Week $currentWeek of $totalWeeks',
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF8D5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$percentInt%',
                    style: AppTypography.labelSmall.copyWith(
                      color: const Color(0xFF4D7C0F),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progressPercent,
            minHeight: 9,
            backgroundColor: const Color(0xFFE9ECEF),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB8E66B)),
          ),
        ),
      ],
    );
  }
}

