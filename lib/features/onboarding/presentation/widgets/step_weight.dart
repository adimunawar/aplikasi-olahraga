import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';
import 'onboarding_stepper_card.dart';
import 'step_weight/step_weight_widgets.dart';

/// Step 4 of 8: Current weight & target weight with dynamic CustomPainter scale.
class StepWeight extends StatelessWidget {
  final double currentWeightKg;
  final double targetWeightKg;
  final String gender;
  final ValueChanged<double> onCurrentWeightChanged;
  final ValueChanged<double> onTargetWeightChanged;

  const StepWeight({
    super.key,
    required this.currentWeightKg,
    required this.targetWeightKg,
    this.gender = 'male',
    required this.onCurrentWeightChanged,
    required this.onTargetWeightChanged,
  });

  static const double _minWeightKg = 30.0;
  static const double _maxWeightKg = 250.0;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context).onboarding.bodyTarget;
    final colorScheme = Theme.of(context).colorScheme;

    final diff = targetWeightKg - currentWeightKg;
    final absDiff = diff.abs();
    final isGain = diff > 0.05;
    final isLoss = diff < -0.05;

    final insightTitle = isGain
        ? t.insight.gainTitle(diff: diff.toStringAsFixed(1))
        : (isLoss
              ? t.insight.lossTitle(diff: diff.toStringAsFixed(1))
              : t.insight.maintainTitle);

    final insightHint = isGain
        ? t.insight.gainHint(
            minWeeks: (absDiff / 0.5).round(),
            maxWeeks: (absDiff / 0.25).round(),
          )
        : (isLoss
              ? t.insight.lossHint(
                  minWeeks: (absDiff / 1.0).round(),
                  maxWeeks: (absDiff / 0.5).round(),
                )
              : t.insight.maintainHint);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.currentWeight,
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
          const SizedBox(height: 14),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 210,
                  child: CharacterScaleStage(
                    weightKg: currentWeightKg,
                    unit: t.unit,
                    gender: gender,
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 20,
                  width: 218,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OnboardingStepperCard(
                        label: t.currentWeight,
                        unit: t.unit,
                        value: currentWeightKg,
                        step: 0.5,
                        minValue: _minWeightKg,
                        maxValue: _maxWeightKg,
                        icon: Icons.monitor_weight_outlined,
                        highlightBorder: true,
                        onChanged: (val) => onCurrentWeightChanged(
                          double.parse(val.toStringAsFixed(1)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OnboardingStepperCard(
                        label: t.targetWeight,
                        unit: t.unit,
                        value: targetWeightKg,
                        step: 0.5,
                        minValue: _minWeightKg,
                        maxValue: _maxWeightKg,
                        icon: Icons.monitor_weight_outlined,
                        onChanged: (val) => onTargetWeightChanged(
                          double.parse(val.toStringAsFixed(1)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InsightBannerCard(title: insightTitle, hint: insightHint),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
