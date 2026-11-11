import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/program_detail_controller.dart';
import '../widgets/program_about_card.dart';
import '../widgets/program_hero_header.dart';
import '../widgets/program_schedule_card.dart';
import '../widgets/program_workouts_section.dart';

/// Layar Detail Program Olahraga (Mockup 1:1)
/// Mengikuti aturan arsitektur & desain wajib:
/// - Feature-First Layered Architecture (lib/features/program/)
/// - Riverpod StateNotifier
/// - Token AppColors & AppTypography
/// - Komponen Global Reusable: AppButton, AppCard, AppSectionHeader, AppSmartImage, AppBadge
/// - GoRouter Navigation
class ProgramDetailScreen extends ConsumerWidget {
  final String programId;

  const ProgramDetailScreen({super.key, required this.programId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(programDetailControllerProvider(programId));
    final controller = ref.read(
      programDetailControllerProvider(programId).notifier,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.darkCharcoal,
            size: 24,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Program Detail',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.darkCharcoal,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.bookmark_border_rounded,
              color: AppColors.darkCharcoal,
              size: 24,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Program disimpan ke bookmark.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.more_horiz_rounded,
              color: AppColors.darkCharcoal,
              size: 24,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Konten Scrollable
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Card Header (Beginner, Upper Body Strength, Meta)
                ProgramHeroHeader(program: state.program),
                const SizedBox(height: 18),

                // 2. About This Program (Deskripsi, Fitur, Anatomi Target Otot)
                ProgramAboutCard(program: state.program),
                const SizedBox(height: 18),

                // 3. Weekly Schedule (7 Hari Chips Mon - Sun)
                ProgramScheduleCard(program: state.program),
                const SizedBox(height: 18),

                // 4. Program Workouts (Week Selector + Daftar Sesi Hari)
                ProgramWorkoutsSection(
                  program: state.program,
                  selectedWeek: state.selectedWeek,
                  onSelectWeek: controller.selectWeek,
                  onDayTap: (day) {
                    if (day.isRest) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Hari ini adalah sesi istirahat & pemulihan aktif.',
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    // Buka Detail Workout menggunakan GoRouter
                    context.push(
                      AppRoutes.workoutDetail,
                      extra: WorkoutDetailArgs(
                        dayNumber: day.day,
                        weekDayText: 'Week ${day.week} • Day ${day.day}',
                        workoutTitle: day.title ?? 'Upper Body Workout',
                        targetMusclesText: day.focus.en,
                        durationText: '${day.estimatedDurationMinutes} min',
                        levelText: state.program.difficulty.label,
                      ),
                    );
                  },
                ),

                // Ruang ekstra untuk sticky bottom bar
                const SizedBox(height: 96),
              ],
            ),
          ),

          // Bottom Sticky CTA Action Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(
                  top: BorderSide(color: AppColors.neutral200, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: AppButton.primary(
                  text: state.isCurrentActive
                      ? 'Program Sedang Aktif'
                      : 'Start This Program',
                  icon: state.isCurrentActive
                      ? Icons.check_circle_rounded
                      : Icons.play_arrow_rounded,
                  isLoading: state.isStartingProgram,
                  onPressed: state.isCurrentActive
                      ? null
                      : () async {
                          final success = await controller.startProgram();
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Program "${state.program.title.en}" berhasil diaktifkan!',
                                ),
                                backgroundColor: const Color(0xFF16A34A),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            // Buka tab Plan untuk melihat kurikulum baru
                            context.go(AppRoutes.plans);
                          }
                        },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
