import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/theme/app_typography.dart';
import 'package:workout_app/i18n/strings.g.dart';

import 'progress_card_decoration.dart';

/// Placeholder untuk metrik tubuh yang belum tersedia di data pengukuran.
class MetricNotTrackedCard extends StatelessWidget {
  const MetricNotTrackedCard({super.key, required this.metric});

  /// Nama metrik yang sudah dilokalkan oleh pemanggil.
  final String metric;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final labels = context.t.core.progress.notTracked;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
      decoration: progressCardDecoration(context),
      child: Column(
        children: [
          Icon(
            Icons.insights_outlined,
            size: 30,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            labels.title(metric: metric),
            style: AppTypography.titleSmall.copyWith(
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            labels.message,
            style: AppTypography.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
