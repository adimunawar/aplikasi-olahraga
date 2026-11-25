import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_widgets.dart';

/// Card "Body Information" pada Halaman Profile (Light & Dark Mode).
class BodyInformationCard extends StatelessWidget {
  final double weight;
  final double height;
  final double bmi;
  final VoidCallback? onEdit;

  const BodyInformationCard({
    super.key,
    this.weight = 58.0,
    this.height = 174.0,
    this.bmi = 19.2,
    this.onEdit,
  });

  double get _effectiveBmi {
    if (bmi > 0) return bmi;
    if (height > 0 && weight > 0) {
      final hM = height / 100.0;
      return double.parse((weight / (hM * hM)).toStringAsFixed(1));
    }
    return 19.2;
  }

  String get _bmiCategory {
    final val = _effectiveBmi;
    if (val < 18.5) return 'Underweight';
    if (val < 25.0) return 'Healthy';
    if (val < 30.0) return 'Overweight';
    return 'Obese';
  }

  Color _bmiBadgeColor(bool isDark) {
    final val = _effectiveBmi;
    if (val < 18.5) {
      return isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB);
    }
    if (val < 25.0) {
      return isDark ? AppColors.limeAccent : AppColors.greenDark;
    }
    if (val < 30.0) {
      return isDark ? const Color(0xFFFCD34D) : const Color(0xFFD97706);
    }
    return isDark ? const Color(0xFFFCA5A5) : AppColors.error;
  }

  Color _bmiBadgeBgColor(bool isDark) {
    final val = _effectiveBmi;
    if (val < 18.5) {
      return isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE);
    }
    if (val < 25.0) {
      return isDark ? const Color(0xFF28390A) : AppColors.limeSurface;
    }
    if (val < 30.0) {
      return isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
    }
    return isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
  }

  double get _bmiPointerFraction {
    final clamped = _effectiveBmi.clamp(15.0, 35.0);
    return (clamped - 15.0) / (35.0 - 15.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final iconBg = isDark ? colorScheme.primaryContainer : AppColors.limeSurface;
    final iconFg = isDark ? colorScheme.primary : colorScheme.onSurface;
    final editBg = isDark ? colorScheme.primaryContainer : AppColors.limeCardSurface;
    final editFg = isDark ? colorScheme.onPrimaryContainer : colorScheme.onSurface;

    return AppCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.monitor_weight_outlined,
                  size: 18,
                  color: iconFg,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Body Information',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Your current body data',
                      style: AppTypography.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: editBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 13,
                        color: editFg,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                          color: editFg,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 10,
                child: _buildWeightColumn(context, isDark, colorScheme, iconBg),
              ),
              _buildVerticalDivider(colorScheme),
              Expanded(
                flex: 9,
                child: _buildHeightColumn(colorScheme, iconBg, iconFg),
              ),
              _buildVerticalDivider(colorScheme),
              Expanded(
                flex: 14,
                child: _buildBmiColumn(isDark, colorScheme, iconBg, iconFg),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightColumn(
    BuildContext context,
    bool isDark,
    ColorScheme colorScheme,
    Color iconBg,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: colorScheme.outline),
              ),
              child: Icon(
                Icons.scale_rounded,
                size: 14,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Weight',
              style: AppTypography.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${weight.toStringAsFixed(1)} kg',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 17,
            color: colorScheme.onSurface,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '↓ -1.0 kg',
            style: AppTypography.labelSmall.copyWith(
              color: isDark ? AppColors.limeAccent : AppColors.greenDark,
              fontWeight: FontWeight.w800,
              fontSize: 10.5,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'from last update',
          style: AppTypography.bodySmall.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 9.5,
          ),
        ),
      ],
    );
  }

  Widget _buildHeightColumn(
    ColorScheme colorScheme,
    Color iconBg,
    Color iconFg,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.straighten_rounded,
                size: 14,
                color: iconFg,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Height',
              style: AppTypography.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${height.toStringAsFixed(0)} cm',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 17,
            color: colorScheme.onSurface,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }

  Widget _buildBmiColumn(
    bool isDark,
    ColorScheme colorScheme,
    Color iconBg,
    Color iconFg,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 14,
                color: iconFg,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'BMI',
              style: AppTypography.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _effectiveBmi.toStringAsFixed(1),
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 17,
                color: colorScheme.onSurface,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _bmiBadgeBgColor(isDark),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _bmiCategory,
                style: AppTypography.labelSmall.copyWith(
                  color: _bmiBadgeColor(isDark),
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildBmiSpectrumMini(colorScheme),
      ],
    );
  }

  Widget _buildBmiSpectrumMini(ColorScheme colorScheme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final pointerPos =
            (totalWidth * _bmiPointerFraction).clamp(0.0, totalWidth - 8.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: pointerPos),
              child: CustomPaint(
                size: const Size(8, 5),
                painter: _SmallDownTrianglePainter(color: colorScheme.onSurface),
              ),
            ),
            const SizedBox(height: 1),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 5,
                child: Row(
                  children: [
                    Expanded(
                      flex: 22,
                      child: Container(color: const Color(0xFF60A5FA)),
                    ),
                    const SizedBox(width: 1.5),
                    Expanded(
                      flex: 30,
                      child: Container(color: const Color(0xFF34D399)),
                    ),
                    const SizedBox(width: 1.5),
                    Expanded(
                      flex: 26,
                      child: Container(color: const Color(0xFFFBBF24)),
                    ),
                    const SizedBox(width: 1.5),
                    Expanded(
                      flex: 22,
                      child: Container(color: const Color(0xFFF87171)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _SpectrumLabel('< 18.5'),
                _SpectrumLabel('18.5 - 24.9'),
                _SpectrumLabel('25 - 29.9'),
                _SpectrumLabel('≥ 30'),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildVerticalDivider(ColorScheme colorScheme) {
    return Container(
      width: 1,
      height: 60,
      color: colorScheme.outlineVariant,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _SpectrumLabel extends StatelessWidget {
  final String text;
  const _SpectrumLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.bodySmall.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 8,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.3,
      ),
    );
  }
}

class _SmallDownTrianglePainter extends CustomPainter {
  final Color color;

  const _SmallDownTrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SmallDownTrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}
