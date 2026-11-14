import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

/// Hero Section pada Workout Summary (Mockup 1:1):
/// - Sisi kiri: Foto Coach Adi perayaan/handuk dengan latar belakang blob hijau lime organik
/// - Sisi kanan: Badge checklist hijau dengan kilatan selebrasi,
///   Judul besar bold-italic "Workout Completed!", dan ucapan personal "Great job, Adi!..."
class WorkoutSummaryHeroSection extends StatelessWidget {
  final String userName;
  final String workoutTitle;

  const WorkoutSummaryHeroSection({
    super.key,
    this.userName = 'Adi',
    this.workoutTitle = 'Upper Body Strength',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Sisi Kiri: Foto Coach dengan Blob Hijau
        SizedBox(
          width: 155,
          height: 175,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Blob hijau lime di latar belakang
              Positioned(
                left: 10,
                bottom: 12,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD9F88A),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(70),
                      topRight: Radius.circular(55),
                      bottomLeft: Radius.circular(60),
                      bottomRight: Radius.circular(80),
                    ),
                  ),
                ),
              ),

              // Foto Coach Pose Perayaan / Handuk
              Image.asset(
                'assets/images/coach_towel_shaker.png',
                height: 170,
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
                errorBuilder: (_, _, _) => Image.asset(
                  'assets/images/coach_celebration.png',
                  height: 170,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),

        // Sisi Kanan: Badge, "Workout Completed!", & Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge Checklist Hijau Selebrasi
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xFF65A30D),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x2865A30D),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Percikan selebrasi
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: const Color(0xFF84CC16).withValues(alpha: 0.8),
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Title: Workout Completed! (Bold Italic)
              Text(
                'Workout\nCompleted!',
                style: AppTypography.displayMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  fontSize: 27,
                  color: const Color(0xFF141718),
                  height: 1.08,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle Ucapan
              Text(
                "Great job, $userName! You've finished\n$workoutTitle.",
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 12.5,
                  height: 1.35,
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

