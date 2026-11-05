import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

/// Card "Body Information" pada Halaman Profile (Mockup 1:1):
/// - Header: Icon timbangan, judul "Body Information", subtitle, & tombol "Edit"
/// - 3 Kolom Metrik Tubuh:
///   1. Weight: "58.0 kg", badge "↓ -1.0 kg", "from last update"
///   2. Height: "174 cm" dengan icon penggaris/pita ukur
///   3. BMI: "19.2", badge "Healthy", spektrum 4 warna dengan pointer segitiga hitam
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

  Color get _bmiBadgeColor {
    final val = _effectiveBmi;
    if (val < 18.5) return const Color(0xFF2563EB); // Blue
    if (val < 25.0) return const Color(0xFF4D7C0F); // Green
    if (val < 30.0) return const Color(0xFFD97706); // Orange
    return const Color(0xFFDC2626); // Red
  }

  Color get _bmiBadgeBgColor {
    final val = _effectiveBmi;
    if (val < 18.5) return const Color(0xFFDBEAFE);
    if (val < 25.0) return const Color(0xFFEAF8D5);
    if (val < 30.0) return const Color(0xFFFEF3C7);
    return const Color(0xFFFEE2E2);
  }

  double get _bmiPointerFraction {
    final clamped = _effectiveBmi.clamp(15.0, 35.0);
    return (clamped - 15.0) / (35.0 - 15.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF1F3F5), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card: Icon + Judul/Subtitle + Tombol Edit
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF8D5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.monitor_weight_outlined,
                  size: 18,
                  color: Color(0xFF141718),
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
                        color: const Color(0xFF141718),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Your current body data',
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFF6B7280),
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
                    color: const Color(0xFFF3FADC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.edit_outlined,
                        size: 13,
                        color: Color(0xFF141718),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                          color: const Color(0xFF141718),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 3 Kolom Metrik Tubuh (Weight, Height, BMI)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kolom 1: Weight
              Expanded(
                flex: 10,
                child: _buildWeightColumn(),
              ),

              // Garis Pemisah Halus
              _buildVerticalDivider(),

              // Kolom 2: Height
              Expanded(
                flex: 9,
                child: _buildHeightColumn(),
              ),

              // Garis Pemisah Halus
              _buildVerticalDivider(),

              // Kolom 3: BMI
              Expanded(
                flex: 14,
                child: _buildBmiColumn(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(
                Icons.scale_rounded,
                size: 14,
                color: Color(0xFF141718),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Weight',
              style: AppTypography.bodySmall.copyWith(
                color: const Color(0xFF6B7280),
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
            color: const Color(0xFF141718),
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF8D5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '↓ -1.0 kg',
            style: AppTypography.labelSmall.copyWith(
              color: const Color(0xFF4D7C0F),
              fontWeight: FontWeight.w800,
              fontSize: 10.5,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'from last update',
          style: AppTypography.bodySmall.copyWith(
            color: const Color(0xFF94A3B8),
            fontSize: 9.5,
          ),
        ),
      ],
    );
  }

  Widget _buildHeightColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF8D5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.straighten_rounded,
                size: 14,
                color: Color(0xFF141718),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Height',
              style: AppTypography.bodySmall.copyWith(
                color: const Color(0xFF6B7280),
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
            color: const Color(0xFF141718),
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }

  Widget _buildBmiColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF8D5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 14,
                color: Color(0xFF141718),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'BMI',
              style: AppTypography.bodySmall.copyWith(
                color: const Color(0xFF6B7280),
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
                color: const Color(0xFF141718),
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _bmiBadgeBgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _bmiCategory,
                style: AppTypography.labelSmall.copyWith(
                  color: _bmiBadgeColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Spektrum Bar Mini dengan Pointer Segitiga Hitam
        _buildBmiSpectrumMini(),
      ],
    );
  }

  Widget _buildBmiSpectrumMini() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final pointerPos =
            (totalWidth * _bmiPointerFraction).clamp(0.0, totalWidth - 8.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pointer Segitiga Hitam Dinamis
            Padding(
              padding: EdgeInsets.only(left: pointerPos),
              child: CustomPaint(
                size: const Size(8, 5),
                painter: _SmallDownTrianglePainter(),
              ),
            ),
            const SizedBox(height: 1),

            // Spektrum 4 Warna
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

            // Label Rentang
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

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 60,
      color: const Color(0xFFF1F3F5),
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
        color: const Color(0xFF94A3B8),
        fontSize: 8,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.3,
      ),
    );
  }
}

class _SmallDownTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF141718)
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

