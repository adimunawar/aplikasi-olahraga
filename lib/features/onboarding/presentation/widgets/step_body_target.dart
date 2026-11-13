import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Step 3 of 7: Your body & target (Current & Target Weight) (Mockup 1:1)
class StepBodyTarget extends StatelessWidget {
  final double currentWeightKg;
  final double targetWeightKg;
  final ValueChanged<double> onCurrentWeightChanged;
  final ValueChanged<double> onTargetWeightChanged;

  const StepBodyTarget({
    super.key,
    required this.currentWeightKg,
    required this.targetWeightKg,
    required this.onCurrentWeightChanged,
    required this.onTargetWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    final diff = targetWeightKg - currentWeightKg;
    final isGain = diff > 0.05;
    final isLoss = diff < -0.05;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your body & target',
            style: AppTypography.displayMedium.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 24,
              color: AppColors.darkCharcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Set your current and target weight.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.neutral500,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),

          // 1. Current Weight Stepper Card
          _buildWeightStepperCard(
            icon: Icons.scale_rounded,
            label: 'Current weight',
            value: currentWeightKg,
            onMinus: () {
              if (currentWeightKg > 35) {
                onCurrentWeightChanged(
                  double.parse((currentWeightKg - 0.5).toStringAsFixed(1)),
                );
              }
            },
            onPlus: () {
              if (currentWeightKg < 200) {
                onCurrentWeightChanged(
                  double.parse((currentWeightKg + 0.5).toStringAsFixed(1)),
                );
              }
            },
          ),
          const SizedBox(height: 16),

          // 2. Target Weight Stepper Card
          _buildWeightStepperCard(
            icon: Icons.track_changes_rounded,
            label: 'Target weight',
            value: targetWeightKg,
            onMinus: () {
              if (targetWeightKg > 35) {
                onTargetWeightChanged(
                  double.parse((targetWeightKg - 0.5).toStringAsFixed(1)),
                );
              }
            },
            onPlus: () {
              if (targetWeightKg < 200) {
                onTargetWeightChanged(
                  double.parse((targetWeightKg + 0.5).toStringAsFixed(1)),
                );
              }
            },
          ),
          const SizedBox(height: 24),

          // 3. Dynamic Calculation Insight Card
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
                        isGain
                            ? 'Target gain: +${diff.toStringAsFixed(1)} kg'
                            : (isLoss
                                ? 'Target loss: ${diff.toStringAsFixed(1)} kg'
                                : 'Target: Maintenance'),
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isGain
                            ? 'A healthy gain is around 0.25 - 0.5 kg per week (${(diff.abs() / 0.5).round()} - ${(diff.abs() / 0.25).round()} weeks).'
                            : (isLoss
                                ? 'A healthy loss is around 0.5 - 1.0 kg per week (${(diff.abs() / 1.0).round()} - ${(diff.abs() / 0.5).round()} weeks).'
                                : 'Keep your current body weight and focus on building muscle density and strength.'),
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
        ],
      ),
    );
  }

  Widget _buildWeightStepperCard({
    required IconData icon,
    required String label,
    required double value,
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
          Icon(icon, size: 20, color: AppColors.greenDark),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.darkCharcoal,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCircleStepButton(
                icon: Icons.remove_rounded,
                onTap: onMinus,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  value.toStringAsFixed(1),
                  style: AppTypography.displayMedium.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
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
          const SizedBox(width: 12),
          Text(
            'kg',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral500,
              fontSize: 13,
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
          padding: const EdgeInsets.all(7),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.darkCharcoal,
          ),
        ),
      ),
    );
  }
}

