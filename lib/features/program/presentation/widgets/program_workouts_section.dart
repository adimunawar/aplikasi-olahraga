import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_smart_image.dart';
import '../../domain/models/program_day.dart';
import '../../domain/models/workout_program.dart';

/// Section "Program Workouts" dengan Week Selector Tab & Daftar Sesi (Mockup 1:1)
class ProgramWorkoutsSection extends StatelessWidget {
  final WorkoutProgram program;
  final int selectedWeek;
  final ValueChanged<int> onSelectWeek;
  final ValueChanged<ProgramDay>? onDayTap;

  const ProgramWorkoutsSection({
    super.key,
    required this.program,
    required this.selectedWeek,
    required this.onSelectWeek,
    this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    // Ambil daftar hari dari minggu yang sedang dipilih
    final weekIndex = (selectedWeek - 1).clamp(0, program.weeks.length - 1);
    final currentWeekData = program.weeks.isNotEmpty
        ? program.weeks[weekIndex]
        : null;

    // Filter hanya sesi latihan dan sesi istirahat aktif utama (4 hari latihan + 1 istirahat pemulihan sesuai mockup)
    final daysToShow = (currentWeekData?.days ?? []).take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        const AppSectionHeader(
          icon: Icons.layers_rounded,
          title: 'Program Workouts',
        ),
        const SizedBox(height: 14),

        // Horizontal Week Selector (Week 1 - Week 8)
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: program.totalWeeks,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final weekNum = index + 1;
              final isSelected = weekNum == selectedWeek;

              return InkWell(
                onTap: () => onSelectWeek(weekNum),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.limeAccent
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.limeAccent
                          : AppColors.neutral200,
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    'Week $weekNum',
                    style: AppTypography.labelMedium.copyWith(
                      color: isSelected
                          ? AppColors.darkCharcoal
                          : AppColors.neutral600,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Container Kartu Daftar Sesi Latihan Minggu Ini
        AppCard(
          padding: EdgeInsets.zero,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysToShow.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.neutral200,
            ),
            itemBuilder: (context, index) {
              final day = daysToShow[index];
              return _WorkoutSessionTile(
                day: day,
                onTap: () => onDayTap?.call(day),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WorkoutSessionTile extends StatelessWidget {
  final ProgramDay day;
  final VoidCallback? onTap;

  const _WorkoutSessionTile({
    required this.day,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = day.title ?? 'Day ${day.day} – Workout';
    final focusText = day.focus.en;
    final isRest = day.isRest;
    final thumbnail = day.thumbnailAsset ??
        (isRest
            ? 'assets/images/onboarding_bg.jpg'
            : 'assets/images/exercises/push_up.webp');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Thumbnail Sesi (AppSmartImage sesuai architecture.md)
            Container(
              width: 76,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.neutral100,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AppSmartImage(
                  imagePathOrUrl: thumbnail,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info Judul & Target Otot
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.darkCharcoal,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    focusText,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.neutral500,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Indikator Durasi atau Rest
            if (isRest)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.bed_outlined,
                    size: 16,
                    color: Color(0xFF22C55E),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Rest',
                    style: AppTypography.labelSmall.copyWith(
                      color: const Color(0xFF22C55E),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 15,
                    color: AppColors.neutral500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${day.estimatedDurationMinutes} min',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.neutral500,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.neutral400,
            ),
          ],
        ),
      ),
    );
  }
}

