import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';

enum DayActivityState { completed, today, rest, upcoming, missed }

class DayProgressData {
  final String dayName;
  final DayActivityState state;
  final DateTime date;

  const DayProgressData({
    required this.dayName,
    required this.state,
    required this.date,
  });
}

/// Kartu Progres Mingguan 7 Hari (Mockup 1:1)
class WeeklyProgressCalendarCard extends StatelessWidget {
  final List<DayProgressData> days;
  final VoidCallback onSeeDetails;

  const WeeklyProgressCalendarCard({
    super.key,
    required this.days,
    required this.onSeeDetails,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.home.weeklyProgress.title,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppColors.darkCharcoal,
                ),
              ),
              InkWell(
                onTap: onSeeDetails,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Text(
                    t.home.weeklyProgress.seeDetails,
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF65A30D),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 7-Days Row Container
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.neutral200, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: days.map((day) => _buildDayItem(day)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem(DayProgressData day) {
    final isToday = day.state == DayActivityState.today;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isToday ? 8 : 4,
        vertical: isToday ? 6 : 4,
      ),
      decoration: isToday
          ? BoxDecoration(
              color: const Color(0xFFF4FBEB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF84CC16), width: 1.5),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nama Hari (Mon, Tue, Wed, ...)
          Text(
            day.dayName,
            style: AppTypography.bodySmall.copyWith(
              fontSize: 11,
              fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
              color: isToday ? AppColors.darkCharcoal : AppColors.neutral500,
            ),
          ),
          const SizedBox(height: 6),

          // Ikon / Bentuk Status
          _buildStateIndicator(day.state),
        ],
      ),
    );
  }

  Widget _buildStateIndicator(DayActivityState state) {
    switch (state) {
      case DayActivityState.completed:
        return Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: Color(0xFF84CC16),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              color: AppColors.darkCharcoal,
              size: 16,
            ),
          ),
        );

      case DayActivityState.today:
        return Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF8D5),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF84CC16), width: 1.2),
          ),
          child: const Center(
            child: Icon(
              Icons.fitness_center_rounded,
              color: Color(0xFF65A30D),
              size: 14,
            ),
          ),
        );

      case DayActivityState.rest:
        return Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.neutral200, width: 1.2),
          ),
          child: const Center(
            child: Icon(
              Icons.bed_rounded,
              color: AppColors.neutral400,
              size: 13,
            ),
          ),
        );

      case DayActivityState.missed:
        return Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: Color(0xFFFEE2E2),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.close_rounded,
              color: Color(0xFFDC2626),
              size: 15,
            ),
          ),
        );

      case DayActivityState.upcoming:
        return Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.neutral300, width: 1.5),
          ),
        );
    }
  }
}
