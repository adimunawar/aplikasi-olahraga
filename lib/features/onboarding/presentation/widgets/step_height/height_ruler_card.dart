import 'package:material_ui/material_ui.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import 'horizontal_ruler_painter.dart';

class HeightRulerCard extends StatefulWidget {
  final String label;
  final String unit;
  final double heightCm;
  final double minHeightCm;
  final double maxHeightCm;
  final ValueChanged<double> onChanged;

  const HeightRulerCard({
    super.key,
    required this.label,
    required this.unit,
    required this.heightCm,
    required this.minHeightCm,
    required this.maxHeightCm,
    required this.onChanged,
  });

  @override
  State<HeightRulerCard> createState() => _HeightRulerCardState();
}

class _HeightRulerCardState extends State<HeightRulerCard> {
  double _dragAccumulator = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHigh : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary, width: 1.5),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.14),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.height_rounded,
                size: 18,
                color: isDark ? colorScheme.primary : AppColors.greenBrand,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Center(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${widget.heightCm.round()} ',
                    style: AppTypography.displayMedium.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: widget.unit,
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (_) => _dragAccumulator = 0,
            onHorizontalDragUpdate: (details) {
              _dragAccumulator += details.delta.dx;
              const pixelsPerCm = 8.0;
              if (_dragAccumulator.abs() >= pixelsPerCm) {
                final stepDelta = (_dragAccumulator / pixelsPerCm).truncate();
                _dragAccumulator -= stepDelta * pixelsPerCm;
                final next = (widget.heightCm - stepDelta).clamp(
                  widget.minHeightCm,
                  widget.maxHeightCm,
                );
                if (next != widget.heightCm) {
                  widget.onChanged(next.roundToDouble());
                }
              }
            },
            child: SizedBox(
              height: 46,
              width: double.infinity,
              child: CustomPaint(
                painter: HorizontalRulerPainter(
                  currentValue: widget.heightCm,
                  accentColor: colorScheme.primary,
                  tickColor: colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.45,
                  ),
                  labelStyle: AppTypography.labelSmall.copyWith(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
