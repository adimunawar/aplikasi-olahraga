import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../i18n/strings.g.dart';

/// Modal selebrasi saat seluruh latihan hari itu tuntas.
/// Menampilkan ringkasan cepat (durasi, jumlah exercise, total set) sebelum
/// user masuk ke layar ringkasan penuh.
class WorkoutCompleteCelebration extends StatelessWidget {
  final int durationMinutes;
  final int totalSetsDone;
  final int totalExercises;
  final VoidCallback onViewSummary;

  const WorkoutCompleteCelebration({
    super.key,
    required this.durationMinutes,
    required this.totalSetsDone,
    required this.totalExercises,
    required this.onViewSummary,
  });

  static Future<void> show(
    BuildContext context, {
    required int durationMinutes,
    required int totalSetsDone,
    required int totalExercises,
    required VoidCallback onViewSummary,
  }) {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => WorkoutCompleteCelebration(
        durationMinutes: durationMinutes,
        totalSetsDone: totalSetsDone,
        totalExercises: totalExercises,
        onViewSummary: () {
          Navigator.pop(sheetContext);
          onViewSummary();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Trophy / Medali
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFF4F9ED),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.emoji_events_rounded,
                  size: 34,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Judul Selebrasi
            Text(
              t.workoutSession.completionTitle,
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: AppColors.darkCharcoal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Deskripsi apresiasi
            Text(
              t.workoutSession.completionDescription,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.neutral600,
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),

            // Ringkasan Cepat Mini
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MiniStat(
                    icon: Icons.access_time_rounded,
                    label: t.workoutSession.durationLabel,
                    value: t.workoutSession.durationMinutesValue(
                      value: durationMinutes,
                    ),
                  ),
                  Container(width: 1, height: 24, color: AppColors.neutral200),
                  _MiniStat(
                    icon: Icons.fitness_center_rounded,
                    label: t.workoutSession.exerciseLabel,
                    value: t.workoutSession.exerciseCount(
                      count: totalExercises,
                    ),
                  ),
                  Container(width: 1, height: 24, color: AppColors.neutral200),
                  _MiniStat(
                    icon: Icons.check_circle_rounded,
                    label: t.workoutSession.totalSetsLabel,
                    value: t.workoutSession.totalSetsCount(
                      count: totalSetsDone,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Tombol Lihat Ringkasan (AppButton.primary)
            AppButton.primary(
              text: t.workoutSession.viewSummary,
              size: AppButtonSize.large,
              onPressed: onViewSummary,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.greenDark),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.neutral500,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: AppColors.darkCharcoal,
          ),
        ),
      ],
    );
  }
}
