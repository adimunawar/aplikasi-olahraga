import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_stepper_input.dart';
import '../../../../i18n/strings.g.dart';

/// Step 3 of 7: Your body & target (Height, Current Weight, Target Weight) (Mockup 1:1)
class StepBodyTarget extends StatelessWidget {
  final double heightCm;
  final double currentWeightKg;
  final double targetWeightKg;
  final ValueChanged<double> onHeightChanged;
  final ValueChanged<double> onCurrentWeightChanged;
  final ValueChanged<double> onTargetWeightChanged;

  const StepBodyTarget({
    super.key,
    required this.heightCm,
    required this.currentWeightKg,
    required this.targetWeightKg,
    required this.onHeightChanged,
    required this.onCurrentWeightChanged,
    required this.onTargetWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context).onboarding.bodyTarget;
    final tAbout = Translations.of(context).onboarding.about;

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

          // 1. Height Stepper with Manual Input
          AppStepperInput(
            label: tAbout.height,
            unit: tAbout.heightUnit,
            value: heightCm,
            step: 1.0,
            minValue: 100.0,
            maxValue: 230.0,
            isDecimal: false,
            onChanged: onHeightChanged,
          ),
          const SizedBox(height: 24),

          // 2. Current Weight Stepper with Manual Input
          AppStepperInput(
            label: t.currentWeight,
            unit: t.unit,
            value: currentWeightKg,
            step: 0.5,
            minValue: 30.0,
            maxValue: 250.0,
            isDecimal: true,
            onChanged: (val) {
              onCurrentWeightChanged(double.parse(val.toStringAsFixed(1)));
            },
          ),
          const SizedBox(height: 24),

          // 3. Target Weight Stepper with Manual Input
          AppStepperInput(
            label: t.targetWeight,
            unit: t.unit,
            value: targetWeightKg,
            step: 0.5,
            minValue: 30.0,
            maxValue: 250.0,
            isDecimal: true,
            onChanged: (val) {
              onTargetWeightChanged(double.parse(val.toStringAsFixed(1)));
            },
          ),
          const SizedBox(height: 24),

          // 4. Dynamic Calculation Insight Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F9ED),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2EED3), width: 1.2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.flag_rounded,
                    size: 18,
                    color: Color(0xFF16A34A),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insightTitle,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        insightHint,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.neutral600,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
