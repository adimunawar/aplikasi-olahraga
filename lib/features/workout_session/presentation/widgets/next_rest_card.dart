import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';

/// Kartu "Rest berikutnya" di bawah rep counter Active Workout.
class NextRestCard extends StatelessWidget {
  final int restSeconds;

  const NextRestCard({super.key, required this.restSeconds});

  @override
  Widget build(BuildContext context) {
    final minutes = (restSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (restSeconds % 60).toString().padLeft(2, '0');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.access_time_rounded,
            size: 18,
            color: AppColors.neutral600,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              Translations.of(context).workoutSession.nextRest,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.darkCharcoal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '$minutes:$seconds',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.darkCharcoal,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
