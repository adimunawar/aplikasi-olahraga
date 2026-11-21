import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/theme/app_colors.dart';

/// Dekorasi kartu standar yang dipakai seluruh widget Progress.
BoxDecoration progressCardDecoration(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final colorScheme = Theme.of(context).colorScheme;

  return BoxDecoration(
    color: colorScheme.surface,
    borderRadius: BorderRadius.circular(15),
    border: Border.all(
      color: isDark ? colorScheme.outline : AppColors.neutral200,
      width: 0.8,
    ),
    boxShadow: isDark ? null : AppColors.cardShadow,
  );
}
