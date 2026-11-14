import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_stepper_input.dart';
import '../../../../i18n/strings.g.dart';

/// Step 2 of 7: Tell us about you (Gender, Age) (Mockup 1:1)
class StepAbout extends StatelessWidget {
  final String gender;
  final int age;
  final ValueChanged<String> onGenderChanged;
  final ValueChanged<int> onAgeChanged;

  const StepAbout({
    super.key,
    required this.gender,
    required this.age,
    required this.onGenderChanged,
    required this.onAgeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context).onboarding.about;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.title,
            style: AppTypography.displayMedium.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 26,
              letterSpacing: -0.5,
              color: AppColors.darkCharcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t.subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // 1. Gender Selector
          Text(
            t.gender,
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.darkCharcoal,
              fontSize: 16,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildGenderCard(
                  id: 'male',
                  label: t.male,
                  icon: Icons.male_rounded,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildGenderCard(
                  id: 'female',
                  label: t.female,
                  icon: Icons.female_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Age Stepper with Manual Typing
          AppStepperInput(
            label: t.age,
            unit: t.ageUnit,
            value: age.toDouble(),
            step: 1.0,
            minValue: 14.0,
            maxValue: 90.0,
            isDecimal: false,
            onChanged: (val) => onAgeChanged(val.round()),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGenderCard({
    required String id,
    required String label,
    required IconData icon,
  }) {
    final isSelected = gender == id;

    return InkWell(
      onTap: () => onGenderChanged(id),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF2FCD6) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFC7EFA0)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.8 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.04 : 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 34,
              color: isSelected
                  ? const Color(0xFF65A30D)
                  : const Color(0xFF1E293B),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: AppColors.darkCharcoal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
