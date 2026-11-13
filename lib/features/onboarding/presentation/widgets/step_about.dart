import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';

/// Step 2 of 7: Tell us about you (Gender, Age, Height) (Mockup 1:1)
class StepAbout extends StatelessWidget {
  final String gender;
  final int age;
  final double heightCm;
  final ValueChanged<String> onGenderChanged;
  final ValueChanged<int> onAgeChanged;
  final ValueChanged<double> onHeightChanged;

  const StepAbout({
    super.key,
    required this.gender,
    required this.age,
    required this.heightCm,
    required this.onGenderChanged,
    required this.onAgeChanged,
    required this.onHeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context).onboarding.about;

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

          // 1. Gender Selector
          Text(
            t.gender,
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.darkCharcoal,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildGenderOption(
                  id: 'male',
                  label: t.male,
                  icon: Icons.male_rounded,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildGenderOption(
                  id: 'female',
                  label: t.female,
                  icon: Icons.female_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Age Stepper
          _buildStepperCard(
            label: t.age,
            valueText: '$age',
            unit: t.ageUnit,
            onMinus: () {
              if (age > 14) onAgeChanged(age - 1);
            },
            onPlus: () {
              if (age < 80) onAgeChanged(age + 1);
            },
          ),
          const SizedBox(height: 18),

          // 3. Height Stepper
          _buildStepperCard(
            label: t.height,
            valueText: heightCm.round().toString(),
            unit: t.heightUnit,
            onMinus: () {
              if (heightCm > 120) onHeightChanged(heightCm - 1);
            },
            onPlus: () {
              if (heightCm < 230) onHeightChanged(heightCm + 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption({
    required String id,
    required String label,
    required IconData icon,
  }) {
    final isSelected = gender == id;

    return InkWell(
      onTap: () => onGenderChanged(id),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF4F9ED) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF84CC16) : AppColors.neutral200,
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
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.greenDark : AppColors.neutral500,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: isSelected ? AppColors.greenDark : AppColors.darkCharcoal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperCard({
    required String label,
    required String valueText,
    required String unit,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.neutral200, width: 1.2),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          // Label Kiri (Age / Height)
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.darkCharcoal,
              ),
            ),
          ),

          // Stepper Minus & Plus di Tengah
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCircleStepButton(
                  icon: Icons.remove_rounded,
                  onTap: onMinus,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    valueText,
                    style: AppTypography.displayMedium.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                ),
                _buildCircleStepButton(
                  icon: Icons.add_rounded,
                  onTap: onPlus,
                ),
              ],
            ),
          ),

          // Satuan di Kanan (years / cm)
          SizedBox(
            width: 50,
            child: Text(
              unit,
              textAlign: TextAlign.end,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleStepButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF1F5F9),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.darkCharcoal,
          ),
        ),
      ),
    );
  }
}

