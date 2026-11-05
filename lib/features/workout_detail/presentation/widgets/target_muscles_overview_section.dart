import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../plans/presentation/widgets/mini_anatomy_icon.dart';

/// Bagian Target Muscles (4 kartu anatomi) dan Overview (ringkasan sesi) side-by-side
class TargetMusclesOverviewSection extends StatelessWidget {
  final List<String> targetMuscles;
  final int totalExercises;
  final String setsText;
  final String repsText;
  final String restText;

  const TargetMusclesOverviewSection({
    super.key,
    this.targetMuscles = const ['Chest', 'Back', 'Shoulder', 'Arms'],
    this.totalExercises = 5,
    this.setsText = '3 Sets (each)',
    this.repsText = '8 – 12 Reps',
    this.restText = 'Rest 60 – 90 sec',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kolom Kiri: Target Muscles (Judul + 4 Kotak Anatomi)
        Expanded(
          flex: 11,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Target Muscles',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: const Color(0xFF141718),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: targetMuscles.map((muscle) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x06000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MiniAnatomyIcon(muscleGroup: muscle),
                          const SizedBox(height: 6),
                          Text(
                            muscle,
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF334155),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Kolom Kanan: Overview Card
        Expanded(
          flex: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F9EA),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2EED0), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Overview
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9F4A4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                        color: Color(0xFF365314),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Overview',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: const Color(0xFF141718),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 4 Item Info
                _buildOverviewRow(Icons.layers_rounded, '$totalExercises Exercises'),
                const SizedBox(height: 5),
                _buildOverviewRow(Icons.autorenew_rounded, setsText),
                const SizedBox(height: 5),
                _buildOverviewRow(Icons.cached_rounded, repsText),
                const SizedBox(height: 5),
                _buildOverviewRow(Icons.access_time_rounded, restText),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: const Color(0xFF475569)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTypography.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

