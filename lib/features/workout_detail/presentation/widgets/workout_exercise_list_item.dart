import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_smart_image.dart';
import '../../../../i18n/strings.g.dart';
import '../../../exercises/domain/models/exercise.dart';

/// Compact exercise card used by the Workout Detail screen.
class WorkoutExerciseListItem extends StatelessWidget {
  final String title;
  final String thumbnailAsset;
  final int sets;
  final String reps;
  final Exercise exercise;

  const WorkoutExerciseListItem({
    super.key,
    required this.title,
    required this.thumbnailAsset,
    this.sets = 3,
    this.reps = '8 – 12',
    required this.exercise,
  });

  String _prescriptionLabel(Translations t) {
    final value = reps.trim();
    final lower = value.toLowerCase();
    final alreadyHasUnit =
        lower.contains('rep') ||
        lower.contains('sec') ||
        lower.endsWith('s') ||
        lower.contains('mnt') ||
        lower.contains('detik');
    if (alreadyHasUnit) return value;
    return '$value ${t.workouts.workoutDetail.repsUnit}';
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.colorScheme.surface;
    final borderColor = isDark
        ? theme.colorScheme.outlineVariant.withValues(alpha: 0.3)
        : const Color(0xFFF0F2F0);
    final titleColor = theme.colorScheme.onSurface;
    final subtitleColor = theme.colorScheme.onSurfaceVariant;
    final fallbackBg = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : const Color(0xFFF3F5F2);

    final setLabel = t.workouts.workoutDetail.setReps(
      sets: sets,
      reps: _prescriptionLabel(t),
    );

    if (title.toLowerCase().contains('knee') ||
        title.toLowerCase().contains('push')) {
      debugPrint(
        '[WorkoutExerciseListItem] 📋 Building item "$title" with thumbnailAsset: "$thumbnailAsset"',
      );
    }

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          context.push(AppRoutes.exerciseDetail, extra: exercise);
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
            boxShadow: isDark
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x07000000),
                      blurRadius: 7,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: SizedBox(
                  width: 66,
                  height: 48,
                  child: AppSmartImage(
                    imagePathOrUrl: thumbnailAsset,
                    fit: BoxFit.cover,
                    errorWidget: Container(
                      color: fallbackBg,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.fitness_center_rounded,
                        color: subtitleColor.withValues(alpha: 0.6),
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelLarge.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      setLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelSmall.copyWith(
                        color: subtitleColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: subtitleColor, size: 21),
            ],
          ),
        ),
      ),
    );
  }
}
