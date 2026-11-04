import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';

/// Hero Banner Card: Bulking Program Card dengan Karakter Coach
class HomeHeroBanner extends StatelessWidget {
  final VoidCallback onStartToday;

  const HomeHeroBanner({super.key, required this.onStartToday});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF161E16), // Dark charcoal forest
            Color(0xFF223021),
            Color(0xFF2E402C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24161E16),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background soft lime glow arc
          Positioned(
            right: -20,
            bottom: -30,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFB8E66B).withValues(alpha: 0.18),
              ),
            ),
          ),

          // Left Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
            child: SizedBox(
              width: screenWidth * 0.52,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // "Bulking Program" Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Text(
                          'Bulking Program',
                          style: AppTypography.labelSmall.copyWith(
                            color: const Color(0xFFD3EBB0),
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // "Build Muscle Effectively" Title
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Build Muscle\n',
                              style: AppTypography.headlineMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                                height: 1.15,
                              ),
                            ),
                            TextSpan(
                              text: 'Effectively',
                              style: AppTypography.headlineMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                                fontStyle: FontStyle.italic,
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 3 Checklist items
                      _buildCheckItem('Structured Workout'),
                      const SizedBox(height: 4),
                      _buildCheckItem('Bulking Meal Plan'),
                      const SizedBox(height: 4),
                      _buildCheckItem('Track Your Progress'),
                    ],
                  ),

                  // Button "▶ Start Today"
                  InkWell(
                    onTap: onStartToday,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB8E66B),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33B8E66B),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.play_arrow_rounded,
                            color: Color(0xFF131A11),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Start Today',
                            style: AppTypography.labelLarge.copyWith(
                              color: const Color(0xFF131A11),
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Coach Character (Tinggi menembus atas card seperti mockup)
          Positioned(
            right: -12,
            bottom: 0,
            child: SizedBox(
              height: 375,
              width: 310,
              child: Image.asset(
                'assets/images/coach_character.png',
                fit: BoxFit.contain,
                alignment: Alignment.bottomRight,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/main-caracter.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: Color(0xFFB8E66B),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Color(0xFF131A11),
            size: 11,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTypography.bodySmall.copyWith(
            color: const Color(0xFFE2EBDC),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
