import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

/// Hero Banner pada Layar Workout Detail (Mockup 1:1):
/// - Background gelap elegan (#162013) dengan pita poligon hijau lime
/// - Info: "Week 3 • Day 1", "Upper Body (A)", durasi & tingkat kesulitan
/// - Foto Coach Adi di sisi kanan
class WorkoutDetailHeroBanner extends StatelessWidget {
  final String weekDayText;
  final String title;
  final String durationText;
  final String levelText;
  final String description;

  const WorkoutDetailHeroBanner({
    super.key,
    this.weekDayText = 'Week 3 • Day 1',
    this.title = 'Upper Body (A)',
    this.durationText = '45 min',
    this.levelText = 'Intermediate',
    this.description = 'Build strength and mass for your chest, back, shoulders, and arms.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF162013),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Pita poligon lime dinamis
            Positioned.fill(
              child: CustomPaint(
                painter: _DetailLimeRibbonsPainter(),
              ),
            ),

            // Foto Coach di kanan
            Positioned(
              right: 0,
              bottom: 0,
              top: 10,
              width: 145,
              child: Image.asset(
                'assets/images/coach_hero.png',
                fit: BoxFit.contain,
                alignment: Alignment.bottomRight,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/coach_character.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                ),
              ),
            ),

            // Teks di kiri
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, bottom: 18, right: 135),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weekDayText,
                        style: AppTypography.bodySmall.copyWith(
                          color: const Color(0xFFD4EBA8),
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: AppTypography.headlineMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: Color(0xFFE2E8F0),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            durationText,
                            style: AppTypography.bodySmall.copyWith(
                              color: const Color(0xFFE2E8F0),
                              fontWeight: FontWeight.w600,
                              fontSize: 11.5,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.signal_cellular_alt_rounded,
                            size: 13,
                            color: Color(0xFFE2E8F0),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            levelText,
                            style: AppTypography.bodySmall.copyWith(
                              color: const Color(0xFFE2E8F0),
                              fontWeight: FontWeight.w600,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF94A3B8),
                      fontSize: 11,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailLimeRibbonsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final limePaint = Paint()
      ..color = const Color(0x66B8E66B)
      ..style = PaintingStyle.fill;

    final limePaintDark = Paint()
      ..color = const Color(0x3384CC16)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final ribbon1 = Path()
      ..moveTo(w * 0.52, 0)
      ..lineTo(w * 0.70, 0)
      ..lineTo(w * 0.88, h)
      ..lineTo(w * 0.68, h)
      ..close();
    canvas.drawPath(ribbon1, limePaintDark);

    final ribbon2 = Path()
      ..moveTo(w * 0.65, 0)
      ..lineTo(w * 0.82, 0)
      ..lineTo(w, h * 0.75)
      ..lineTo(w * 0.80, h)
      ..close();
    canvas.drawPath(ribbon2, limePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

