import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

/// Header Halaman Profile (Mockup 1:1):
/// - Judul besar: "Profile"
/// - Subtitle: "Manage your account, body data, and preferences."
/// - Ambient glow lime lembut di pojok kanan atas
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Ambient soft lime glow di pojok kanan atas
        Positioned(
          top: -25,
          right: -25,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFC7F135).withValues(alpha: 0.35),
                  const Color(0xFFC7F135).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),

        // Konten Teks Header
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: AppTypography.headlineLarge.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  color: const Color(0xFF141718),
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your account, body data, and preferences.',
                style: AppTypography.bodyMedium.copyWith(
                  color: const Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

