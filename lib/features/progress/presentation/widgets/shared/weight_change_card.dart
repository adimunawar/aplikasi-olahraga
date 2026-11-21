import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/theme/app_colors.dart';
import 'package:workout_app/core/theme/app_typography.dart';
import 'package:workout_app/i18n/strings.g.dart';

import 'progress_card_decoration.dart';

/// Baris aksi untuk mencatat perubahan berat badan.
class WeightChangeCard extends StatelessWidget {
  const WeightChangeCard({
    super.key,
    required this.change,
    required this.onTap,
  });

  final double change;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: progressCardDecoration(context),
          child: Row(
            children: [
              Icon(
                Icons.monitor_weight_outlined,
                color: isDark ? colorScheme.primary : AppColors.greenDark,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.t.core.progress.body.recordWeight,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)} kg',
                style: AppTypography.titleSmall.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
