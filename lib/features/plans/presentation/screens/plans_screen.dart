import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../../../program/domain/models/workout_program.dart';
import '../controllers/plans_controller.dart';
import '../widgets/plans_header.dart';
import '../widgets/current_plan_hero_card.dart';
import '../widgets/weekly_schedule_days_section.dart';
import '../widgets/workouts_in_this_plan_section.dart';
import '../widgets/other_programs_section.dart';
import 'plans_3tabs_screen_backup.dart';

/// Halaman Plans (Desain 1:1 Mockup dengan Riverpod 2.x & Clean Layered Architecture)
class PlansScreen extends ConsumerWidget {
  final int initialTabIndex;

  const PlansScreen({super.key, this.initialTabIndex = 0});

  // Toggle cadangan untuk desain lama 3-tab jika dibutuhkan
  static const bool _showOld3TabsDesign = false;

  void _showProgramDetailModal(
    BuildContext context,
    WidgetRef ref,
    WorkoutProgram program,
  ) {
    String title = program.title.en.isNotEmpty ? program.title.en : program.title.id;
    if (title.trim().isEmpty) {
      title = program.id
          .replaceAll('_', ' ')
          .split(' ')
          .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
          .join(' ');
    }

    String desc = program.description.en.isNotEmpty ? program.description.en : program.description.id;
    if (desc.trim().isEmpty) {
      desc = 'Program latihan terstruktur untuk membangun massa otot di rumah.';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.neutral200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Badges (DRY via AppBadge)
              Row(
                children: [
                  AppBadge.category(label: program.category.name),
                  const SizedBox(width: 8),
                  AppBadge.difficulty(label: program.difficulty.name),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                title,
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                desc,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.neutral500,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Duration stats
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.neutral100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildModalStat(Icons.calendar_today_rounded, '${program.totalWeeks} Weeks', 'Duration'),
                    Container(width: 1, height: 32, color: AppColors.neutral200),
                    _buildModalStat(Icons.fitness_center_rounded, '${program.daysPerWeek} Days/Week', 'Frequency'),
                    Container(width: 1, height: 32, color: AppColors.neutral200),
                    _buildModalStat(Icons.speed_rounded, program.difficulty.name, 'Difficulty'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Mulai Program Ini (DRY via AppButton)
              AppButton.primary(
                text: 'Mulai Program Ini',
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    await ref
                        .read(plansControllerProvider.notifier)
                        .switchActiveProgram(program);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: AppColors.limeAccent),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Program aktif berhasil diubah ke $title!',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: AppColors.darkCharcoal,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal mengganti program: $e')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalStat(IconData icon, String val, String label) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.darkCharcoal),
        const SizedBox(height: 4),
        Text(
          val,
          style: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 12.5,
            color: AppColors.darkCharcoal,
          ),
        ),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            fontSize: 10.5,
            color: AppColors.neutral400,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_showOld3TabsDesign) {
      return Plans3TabsScreenBackup(initialTabIndex: initialTabIndex);
    }

    final state = ref.watch(plansControllerProvider);
    final active = state.activeProgram;

    String title = active?.title.en.isNotEmpty == true
        ? active!.title.en
        : (active?.title.id.isNotEmpty == true ? active!.title.id : '');
    if (title.trim().isEmpty) {
      final id = active?.id ?? '';
      title = id.isNotEmpty
          ? id.replaceAll('_', ' ').split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ')
          : 'Upper Body Strength';
    }

    String desc = active?.description.en.isNotEmpty == true
        ? active!.description.en
        : (active?.description.id.isNotEmpty == true ? active!.description.id : '');
    if (desc.trim().isEmpty) {
      desc = 'Build a stronger chest, back, arms, and shoulders at home.';
    }
    final totalWeeks = active?.totalWeeks ?? 8;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.darkCharcoal,
          backgroundColor: AppColors.limeAccent,
          onRefresh: () => ref.read(plansControllerProvider.notifier).loadPrograms(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Plans
                const PlansHeader(),
                const SizedBox(height: 16),

                // 2. Current Plan Hero Card (Reaktif dari Riverpod State)
                CurrentPlanHeroCard(
                  title: title,
                  description: desc,
                  currentWeek: state.currentWeek,
                  totalWeeks: totalWeeks,
                  progressPercent: state.progressPercent,
                ),
                const SizedBox(height: 22),

                // 3. Weekly Schedule (Mon - Sun dinamis sesuai minggu yang dipilih)
                WeeklyScheduleDaysSection(
                  selectedWeek: state.selectedWeekNumber,
                  currentWeek: state.currentWeek,
                  totalWeeks: totalWeeks,
                  days: state.currentWeekDays,
                  completedDayNumbers: state.completedDaysForSelectedWeek,
                  onSelectWeek: (weekNum) {
                    ref.read(plansControllerProvider.notifier).selectWeek(weekNum);
                  },
                ),
                const SizedBox(height: 22),

                // 4. Workouts in This Plan (Daftar sesi dinamis sesuai minggu terpilih)
                WorkoutsInThisPlanSection(
                  totalWeeks: totalWeeks,
                  daysPerWeek: active?.daysPerWeek ?? 4,
                  selectedWeek: state.selectedWeekNumber,
                  days: state.currentWeekDays,
                  completedDayNumbers: state.completedDaysForSelectedWeek,
                ),
                const SizedBox(height: 22),

                // 5. Other Programs (Carousel Program Lain)
                OtherProgramsSection(
                  programs: state.otherPrograms,
                  onSelectProgram: (p) => _showProgramDetailModal(context, ref, p),
                  onSeeAll: () {},
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
