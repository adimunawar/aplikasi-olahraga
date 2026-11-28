import 'package:material_ui/material_ui.dart';

Path buildSlantedGoalCardPath(Size size) {
  const skewY = 14.0;
  const xInset = 10.0;
  const radius = 22.0;

  final topLeft = Offset(xInset, skewY);
  final topRight = Offset(size.width, 0);
  final bottomRight = Offset(size.width - xInset, size.height - skewY);
  final bottomLeft = Offset(0, size.height);

  return Path()
    ..moveTo(topLeft.dx + radius, topLeft.dy - 1)
    ..lineTo(topRight.dx - radius, topRight.dy + 1)
    ..quadraticBezierTo(
      topRight.dx,
      topRight.dy,
      topRight.dx - 2,
      topRight.dy + radius,
    )
    ..lineTo(bottomRight.dx + 2, bottomRight.dy - radius)
    ..quadraticBezierTo(
      bottomRight.dx,
      bottomRight.dy,
      bottomRight.dx - radius,
      bottomRight.dy + 1,
    )
    ..lineTo(bottomLeft.dx + radius, bottomLeft.dy - 1)
    ..quadraticBezierTo(
      bottomLeft.dx,
      bottomLeft.dy,
      bottomLeft.dx + 2,
      bottomLeft.dy - radius,
    )
    ..lineTo(topLeft.dx - 2, topLeft.dy + radius)
    ..quadraticBezierTo(
      topLeft.dx,
      topLeft.dy,
      topLeft.dx + radius,
      topLeft.dy - 1,
    )
    ..close();
}

class SlantedGoalCardClipper extends CustomClipper<Path> {
  const SlantedGoalCardClipper();

  @override
  Path getClip(Size size) => buildSlantedGoalCardPath(size);

  @override
  bool shouldReclip(covariant SlantedGoalCardClipper oldClipper) => false;
}

class SlantedGoalBottomClipper extends CustomClipper<Path> {
  const SlantedGoalBottomClipper();

  @override
  Path getClip(Size size) {
    const skewY = 14.0;
    const xInset = 10.0;
    const radius = 22.0;
    final bottomRight = Offset(size.width - xInset, size.height - skewY);
    final bottomLeft = Offset(0, size.height);

    return Path()
      ..moveTo(-40, -80)
      ..lineTo(size.width + 40, -80)
      ..lineTo(size.width + 40, bottomRight.dy - radius)
      ..lineTo(bottomRight.dx + 2, bottomRight.dy - radius)
      ..quadraticBezierTo(
        bottomRight.dx,
        bottomRight.dy,
        bottomRight.dx - radius,
        bottomRight.dy + 1,
      )
      ..lineTo(bottomLeft.dx + radius, bottomLeft.dy - 1)
      ..quadraticBezierTo(
        bottomLeft.dx,
        bottomLeft.dy,
        bottomLeft.dx + 2,
        bottomLeft.dy - radius,
      )
      ..lineTo(-40, bottomLeft.dy - radius)
      ..close();
  }

  @override
  bool shouldReclip(covariant SlantedGoalBottomClipper oldClipper) => false;
}

class SlantedGoalCardPainter extends CustomPainter {
  final List<Color> gradientColors;
  final Color borderColor;
  final double borderWidth;

  const SlantedGoalCardPainter({
    required this.gradientColors,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = buildSlantedGoalCardPath(size);

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
      ).createShader(Offset.zero & size);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant SlantedGoalCardPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.gradientColors.first != gradientColors.first ||
        oldDelegate.gradientColors.last != gradientColors.last;
  }
}
