import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';

/// Step 6 of 7: What equipment do you have? (Mockup 1:1)
class StepEquipment extends StatelessWidget {
  final List<String> selectedEquipments;
  final ValueChanged<String> onToggleEquipment;

  const StepEquipment({
    super.key,
    required this.selectedEquipments,
    required this.onToggleEquipment,
  });

  static const Map<String, IconData> _icons = {
    'bodyweight': Icons.accessibility_new_rounded,
    'dumbbell': Icons.fitness_center_rounded,
    'resistance_band': Icons.all_inclusive_rounded,
    'kettlebell': Icons.sports_gymnastics_rounded,
    'pull_up_bar': Icons.horizontal_rule_rounded,
    'barbell': Icons.line_weight_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context).onboarding.equipment;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.title,
            style: AppTypography.displayMedium.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 24,
              color: AppColors.darkCharcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t.subtitle,
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
            itemCount: t.options.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              final opt = t.options[index];
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
                              _icons[opt.id] ??
                                  Icons.fitness_center_rounded,
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

