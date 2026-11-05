import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Card Progres Berat Badan (Weight) pada Halaman Progress (1:1 sesuai mockup):
/// - Header: Icon timbangan dalam squircle lime lembut, judul "Weight", chevron '>'
/// - Nilai: "58 kg" dengan badge pill "↓ -1.0 kg"
/// - Sparkline chart kurva halus dengan titik nodes dan arsiran gradien di bawah kurva
/// - Label tanggal awal dan akhir dinamis
class WeightProgressCard extends StatelessWidget {
  final double currentWeight;
  final double weightChange;
  final String? startLabel;
  final String? endLabel;
  final VoidCallback? onTap;

  const WeightProgressCard({
    super.key,
    this.currentWeight = 58.0,
    this.weightChange = -1.0,
    this.startLabel,
    this.endLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final changeText = weightChange <= 0
        ? '↓ ${weightChange.toStringAsFixed(1)} kg'
        : '↑ +${weightChange.toStringAsFixed(1)} kg';

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
            // Baris 1: Header Icon + "Weight" + Chevron '>'
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
                    Icons.scale_rounded,
                    size: 17,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Weight',
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

            // Baris 2: Nilai Berat Badan & Badge Pill
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${currentWeight.toStringAsFixed(0)} kg',
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 21,
                    color: AppColors.darkCharcoal,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: AppColors.limeSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    changeText,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.greenDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            // Baris 3: Sparkline Curve
            SizedBox(
              height: 38,
              width: double.infinity,
              child: CustomPaint(
                painter: _WeightSparklinePainter(),
              ),
            ),

            // Baris 4: Tanggal Awal & Akhir
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  startLabel ?? '60 kg\n(Oct 25)',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral400,
                    fontSize: 10,
                    height: 1.15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  endLabel ?? '${currentWeight.toStringAsFixed(0)} kg\n(Nov 5)',
                  textAlign: TextAlign.right,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral400,
                    fontSize: 10,
                    height: 1.15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightSparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      Offset(0, size.height * 0.22),
      Offset(size.width * 0.28, size.height * 0.45),
      Offset(size.width * 0.56, size.height * 0.72),
      Offset(size.width * 0.78, size.height * 0.60),
      Offset(size.width, size.height * 0.66),
    ];

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final ctrlX = (p0.dx + p1.dx) / 2;
      path.cubicTo(ctrlX, p0.dy, ctrlX, p1.dy, p1.dx, p1.dy);
    }

    // Gradient Fill di bawah kurva
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.limeAccent.withOpacity(0.42),
          AppColors.limeAccent.withOpacity(0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Garis stroke kurva
    final strokePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);

    // Node lingkaran titik data
    final nodeFillPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.fill;
    final nodeBorderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final pt in points) {
      canvas.drawCircle(pt, 3.2, nodeFillPaint);
      canvas.drawCircle(pt, 3.2, nodeBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
