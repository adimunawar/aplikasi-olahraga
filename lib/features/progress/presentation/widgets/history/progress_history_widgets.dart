import 'package:material_ui/material_ui.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../application/progress_history_grouping.dart';
import '../../../domain/models/weight_record.dart';
import '../../../domain/models/workout_history_item.dart';

class HistoryEntry {
  const HistoryEntry._({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.isMeasurement,
  });

  factory HistoryEntry.workout(WorkoutHistoryItem item) {
    final date = const ProgressHistoryGrouping().parseWorkoutDate(
      item.dateText,
      now: DateTime.now(),
    );
    return HistoryEntry._(
      date: date,
      title: item.title,
      subtitle: 'Workout · ${item.durationText}',
      isMeasurement: false,
    );
  }

  factory HistoryEntry.measurement(WeightRecord item) => HistoryEntry._(
    date: item.recordedAt,
    title: 'Body Measurement',
    subtitle: '${item.weightKg.toStringAsFixed(1)} kg',
    isMeasurement: true,
  );

  final DateTime date;
  final String title;
  final String subtitle;
  final bool isMeasurement;
}

class HistoryFilterChip extends StatelessWidget {
  const HistoryFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.limeAccent : AppColors.neutral100,
    borderRadius: BorderRadius.circular(22),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: AppColors.darkCharcoal),
            const SizedBox(width: 4),
          ],
          Text(label, style: AppTypography.labelSmall.copyWith(
            color: AppColors.darkCharcoal,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          )),
        ]),
      ),
    ),
  );
}

class HistoryGroupCard extends StatelessWidget {
  const HistoryGroupCard({super.key, required this.entries});
  final List<HistoryEntry> entries;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: AppColors.neutral200),
      boxShadow: AppColors.cardShadow,
    ),
    child: Column(children: List.generate(entries.length, (index) {
      final entry = entries[index];
      return Column(children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: entry.isMeasurement ? AppColors.neutral100 : AppColors.limeSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              entry.isMeasurement ? Icons.monitor_weight_outlined : Icons.fitness_center_rounded,
              size: 17,
              color: entry.isMeasurement ? AppColors.neutral700 : AppColors.greenDark,
            ),
          ),
          title: Text(entry.title, style: AppTypography.titleSmall.copyWith(fontSize: 12)),
          subtitle: Text(entry.subtitle, style: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.neutral500)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(_historyDateLabel(entry.date), style: AppTypography.labelSmall.copyWith(color: AppColors.neutral500)),
            const SizedBox(width: 5),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.neutral400),
          ]),
        ),
        if (index != entries.length - 1)
          const Divider(height: 1, color: AppColors.neutral200),
      ]);
    })),
  );
}

class HistoryEmptyState extends StatelessWidget {
  const HistoryEmptyState({super.key, required this.filter});
  final String filter;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: AppColors.neutral200),
    ),
    child: Column(children: [
      const Icon(Icons.history_rounded, size: 30, color: AppColors.neutral400),
      const SizedBox(height: 8),
      Text('No ${filter == 'All' ? 'history' : filter.toLowerCase()} yet',
        style: AppTypography.titleSmall),
      const SizedBox(height: 4),
      Text('Your activity will appear here when it is recorded.',
        textAlign: TextAlign.center,
        style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500)),
    ]),
  );
}

String _historyDateLabel(DateTime date) {
  final now = DateTime.now();
  final day = DateTime(date.year, date.month, date.day);
  final today = DateTime(now.year, now.month, now.day);
  final difference = today.difference(day).inDays;
  if (difference == 0) return 'Today';
  if (difference == 1) return 'Yesterday';
  return '${date.day}/${date.month}';
}
