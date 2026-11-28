import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';

/// Step 3 of 8: Your height (Interactive ruler + character height stage).
class StepHeight extends StatelessWidget {
  final double heightCm;
  final ValueChanged<double> onHeightChanged;

  const StepHeight({
    super.key,
    required this.heightCm,
    required this.onHeightChanged,
  });

  static const double _minHeightCm = 100.0;
  static const double _maxHeightCm = 230.0;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context).onboarding.bodyTarget;
    final tAbout = Translations.of(context).onboarding.about;
    final colorScheme = Theme.of(context).colorScheme;
    final heightRatio =
        ((heightCm - _minHeightCm) / (_maxHeightCm - _minHeightCm)).clamp(
          0.0,
          1.0,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tAbout.height,
            style: AppTypography.displayMedium.copyWith(
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              fontSize: 26,
              height: 1.15,
              letterSpacing: -0.5,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _CharacterHeightStage(
              heightCm: heightCm,
              unit: tAbout.heightUnit,
              heightRatio: heightRatio,
            ),
          ),
          const SizedBox(height: 16),
          _HeightRulerCard(
            label: tAbout.height,
            unit: tAbout.heightUnit,
            heightCm: heightCm,
            minHeightCm: _minHeightCm,
            maxHeightCm: _maxHeightCm,
            onChanged: onHeightChanged,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _CharacterHeightStage extends StatelessWidget {
  final double heightCm;
  final String unit;
  final double heightRatio;

  const _CharacterHeightStage({
    required this.heightCm,
    required this.unit,
    required this.heightRatio,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.primary;
    final clampedRatio = heightRatio.clamp(0.0, 1.0);
    final charHeightFactor = 0.45 + (clampedRatio * 0.47);
    final alignY = (1.0 - (2.0 * charHeightFactor)).clamp(-1.0, 1.0);

    return Center(
      child: SizedBox(
        width: 240,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 20,
              right: 10,
              bottom: 0,
              height: 36,
              child: CustomPaint(painter: _FloorGlowRingPainter(color: accent)),
            ),
            Positioned(
              left: 0,
              top: 12,
              bottom: 18,
              width: 60,
              child: CustomPaint(
                painter: _VerticalHeightRulerPainter(
                  color: accent,
                  heightFactor: charHeightFactor,
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 0,
              top: 12,
              bottom: 18,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutCubic,
                  heightFactor: charHeightFactor,
                  widthFactor: 1.0,
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    'assets/images/about-you-men.webp',
                    fit: BoxFit.fitHeight,
                    alignment: Alignment.bottomCenter,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.accessibility_new_rounded,
                      size: 72,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 0,
              top: 0,
              bottom: 18,
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOutCubic,
                alignment: Alignment(-0.85, alignY),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    '${heightCm.round()} $unit',
                    style: AppTypography.labelSmall.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeightRulerCard extends StatefulWidget {
  final String label;
  final String unit;
  final double heightCm;
  final double minHeightCm;
  final double maxHeightCm;
  final ValueChanged<double> onChanged;

  const _HeightRulerCard({
    required this.label,
    required this.unit,
    required this.heightCm,
    required this.minHeightCm,
    required this.maxHeightCm,
    required this.onChanged,
  });

  @override
  State<_HeightRulerCard> createState() => _HeightRulerCardState();
}

class _HeightRulerCardState extends State<_HeightRulerCard> {
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
                painter: _HorizontalRulerPainter(
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

class _VerticalHeightRulerPainter extends CustomPainter {
  final Color color;
  final double heightFactor;

  const _VerticalHeightRulerPainter({
    required this.color,
    required this.heightFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final tickPaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..strokeWidth = 1.2;

    canvas.drawLine(const Offset(4, 0), Offset(4, size.height), linePaint);

    const totalTicks = 28;
    for (var i = 0; i <= totalTicks; i++) {
      final y = (size.height / totalTicks) * i;
      final isMajor = i % 5 == 0;
      final tickLen = isMajor ? 10.0 : 5.0;
      canvas.drawLine(Offset(4, y), Offset(4 + tickLen, y), tickPaint);
    }

    final clampedY = (size.height * (1.0 - heightFactor)).clamp(
      0.0,
      size.height,
    );
    final guidePaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(4, clampedY),
      Offset(size.width, clampedY),
      guidePaint,
    );
    canvas.drawCircle(Offset(4, clampedY), 4.0, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _VerticalHeightRulerPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.heightFactor != heightFactor;
  }
}

class _FloorGlowRingPainter extends CustomPainter {
  final Color color;

  const _FloorGlowRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.88,
      height: size.height * 0.56,
    );

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    canvas.drawOval(rect, glowPaint);
    canvas.drawOval(rect, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _FloorGlowRingPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _HorizontalRulerPainter extends CustomPainter {
  final double currentValue;
  final Color accentColor;
  final Color tickColor;
  final TextStyle labelStyle;

  const _HorizontalRulerPainter({
    required this.currentValue,
    required this.accentColor,
    required this.tickColor,
    required this.labelStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    const pixelsPerUnit = 8.0;
    final visibleHalfRange = (size.width / 2 / pixelsPerUnit).ceil() + 2;
    final startTick = currentValue.round() - visibleHalfRange;
    final endTick = currentValue.round() + visibleHalfRange;

    final tickPaint = Paint()..strokeWidth = 1.4;

    for (var value = startTick; value <= endTick; value++) {
      final dx = centerX + (value - currentValue) * pixelsPerUnit;
      if (dx < 0 || dx > size.width) continue;

      final isMajor = value % 5 == 0;
      final tickHeight = isMajor ? 18.0 : 10.0;
      final topY = isMajor ? 4.0 : 8.0;
      tickPaint.color = isMajor ? tickColor.withValues(alpha: 0.9) : tickColor;

      canvas.drawLine(
        Offset(dx, topY),
        Offset(dx, topY + tickHeight),
        tickPaint,
      );

      if (isMajor) {
        final painter = TextPainter(
          text: TextSpan(text: '$value', style: labelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        painter.paint(canvas, Offset(dx - painter.width / 2, 26));
      }
    }

    final indicatorPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(centerX, 6), Offset(centerX, 24), indicatorPaint);
    canvas.drawCircle(
      Offset(centerX, 6),
      4.5,
      Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
  }

  @override
  bool shouldRepaint(covariant _HorizontalRulerPainter oldDelegate) {
    return oldDelegate.currentValue != currentValue ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.tickColor != tickColor;
  }
}
