import 'package:material_ui/material_ui.dart';

import '../../../../../core/theme/app_typography.dart';
import '../../../../../i18n/strings.g.dart';

/// Komponen pemilih rentang minggu (4, 8, 12 minggu) untuk filter data progres
class ProgressRangeSelector extends StatelessWidget {
  final int selectedWeeks;
  final ValueChanged<int> onWeeksChanged;

  const ProgressRangeSelector({
    super.key,
    required this.selectedWeeks,
    required this.onWeeksChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      initialValue: selectedWeeks,
      onSelected: onWeeksChanged,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 4,
          child: Text(context.t.core.progress.rangeWeeks(weeks: 4)),
        ),
        PopupMenuItem(
          value: 8,
          child: Text(context.t.core.progress.rangeWeeks(weeks: 8)),
        ),
        PopupMenuItem(
          value: 12,
          child: Text(context.t.core.progress.rangeWeeks(weeks: 12)),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 7),
            Text(
              context.t.core.progress.rangeWeeks(weeks: selectedWeeks),
              style: AppTypography.labelSmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 5),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
