import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';

/// Empty state when a workout session has no exercises assigned.
class WorkoutDetailEmptyState extends StatelessWidget {
  const WorkoutDetailEmptyState({super.key});

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isId = t.$meta.locale == AppLocale.id;

    final title = isId
        ? 'Belum ada gerakan latihan'
        : 'No exercises available';
    final subtitle = isId
        ? 'Tidak ada gerakan latihan yang dijadwalkan pada sesi ini.'
        : 'There are no exercises assigned to this workout yet.';

    final cardBg = isDark
        ? theme.colorScheme.surfaceContainer
        : theme.colorScheme.surfaceContainerLowest;
    final borderColor = isDark
        ? theme.colorScheme.outlineVariant.withValues(alpha: 0.3)
        : theme.dividerColor.withValues(alpha: 0.5);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center_rounded,
            size: 30,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}