import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class LimitationOption {
  final String id;
  final String label;

  const LimitationOption({
    required this.id,
    required this.label,
  });
}

/// Step 7 of 7: Any limitations or considerations? (Mockup 1:1)
class StepLimitations extends StatelessWidget {
  final List<String> selectedLimitations;
  final ValueChanged<String> onToggleLimitation;

  const StepLimitations({
    super.key,
    required this.selectedLimitations,
    required this.onToggleLimitation,
  });

  static const List<LimitationOption> options = [
    LimitationOption(id: 'none', label: 'No limitations'),
    LimitationOption(id: 'knee', label: 'Knee (e.g. pain, injury)'),
    LimitationOption(id: 'back', label: 'Back (e.g. lower back pain)'),
    LimitationOption(id: 'shoulder', label: 'Shoulder'),
    LimitationOption(id: 'wrist', label: 'Wrist'),
    LimitationOption(id: 'other', label: 'Other'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Any limitations or considerations?',
            style: AppTypography.displayMedium.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 24,
              color: AppColors.darkCharcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Let us know if you have any health conditions or areas to avoid.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.neutral500,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),

          ...options.map((opt) {
            final isSelected = selectedLimitations.contains(opt.id);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => onToggleLimitation(opt.id),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF4F9ED)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
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
                  child: Row(
                    children: [
                      // Radio Circle Indicator
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? const Color(0xFF84CC16)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF84CC16)
                                : AppColors.neutral400,
                            width: 1.5,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: AppColors.darkCharcoal,
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),

                      Text(
                        opt.label,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isSelected
                              ? AppColors.greenDark
                              : AppColors.darkCharcoal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

