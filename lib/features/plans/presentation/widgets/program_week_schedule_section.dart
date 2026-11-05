import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_typography.dart';

/// Section "This Week" pada Tab Program:
/// Daftar 4 sesi latihan mingguan dengan indikator selesai (checklist hijau) & belum selesai.
class ProgramWeekScheduleSection extends StatelessWidget {
  const ProgramWeekScheduleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final scheduleItems = [
      _ScheduleDayData(
        dayNumber: 1,
        title: 'Day 1 - Upper Body (A)',
        subtitle: 'Chest • Back • Shoulder • Arms',
        isCompleted: true,
      ),
      _ScheduleDayData(
        dayNumber: 2,
        title: 'Day 2 - Lower Body (A)',
        subtitle: 'Legs • Glutes • Calves',
        isCompleted: false,
      ),
      _ScheduleDayData(
        dayNumber: 3,
        title: 'Day 3 - Upper Body (B)',
        subtitle: 'Back • Chest • Arms • Shoulder',
        isCompleted: false,
      ),
      _ScheduleDayData(
        dayNumber: 4,
        title: 'Day 4 - Lower Body (B)',
        subtitle: 'Legs • Glutes • Core',
        isCompleted: false,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This Week',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 16.5,
            color: const Color(0xFF141718),
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: scheduleItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = scheduleItems[index];
            return _buildScheduleCard(context, item);
          },
        ),
      ],
    );
  }

  Widget _buildScheduleCard(BuildContext context, _ScheduleDayData item) {
    return InkWell(
      onTap: () => _openWorkout(context, item),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: item.isCompleted ? const Color(0xFFF4FBEB) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isCompleted
                ? const Color(0xFFD4EBA8)
                : const Color(0xFFE9ECEF),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Status Icon: Checklist hijau atau circle outline kosong
            if (item.isCompleted)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF88D618),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFCBD5E1),
                    width: 2,
                  ),
                ),
              ),
            const SizedBox(width: 14),

            // Teks Judul & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      color: const Color(0xFF141718),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Chevron Right
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  void _openWorkout(BuildContext context, _ScheduleDayData item) {
    context.push(
      AppRoutes.workoutDetail,
      extra: WorkoutDetailArgs(
        dayNumber: item.dayNumber,
        weekDayText: 'Week 3 • Day ${item.dayNumber}',
        workoutTitle: item.title,
        targetMusclesText: item.subtitle,
        durationText: item.dayNumber.isEven ? '50 min' : '45 min',
        levelText: 'Intermediate',
        description:
            'Build strength and mass for your ${item.subtitle.toLowerCase()}.',
      ),
    );
  }
}

class _ScheduleDayData {
  final int dayNumber;
  final String title;
  final String subtitle;
  final bool isCompleted;

  _ScheduleDayData({
    required this.dayNumber,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
  });
}

