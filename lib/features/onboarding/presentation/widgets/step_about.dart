import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';
import 'onboarding_stepper_card.dart';
import 'step_about/step_about_widgets.dart';

/// Step 2 of 8: Tell us about you (Gender, Age) (Light & Dark Mode)
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.title,
            style: AppTypography.displayMedium.copyWith(
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              fontSize: 26,
              height: 1.15,
              letterSpacing: -0.5,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GenderCard(
                  label: t.male,
                  icon: Icons.male_rounded,
                  imagePath: 'assets/images/man-half-body.webp',
                  isSelected: gender == 'male',
                  onTap: () => onGenderChanged('male'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GenderCard(
                  label: t.female,
                  icon: Icons.female_rounded,
                  imagePath: 'assets/images/women_upper_body.webp',
                  isSelected: gender == 'female',
                  onTap: () => onGenderChanged('female'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          OnboardingStepperCard(
            label: t.age,
            unit: t.ageUnit,
            value: age.toDouble(),
            step: 1.0,
            minValue: 14.0,
            maxValue: 90.0,
            icon: Icons.calendar_today_outlined,
            highlightBorder: true,
            onChanged: (val) => onAgeChanged(val.round()),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
