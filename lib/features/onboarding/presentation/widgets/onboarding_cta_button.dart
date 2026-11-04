import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Komponen tombol CTA utama onboarding reusable:
/// Digunakan seragam di seluruh 5 langkah onboarding:
/// - "Get Started →" (Welcome)
/// - "Next →" (Goal, Level, Schedule)
/// - "Start My Plan →" (Plan Ready)
class OnboardingCtaButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool showArrow;
  final Color backgroundColor;
  final Color textColor;

  const OnboardingCtaButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.showArrow = true,
    this.backgroundColor = const Color(0xFF88D618),
    this.textColor = const Color(0xFF141718),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: GoogleFonts.inter(
                color: textColor,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            if (showArrow) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                size: 20,
                color: textColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

