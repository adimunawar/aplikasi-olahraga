import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../../program/domain/models/program_day.dart';

/// Section "Workouts in This Plan" pada Halaman Plans:
/// - Header: "Workouts in This Plan" & "X weeks • Y days/week"
/// - Menampilkan daftar kartu sesi latihan dan rest day pada minggu terpilih secara dinamis
class WorkoutsInThisPlanSection extends StatelessWidget {
  final int totalWeeks;
  final int daysPerWeek;
  final int selectedWeek;
  final List<ProgramDay> days;
  final Set<int> completedDayNumbers;

  const WorkoutsInThisPlanSection({
    super.key,
    this.totalWeeks = 8,
    this.daysPerWeek = 4,
    this.selectedWeek = 3,
    this.days = const [],
    this.completedDayNumbers = const {1, 2},
  });

  @override
  Widget build(BuildContext context) {
    // Ambil hari-hari aktif dan rest day yang terdefinisi pada minggu ini (maksimal 4 sesi utama seperti mockup)
    final displayDays = days.isNotEmpty
        ? days.take(4).toList()
        : _buildDefaultDays();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header (DRY via AppSectionHeader)
        AppSectionHeader.withSubtitle(
          icon: Icons.format_list_bulleted_rounded,
          title: 'Workouts in This Plan',
          subtitle: '$totalWeeks weeks • $daysPerWeek days/week',
        ),
        const SizedBox(height: 12),

        // Daftar Kartu Sesi Latihan
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayDays.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final pDay = displayDays[index];
            final dayNumber = index + 1;
            final programDayNumber = pDay.day > 0
                ? pDay.day
                : ((selectedWeek - 1) * daysPerWeek + dayNumber);
            final isCompleted = completedDayNumbers.contains(dayNumber);
            final isRestDay = pDay.isRest;

            final title = isRestDay
                ? 'Day $dayNumber – Rest or Active Recovery'
                : 'Day $dayNumber – ${_formatDayTitle(pDay, dayNumber)}';

            final targetMuscles = _formatFocusText(pDay, dayNumber);

            return _buildWorkoutCard(
              context: context,
              dayNumber: dayNumber,
              programDayNumber: programDayNumber,
              title: title,
              targetMuscles: targetMuscles,
              isCompleted: isCompleted,
              isRestDay: isRestDay,
            );
          },
        ),
      ],
    );
  }

  String _formatDayTitle(ProgramDay day, int dayNumber) {
    if (day.isRest) return 'Rest or Active Recovery';
    switch (day.type) {
      case WorkoutTypeCode.p:
        return dayNumber == 1 ? 'Push' : 'Pull';
      case WorkoutTypeCode.k:
        return 'Legs';
      case WorkoutTypeCode.c:
        return 'Core & Abs';
      case WorkoutTypeCode.f:
        return 'Upper Mix';
      case WorkoutTypeCode.r:
      return 'Rest or Active Recovery';
    }
  }

  String _formatFocusText(ProgramDay day, int dayNumber) {
    if (day.isRest) {
      return (day.focus.en.isNotEmpty ? day.focus.en : day.focus.id).isNotEmpty
          ? (day.focus.en.isNotEmpty ? day.focus.en : day.focus.id)
          : 'Rest, or light activity like stretching.';
    }
    if (day.focus.en.isNotEmpty) return day.focus.en;
    if (day.focus.id.isNotEmpty) return day.focus.id;
    switch (dayNumber) {
      case 1:
        return 'Chest • Shoulders • Triceps (Week $selectedWeek)';
      case 2:
        return 'Back • Biceps (Week $selectedWeek)';
      case 4:
        return 'Chest • Back • Shoulders • Arms (Week $selectedWeek)';
      default:
        return 'Full Body Conditioning (Week $selectedWeek)';
    }
  }

  List<ProgramDay> _buildDefaultDays() {
    return const [
      ProgramDay(
        day: 1,
        week: 3,
        type: WorkoutTypeCode.p,
        focus: LocalizedString(id: 'Dada • Bahu • Triceps', en: 'Chest • Shoulders • Triceps'),
        isRest: false,
        isRetestMilestone: false,
        items: [],
      ),
      ProgramDay(
        day: 2,
        week: 3,
        type: WorkoutTypeCode.p,
        focus: LocalizedString(id: 'Punggung • Biceps', en: 'Back • Biceps'),
        isRest: false,
        isRetestMilestone: false,
        items: [],
      ),
      ProgramDay(
        day: 3,
        week: 3,
        type: WorkoutTypeCode.r,
        focus: LocalizedString(
          id: 'Istirahat atau aktivitas ringan seperti stretching.',
          en: 'Rest, or light activity like stretching.',
        ),
        isRest: true,
        isRetestMilestone: false,
        items: [],
      ),
      ProgramDay(
        day: 4,
        week: 3,
        type: WorkoutTypeCode.f,
        focus: LocalizedString(
          id: 'Dada • Punggung • Bahu • Lengan',
          en: 'Chest • Back • Shoulders • Arms',
        ),
        isRest: false,
        isRetestMilestone: false,
        items: [],
      ),
    ];
  }

  Widget _buildWorkoutCard({
    required BuildContext context,
    required int dayNumber,
    required int programDayNumber,
    required String title,
    required String targetMuscles,
    required bool isCompleted,
    required bool isRestDay,
  }) {
    final cardContent = Row(
      children: [
        // Icon Gerakan (Dumbbell miring) atau Icon Istirahat (Bed)
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isRestDay ? AppColors.limeSurface : AppColors.neutral100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: isRestDay
                ? const Icon(
                    Icons.bed_rounded,
                    size: 22,
                    color: AppColors.greenDark,
                  )
                : Transform.rotate(
                    angle: -0.785398,
                    child: const Icon(
                      Icons.fitness_center_rounded,
                      size: 20,
                      color: AppColors.neutral500,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),

        // Judul & Subtitle Otot
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                  color: AppColors.darkCharcoal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                targetMuscles,
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

        // Status Bulat Centang Hijau atau Lingkaran Kosong
        if (isCompleted)
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.darkCharcoal,
              size: 15,
            ),
          )
        else
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.neutral300,
                width: 1.8,
              ),
            ),
          ),
        const SizedBox(width: 6),

        // Chevron Panah Kanan
        const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.neutral400,
          size: 20,
        ),
      ],
    );

    return isRestDay
        ? AppCard.tinted(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: cardContent,
          )
        : AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            onTap: () {
              context.push(
                AppRoutes.workoutDetail,
                extra: WorkoutDetailArgs(
                  dayNumber: programDayNumber,
                  weekDayText: 'Week $selectedWeek • Day $dayNumber',
                  workoutTitle: title,
                  targetMusclesText: targetMuscles,
                  durationText: '45 min',
                  levelText: 'Intermediate',
                  description:
                      'Build strength and muscle mass for your $targetMuscles.',
                ),
              );
            },
            child: cardContent,
          );
  }
}
