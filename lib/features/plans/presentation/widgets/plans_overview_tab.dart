import 'package:flutter/material.dart';
import '../../../../core/database/models/dynamic_program_entity.dart';
import '../../../../core/database/models/user_profile_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class PlansOverviewTab extends StatelessWidget {
  final UserProfileEntity? profile;
  final TrainingProgramEntity? program;
  final VoidCallback? onSwitchProgram;

  const PlansOverviewTab({
    super.key,
    required this.profile,
    required this.program,
    this.onSwitchProgram,
  });

  String _formatGoal(String? goal) {
    if (goal == null || goal.isEmpty) return 'Gain Weight & Build Muscle';
    final g = goal.toLowerCase();
    if (g.contains('bulk') || g.contains('gain')) {
      return 'Gain Weight & Build Muscle';
    } else if (g.contains('cut') || g.contains('fat') || g.contains('loss')) {
      return 'Lose Weight & Reduce Fat';
    } else if (g.contains('maintain')) {
      return 'Maintain & Stay Fit';
    }
    return 'Gain Weight & Build Muscle';
  }

  String _formatLevel(String? level) {
    if (level == null || level.isEmpty) return 'Beginner';
    return level[0].toUpperCase() + level.substring(1).toLowerCase();
  }

  String _formatEquipment(List<String>? equipments) {
    if (equipments == null || equipments.isEmpty) {
      return 'Bodyweight';
    }
    final labels = equipments.map((e) {
      final key = e.toLowerCase();
      if (key.contains('bodyweight')) return 'Bodyweight';
      if (key.contains('dumbbell')) return 'Dumbbell';
      if (key.contains('resistance') || key.contains('band')) return 'Resistance Band';
      if (key.contains('kettlebell')) return 'Kettlebell';
      if (key.contains('pull')) return 'Pull-up Bar';
      if (key.contains('barbell')) return 'Barbell';
      return e;
    }).toSet().toList();

    return labels.join(', ');
  }

  String _generateExpectedProgressText() {
    final curWeight = profile?.currentWeightKg ?? 75.0;
    final tarWeight = profile?.targetWeightKg ?? 82.0;
    final weeks = profile?.targetTimeframeWeeks ?? (program?.durationWeeks ?? 12);
    final diff = tarWeight - curWeight;

    final goal = (profile?.goal ?? 'bulking').toLowerCase();
    if (goal.contains('bulk') || goal.contains('gain') || diff > 0) {
      final minGain = diff > 0 ? (diff * 0.8).toStringAsFixed(0) : '6';
      final maxGain = diff > 0 ? diff.toStringAsFixed(0) : '8';
      return 'Around +$minGain – $maxGain kg in $weeks weeks, depending on your nutrition, consistency, and recovery.';
    } else if (goal.contains('cut') || goal.contains('loss') || diff < 0) {
      final loss = diff.abs().toStringAsFixed(1);
      return 'Targeting -$loss kg in $weeks weeks, with focus on calorie deficit and lean muscle retention.';
    } else {
      return 'Focus on progressive overload, functional strength, and optimal body recomposition over $weeks weeks.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalText = _formatGoal(profile?.goal);
    final durationWeeks = profile?.targetTimeframeWeeks ?? (program?.durationWeeks ?? 12);
    final frequency = profile?.weeklyFrequency ?? (program?.weeklyFrequency ?? 4);
    final durationMinutes = profile?.preferredDurationMin ?? 45;
    final levelText = _formatLevel(profile?.experienceLevel);
    final equipmentText = _formatEquipment(profile?.equipments);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Program Overview Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.cardBorder, width: 1.2),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Program Overview',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    if (onSwitchProgram != null)
                      InkWell(
                        onTap: onSwitchProgram,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            'Edit',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),

                // Item 1: Goal
                _buildOverviewItem(
                  icon: Icons.track_changes_rounded,
                  label: 'Goal',
                  value: goalText,
                ),
                const SizedBox(height: 16),

                // Item 2: Duration
                _buildOverviewItem(
                  icon: Icons.calendar_today_rounded,
                  label: 'Duration',
                  value: '$durationWeeks Weeks',
                ),
                const SizedBox(height: 16),

                // Item 3: Frequency
                _buildOverviewItem(
                  icon: Icons.event_repeat_rounded,
                  label: 'Frequency',
                  value: '$frequency Days / Week',
                ),
                const SizedBox(height: 16),

                // Item 4: Time per Session
                _buildOverviewItem(
                  icon: Icons.access_time_rounded,
                  label: 'Time per Session',
                  value: '≈ $durationMinutes Minutes',
                ),
                const SizedBox(height: 16),

                // Item 5: Level
                _buildOverviewItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Level',
                  value: levelText,
                ),
                const SizedBox(height: 16),

                // Item 6: Equipment
                _buildOverviewItem(
                  icon: Icons.fitness_center_rounded,
                  label: 'Equipment',
                  value: equipmentText,
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 2. Expected Progress Card (Lime Accent Background)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FEE7), // Soft lime
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD9F99D), width: 1.2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.limeAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: AppColors.darkCharcoal,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expected Progress',
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _generateExpectedProgressText(),
                        style: AppTypography.bodySmall.copyWith(
                          color: const Color(0xFF4B5563),
                          fontSize: 12.5,
                          height: 1.4,
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

  Widget _buildOverviewItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 19,
            color: const Color(0xFF4B5563),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.darkCharcoal,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

