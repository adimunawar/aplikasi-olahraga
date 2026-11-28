import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';
import 'step_height/step_height_widgets.dart';

/// Step 3 of 8: Your height (Interactive ruler + character height stage).
class StepHeight extends StatelessWidget {
  final double heightCm;
  final String gender;
  final ValueChanged<double> onHeightChanged;

  const StepHeight({
    super.key,
    required this.heightCm,
    this.gender = 'male',
    required this.onHeightChanged,
  });

  static const double _minHeightCm = 100.0;
  static const double _maxHeightCm = 230.0;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context).onboarding.bodyTarget;
    final tAbout = Translations.of(context).onboarding.about;
    final colorScheme = Theme.of(context).colorScheme;
    final heightRatio =
        ((heightCm - _minHeightCm) / (_maxHeightCm - _minHeightCm)).clamp(
          0.0,
          1.0,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Text(
            tAbout.height,
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
          const SizedBox(height: 12),
          Expanded(
            child: CharacterHeightStage(
              heightCm: heightCm,
              unit: tAbout.heightUnit,
              heightRatio: heightRatio,
              gender: gender,
            ),
          ),
          const SizedBox(height: 16),
          HeightRulerCard(
            label: tAbout.height,
            unit: tAbout.heightUnit,
            heightCm: heightCm,
            minHeightCm: _minHeightCm,
            maxHeightCm: _maxHeightCm,
            onChanged: onHeightChanged,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
