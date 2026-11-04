import 'package:flutter/material.dart';

/// Komponen indikator titik (dots indicator) onboarding reusable:
/// Menampilkan 3 titik terpusat secara konsisten di seluruh langkah.
class OnboardingDotsIndicator extends StatelessWidget {
  final int totalDots;
  final int activeIndex;
  final Color activeColor;
  final Color inactiveColor;

  const OnboardingDotsIndicator({
    super.key,
    this.totalDots = 3,
    required this.activeIndex,
    this.activeColor = const Color(0xFF7CB818),
    this.inactiveColor = const Color(0xFFD1D5DB),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(totalDots, (index) {
          final isActive = index == activeIndex;
          return Container(
            margin: EdgeInsets.only(right: index == totalDots - 1 ? 0 : 8),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}

