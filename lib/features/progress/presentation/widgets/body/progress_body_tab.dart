import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/theme/app_colors.dart';
import 'package:workout_app/core/theme/app_typography.dart';
import 'package:workout_app/features/progress/application/weight_chart_series.dart';
import 'package:workout_app/i18n/strings.g.dart';

import '../../controllers/progress_state.dart';
import '../shared/progress_shared_widgets.dart';

/// Metrik tubuh yang bisa dipilih pada tab Tubuh.
enum _BodyMetric {
  weight,
  muscleMass,
  bodyFat;

  String label(BuildContext context) => switch (this) {
    _BodyMetric.weight => context.t.core.progress.body.weight,
    _BodyMetric.muscleMass => context.t.core.progress.body.muscleMass,
    _BodyMetric.bodyFat => context.t.core.progress.body.bodyFat,
  };
}

/// Tab Tubuh (Body) pada Halaman Progress
class ProgressBodyTab extends StatefulWidget {
  final ProgressState state;
  final int rangeWeeks;
  final ValueChanged<double?> onLogWeight;

  const ProgressBodyTab({
    super.key,
    required this.state,
    required this.rangeWeeks,
    required this.onLogWeight,
  });

  @override
  State<ProgressBodyTab> createState() => _ProgressBodyTabState();
}

class _ProgressBodyTabState extends State<ProgressBodyTab> {
  _BodyMetric _bodyMetric = _BodyMetric.weight;

  @override
  Widget build(BuildContext context) {
    final chartPoints = WeightChartSeries().build(
      widget.state.weightHistory,
      weeks: widget.rangeWeeks,
      now: DateTime.now(),
    );
    final hasWeightData = chartPoints.isNotEmpty;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProgressSectionHeading(
          title: context.t.core.progress.body.title,
          subtitle: context.t.core.progress.body.subtitle,
        ),
        const SizedBox(height: 10),
        _buildMetricSelector(context),
        const SizedBox(height: 10),
        if (_bodyMetric == _BodyMetric.weight) ...[
          ProgressReveal(
            child: WeightTrendCard(
              points: chartPoints,
              weeks: widget.rangeWeeks,
              currentWeight: widget.state.currentWeight,
              hasData: hasWeightData,
            ),
          ),
          if (hasWeightData) ...[
            const SizedBox(height: 10),
            ProgressReveal(
              child: CurrentWeightSummary(
                currentWeight: widget.state.currentWeight,
                change: widget.state.weightChange,
                rangeWeeks: widget.rangeWeeks,
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: () => widget.onLogWeight(
                hasWeightData ? widget.state.currentWeight : null,
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(context.t.core.progress.body.logMeasurement),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                textStyle: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ] else
          MetricNotTrackedCard(metric: _bodyMetric.label(context)),
      ],
    );
  }

  Widget _buildMetricSelector(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Row(
      children: _BodyMetric.values.map((metric) {
        final selected = _bodyMetric == metric;
        final unselectedBg = isDark
            ? colorScheme.surfaceContainerHighest
            : AppColors.neutral100;
        final unselectedTextColor = isDark
            ? colorScheme.onSurfaceVariant
            : AppColors.neutral600;

        return Padding(
          padding: const EdgeInsets.only(right: 7),
          child: GestureDetector(
            onTap: () => setState(() => _bodyMetric = metric),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: selected ? colorScheme.primary : unselectedBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                metric.label(context),
                style: AppTypography.labelSmall.copyWith(
                  color: selected ? colorScheme.onPrimary : unselectedTextColor,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
