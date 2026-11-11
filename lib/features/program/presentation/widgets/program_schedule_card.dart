import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../domain/models/workout_program.dart';

/// Kartu "Weekly Schedule" (Mockup Referensi 1:1)
class ProgramScheduleCard extends StatelessWidget {
  final WorkoutProgram program;

  const ProgramScheduleCard({
    super.key,
    required this.program,
  });

  @override
  Widget build(BuildContext context) {
    // Definisi jadwal 7 hari sesuai pola program Upper Body (4 Latihan, 3 Rest)
    final scheduleDays = [
      _ScheduleDayData(dayName: 'Mon', label: 'Push', isWorkout: true),
      _ScheduleDayData(dayName: 'Tue', label: 'Pull', isWorkout: true),
      _ScheduleDayData(dayName: 'Wed', label: 'Rest', isWorkout: false),
      _ScheduleDayData(dayName: 'Thu', label: 'Mix', isWorkout: true),
      _ScheduleDayData(dayName: 'Fri', label: 'Rest', isWorkout: false),
      _ScheduleDayData(dayName: 'Sat', label: 'Full', isWorkout: true),
      _ScheduleDayData(dayName: 'Sun', label: 'Rest', isWorkout: false),
    ];

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          AppSectionHeader(
            icon: Icons.calendar_today_rounded,
            title: 'Weekly Schedule',
            trailing: Text(
              '${program.daysPerWeek} workouts / week',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.neutral500,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 7 Chips Hari: Mon - Sun
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: scheduleDays.map((day) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5),
                  child: _ScheduleDayChip(data: day),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ScheduleDayData {
  final String dayName;
  final String label;
  final bool isWorkout;

  const _ScheduleDayData({
    required this.dayName,
    required this.label,
    required this.isWorkout,
  });
}

class _ScheduleDayChip extends StatelessWidget {
  final _ScheduleDayData data;

  const _ScheduleDayChip({required this.data});

  @override
  Widget build(BuildContext context) {
    final isWorkout = data.isWorkout;
    final backgroundColor = isWorkout
        ? const Color(0xFFE2F87A) // Lime tint
        : AppColors.surface;
    final borderColor = isWorkout
        ? const Color(0xFFD4F356)
        : AppColors.neutral200;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon Dumbbell / Bulan Rest
          Icon(
            isWorkout
                ? Icons.fitness_center_rounded
                : Icons.nightlight_round,
            size: 16,
            color: isWorkout
                ? AppColors.darkCharcoal
                : const Color(0xFF64748B),
          ),
          const SizedBox(height: 6),

          // Nama Hari (Mon, Tue, ...)
          Text(
            data.dayName,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.darkCharcoal,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),

          // Label Fokus (Push, Pull, Rest, Mix, Full)
          Text(
            data.label,
            style: AppTypography.labelSmall.copyWith(
              color: isWorkout
                  ? AppColors.darkCharcoal
                  : const Color(0xFF64748B),
              fontWeight: FontWeight.w700,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

