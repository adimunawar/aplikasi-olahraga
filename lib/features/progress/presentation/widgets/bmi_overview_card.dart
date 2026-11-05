import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Card Ringkasan BMI pada Halaman Progress (1:1 sesuai mockup):
/// - Header: Icon squircle lime dengan lambang hati, judul "BMI", chevron '>'
/// - Nilai: "19.2" dengan status badge "Healthy"
/// - Pointer segitiga hitam menunjuk tepat ke nilai BMI
/// - Spektrum 4 warna dalam satu kapsul rounded
class BmiOverviewCard extends StatelessWidget {
  final double bmiValue;
  final String statusText;
  final VoidCallback? onTap;

  const BmiOverviewCard({
    super.key,
    this.bmiValue = 19.2,
    this.statusText = 'Healthy',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 168,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder, width: 1.2),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Baris 1: Header Icon + "BMI" + Chevron '>'
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.limeSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.favorite_border_rounded,
                    size: 17,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'BMI',
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.neutral400,
                ),
              ],
            ),

            // Baris 2: Nilai BMI & Badge Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  bmiValue.toStringAsFixed(1),
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 21,
                    color: AppColors.darkCharcoal,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: AppColors.limeSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.greenDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            // Baris 3: Segitiga Pointer + Spektrum Bar + Label
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPointerIndicator(),
                const SizedBox(height: 2),

                // Kapsul 4 Warna Spektrum
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 7,
                    child: Row(
                      children: [
                        // < 18.5 (Biru)
                        Expanded(
                          flex: 22,
                          child: Container(color: AppColors.secondary),
                        ),
                        const SizedBox(width: 2),
                        // 18.5 - 24.9 (Toska/Hijau)
                        Expanded(
                          flex: 30,
                          child: Container(color: AppColors.primary),
                        ),
                        const SizedBox(width: 2),
                        // 25 - 29.9 (Kuning/Oranye)
                        Expanded(
                          flex: 26,
                          child: Container(color: AppColors.amberWarning),
                        ),
                        const SizedBox(width: 2),
                        // >= 30 (Merah coral)
                        Expanded(
                          flex: 22,
                          child: Container(color: AppColors.vibrantCoral),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Label Rentang
                Row(
                  children: [
                    Expanded(
                      flex: 22,
                      child: Text(
                        '< 18.5',
                        style: _rangeStyle,
                        maxLines: 1,
                      ),
                    ),
                    Expanded(
                      flex: 30,
                      child: Text(
                        '18.5 - 24.9',
                        textAlign: TextAlign.center,
                        style: _rangeStyle,
                        maxLines: 1,
                      ),
                    ),
                    Expanded(
                      flex: 26,
                      child: Text(
                        '25 - 29.9',
                        textAlign: TextAlign.center,
                        style: _rangeStyle,
                        maxLines: 1,
                      ),
                    ),
                    Expanded(
                      flex: 22,
                      child: Text(
                        '≥ 30',
                        textAlign: TextAlign.right,
                        style: _rangeStyle,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TextStyle get _rangeStyle => AppTypography.bodySmall.copyWith(
        color: AppColors.neutral400,
        fontSize: 9.5,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.2,
      );

  Widget _buildPointerIndicator() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const minBmi = 15.0;
        const maxBmi = 35.0;
        final ratio = ((bmiValue - minBmi) / (maxBmi - minBmi)).clamp(0.05, 0.95);
        final arrowX = (ratio * (totalWidth - 10)).clamp(4.0, totalWidth - 12.0);

        return Stack(
          children: [
            SizedBox(height: 8, width: totalWidth),
            Positioned(
              left: arrowX,
              top: 0,
              child: CustomPaint(
                size: const Size(9, 6),
                painter: _DownTrianglePainter(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DownTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.darkCharcoal
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
