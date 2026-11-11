import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../domain/models/workout_program.dart';
import 'program_anatomy_diagram.dart';

/// Kartu "About This Program" (Mockup Referensi 1:1)
class ProgramAboutCard extends StatelessWidget {
  final WorkoutProgram program;

  const ProgramAboutCard({
    super.key,
    required this.program,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          const AppSectionHeader(
            icon: Icons.track_changes_rounded,
            title: 'About This Program',
          ),
          const SizedBox(height: 14),

          // Baris Isi: Deskripsi & Fitur di Kiri, Diagram Anatomi di Kanan
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kolom Teks Deskripsi & Fitur
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'An ${program.totalWeeks}-week structured program designed to help beginners build upper body strength at home, with no gym equipment needed.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral600,
                        height: 1.45,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Badges / Tags Fitur
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _FeaturePill(
                          icon: Icons.home_outlined,
                          label: 'Bodyweight Only',
                        ),
                        _FeaturePill(
                          icon: Icons.trending_up_rounded,
                          label: 'Progressive Plan',
                        ),
                        _FeaturePill(
                          icon: Icons.bolt_rounded,
                          label: 'Beginner Friendly',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              // Diagram Anatomi Target Otot (Dada, Bahu, Lengan)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: AnatomyMuscleDiagram(
                  width: 95,
                  height: 110,
                  highlightChest: true,
                  highlightShoulders: true,
                  highlightArms: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neutral200,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: AppColors.darkCharcoal,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.darkCharcoal,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

