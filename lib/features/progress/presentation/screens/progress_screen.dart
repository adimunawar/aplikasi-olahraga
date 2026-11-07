import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../controllers/progress_controller.dart';
import '../widgets/progress_header.dart';
import '../widgets/top_metrics_summary_card.dart';
import '../widgets/weight_progress_card.dart';
import '../widgets/bmi_overview_card.dart';
import '../widgets/workout_activity_chart_card.dart';
import '../widgets/weekly_goal_card.dart';
import '../widgets/streak_card.dart';
import '../widgets/recent_workouts_section.dart';
import '../widgets/program_progress_bottom_card.dart';
import '../widgets/weekly_movement_volume_card.dart';
import '../widgets/progression_milestones_card.dart';

/// Halaman Progress & Riwayat Latihan (Arsitektur Layered + Riverpod 2.x):
/// - Presentation Layer murni (ConsumerWidget)
/// - Mengamati State secara reaktif melalui `progressControllerProvider`
/// - Bebas dari pemanggilan langsung ke Database / I/O
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  void _showRecordWeightDialog(BuildContext context, WidgetRef ref, double initialWeight) {
    final controller = TextEditingController(text: initialWeight.toStringAsFixed(1));

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.scale_rounded, color: AppColors.greenBrand),
              const SizedBox(width: 8),
              Text(
                'Catat Berat Badan',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppColors.darkCharcoal,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Masukkan berat badan terkini kamu untuk memperbarui grafik progres dan BMI:',
                style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Berat Badan (kg)',
                  suffixText: 'kg',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.greenBrand, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Batal',
                style: AppTypography.labelMedium.copyWith(color: AppColors.neutral500),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final newWeight = double.tryParse(controller.text);
                if (newWeight != null && newWeight > 0) {
                  Navigator.pop(ctx);
                  await ref.read(progressControllerProvider.notifier).recordWeight(newWeight);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Berat badan berhasil dicatat: $newWeight kg'),
                        backgroundColor: AppColors.darkCharcoal,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.limeAccent,
                foregroundColor: AppColors.darkCharcoal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Simpan',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkCharcoal,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(progressControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.darkCharcoal,
          backgroundColor: AppColors.limeAccent,
          onRefresh: () => ref.read(progressControllerProvider.notifier).loadProgress(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Progres
                const ProgressHeader(),
                const SizedBox(height: 16),

                // 2. Top Metrics Summary: Workouts, Calories, Minutes dinamis dari Provider
                TopMetricsSummaryCard(
                  workoutCount: state.metrics.workoutCount,
                  caloriesBurned: state.metrics.caloriesBurned,
                  totalMinutes: state.metrics.totalMinutes,
                ),
                const SizedBox(height: 14),

                // 3. Dual Cards: Weight (Sparkline) & BMI (Spectrum bar)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: WeightProgressCard(
                        currentWeight: state.currentWeight,
                        weightChange: state.weightChange,
                        startLabel: state.startLabel,
                        endLabel: state.endLabel,
                        onTap: () => _showRecordWeightDialog(context, ref, state.currentWeight),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BmiOverviewCard(
                        bmiValue: state.bmiValue,
                        statusText: state.bmiStatus,
                        onTap: () => _showRecordWeightDialog(context, ref, state.currentWeight),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 4. Workout Activity Bar Chart (Mon - Sun dinamis)
                WorkoutActivityChartCard(
                  weeklyData: state.weeklyActivity,
                ),
                const SizedBox(height: 14),

                // 4b. Distribusi Volume Otot Biomekanikal (Push/Pull/Squat/Hinge/Core - Fase 5)
                WeeklyMovementVolumeCard(
                  volumeData: state.movementVolume,
                ),
                const SizedBox(height: 14),

                // 5. Dual Cards: Weekly Goal (3 of 4) & Streak
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 11,
                      child: WeeklyGoalCard(
                        completedWorkouts: state.metrics.completedThisWeek,
                        targetWorkouts: state.metrics.weeklyTarget,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 9,
                      child: StreakCard(
                        streakDays: state.metrics.streakDays,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 6. Recent Workouts (Daftar sesi latihan dari Provider)
                RecentWorkoutsSection(
                  workouts: state.recentWorkouts,
                ),
                const SizedBox(height: 14),

                // 6b. Pencapaian Tangga Gerakan & Riwayat Adaptasi Coach Adi (Fase 5)
                ProgressionMilestonesCard(
                  milestones: state.milestones,
                ),
                const SizedBox(height: 14),

                // 7. Program Progress Bottom (Status program aktif saat ini)
                ProgramProgressBottomCard(
                  programTitle: state.activeProgramTitle,
                  currentWeek: state.activeProgramWeek,
                  totalWeeks: state.activeProgramTotalWeeks,
                  percent: state.activeProgramPercent,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
