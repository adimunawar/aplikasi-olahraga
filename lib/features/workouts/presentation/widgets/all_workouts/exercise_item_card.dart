import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/theme/app_typography.dart';
import 'package:workout_app/features/exercises/domain/models/exercise.dart';

/// Kartu untuk menampilkan item latihan pada tab "Semua Latihan".
class ExerciseItemCard extends StatelessWidget {
  final Exercise exercise;
  final String langCode;
  final VoidCallback onTap;

  const ExerciseItemCard({
    super.key,
    required this.exercise,
    required this.langCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final localizedName = exercise.name.get(langCode);
    final name = localizedName.trim().isNotEmpty
        ? localizedName
        : exercise.name.id;

    final primaryMuscle = exercise.primaryMuscles.isNotEmpty
        ? exercise.primaryMuscles.first.get(langCode)
        : exercise.category.localizedName(langCode);
    final difficulty = exercise.difficulty.localizedName(langCode);

    final thumb = exercise.media.startPose.isNotEmpty
        ? exercise.media.startPose
        : exercise.media.endPose;

    final cardBgColor = isDark ? theme.colorScheme.surface : Colors.white;
    final borderColor = isDark ? theme.colorScheme.outline : const Color(0xFFE5E7EB);
    final titleColor = theme.colorScheme.onSurface;
    final subtextColor = theme.colorScheme.onSurfaceVariant;
    final iconBgColor = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : const Color(0xFFF3F4F6);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: thumb.isNotEmpty
                    ? Image.asset(
                        thumb,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.fitness_center_rounded,
                          color: Color(0xFF65A30D),
                          size: 26,
                        ),
                      )
                    : const Icon(
                        Icons.fitness_center_rounded,
                        color: Color(0xFF65A30D),
                        size: 26,
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$primaryMuscle • $difficulty',
                    style: TextStyle(
                      color: subtextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: subtextColor,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
