import 'package:flutter/material.dart';

/// Komponen indikator titik (dots indicator) onboarding reusable:
/// Menampilkan pill aktif memanjang dan lingkaran inaktif sesuai mockup 1:1.
class OnboardingDotsIndicator extends StatelessWidget {
  final int totalDots;
  final int activeIndex;
  final Color activeColor;
  final Color inactiveColor;

  const OnboardingDotsIndicator({
    super.key,
    this.totalDots = 3,
    required this.activeIndex,
    this.activeColor = const Color(0xFF84CC16),
    this.inactiveColor = const Color(0xFFE2E8F0),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalDots, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.only(right: index == totalDots - 1 ? 0 : 6),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

