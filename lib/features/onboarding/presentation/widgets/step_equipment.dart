import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class EquipmentOption {
  final String id;
  final String label;
  final IconData icon;

  const EquipmentOption({
    required this.id,
    required this.label,
    required this.icon,
  });
}

/// Step 6 of 7: What equipment do you have? (Mockup 1:1)
class StepEquipment extends StatelessWidget {
  final List<String> selectedEquipments;
  final ValueChanged<String> onToggleEquipment;

  const StepEquipment({
    super.key,
    required this.selectedEquipments,
    required this.onToggleEquipment,
  });

  static const List<EquipmentOption> options = [
    EquipmentOption(
      id: 'bodyweight',
      label: 'Bodyweight\n(no equipment)',
      icon: Icons.accessibility_new_rounded,
    ),
    EquipmentOption(
      id: 'dumbbell',
      label: 'Dumbbell',
      icon: Icons.fitness_center_rounded,
    ),
    EquipmentOption(
      id: 'resistance_band',
      label: 'Resistance\nBand',
      icon: Icons.all_inclusive_rounded,
    ),
    EquipmentOption(
      id: 'kettlebell',
      label: 'Kettlebell',
      icon: Icons.sports_gymnastics_rounded,
    ),
    EquipmentOption(
      id: 'pull_up_bar',
      label: 'Pull-up Bar',
      icon: Icons.horizontal_rule_rounded,
    ),
    EquipmentOption(
      id: 'barbell',
      label: 'Barbell',
      icon: Icons.line_weight_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What equipment do you have?',
            style: AppTypography.displayMedium.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 24,
              color: AppColors.darkCharcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select all that apply.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.neutral500,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),

          // 2-Column Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: options.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              final opt = options[index];
              final isSelected = selectedEquipments.contains(opt.id);

              return InkWell(
                onTap: () => onToggleEquipment(opt.id),
                borderRadius: BorderRadius.circular(18),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF4F9ED)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF84CC16)
                          : AppColors.neutral200,
                      width: isSelected ? 1.8 : 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.limeAccent.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : AppColors.cardShadow,
                  ),
                  child: Stack(
                    children: [
                      // Icon & Label di Tengah
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              opt.icon,
                              size: 32,
                              color: isSelected
                                  ? AppColors.greenDark
                                  : AppColors.neutral600,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              opt.label,
                              textAlign: TextAlign.center,
                              style: AppTypography.labelMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: isSelected
                                    ? AppColors.greenDark
                                    : AppColors.darkCharcoal,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Indikator Centang di Kanan Atas
                      if (isSelected)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Color(0xFF84CC16),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: AppColors.darkCharcoal,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

