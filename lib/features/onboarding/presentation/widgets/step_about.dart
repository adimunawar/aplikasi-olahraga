import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_stepper_input.dart';
import '../../../../i18n/strings.g.dart';

/// Step 2 of 7: Tell us about you (Gender, Age) (Light & Dark Mode)
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
    final colorScheme = Theme.of(context).colorScheme;

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
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t.subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            t.gender,
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              fontSize: 16,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildGenderCard(
                  context: context,
                  id: 'male',
                  label: t.male,
                  icon: Icons.male_rounded,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildGenderCard(
                  context: context,
                  id: 'female',
                  label: t.female,
                  icon: Icons.female_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
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
    required BuildContext context,
    required String id,
    required String label,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final isSelected = gender == id;

    return InkWell(
      onTap: () => onGenderChanged(id),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? (isDark ? colorScheme.primary : AppColors.greenBrand)
                : colorScheme.outline,
            width: isSelected ? 1.8 : 1.2,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isSelected ? 0.04 : 0.02),
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
                  ? (isDark ? colorScheme.primary : AppColors.greenBrand)
                  : colorScheme.onSurface,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
