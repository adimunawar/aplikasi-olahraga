import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/home_controller.dart';
import '../controllers/home_state.dart';
import '../widgets/goal_progress_card.dart';
import '../widgets/home_error_banner.dart';
import '../widgets/home_greeting_header.dart';
import '../widgets/home_loading_skeleton.dart';
import '../widgets/recovery_guide_bottom_sheet.dart';
import '../widgets/recovery_routine_screen.dart';
import '../widgets/support_goal_nutrition_card.dart';
import '../widgets/today_workout/today_workout_section.dart';
import '../widgets/weekly_progress_calendar_card.dart';

/// Halaman Home Utama Redesign (Phase B: ConsumerWidget dengan Riverpod HomeController)
class HomeScreen extends ConsumerWidget {
  final VoidCallback onNavigateToCalendar;
  final VoidCallback onNavigateToExercises;
  final VoidCallback onNavigateToNutrition;
  final VoidCallback? onNavigateToProgress;

  const HomeScreen({
    super.key,
    required this.onNavigateToCalendar,
    required this.onNavigateToExercises,
    required this.onNavigateToNutrition,
    this.onNavigateToProgress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);
    final controller = ref.read(homeControllerProvider.notifier);

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF9FAFB),
        body: SafeArea(
          child: HomeLoadingSkeleton(),
        ),
      );
    }

    final profile = state.userProfile;
    final userName = profile?.displayName.isNotEmpty == true
        ? profile!.displayName
        : 'Adi';

    Future<void> openHydrationGuide() =>
        showRecoveryGuideBottomSheet(context, RecoveryGuideType.hydration);

    Future<void> openSleepGuide() =>
        showRecoveryGuideBottomSheet(context, RecoveryGuideType.sleep);

    void openRecoveryRoutine() {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          builder: (_) => const RecoveryRoutineScreen(),
        ),
      );
    }

    Future<void> startWorkoutSession() async {
      final day = state.todayProgram;
      if (day != null && !day.isRest) {
        await context.push(
          AppRoutes.workoutSession,
          extra: WorkoutSessionArgs(day: day, exercises: state.todayExercises),
        );
        controller.refresh();
      } else {
        onNavigateToCalendar();
      }
    }

    Future<void> viewWorkoutDetail() async {
      final day = state.todayProgram;
      if (day != null) {
        await context.push(
          AppRoutes.workoutDetail,
          extra: WorkoutDetailArgs(
            dayNumber: day.day,
            weekDayText: 'Week ${day.week} • Day ${day.day}',
            workoutTitle: state.sessionFocus,
            targetMusclesText: state.targetMuscles,
            durationText: '${state.sessionDurationMinutes} min',
            levelText: state.userProfile?.experienceLevel ?? 'Beginner',
          ),
        );
        controller.refresh();
      } else {
        onNavigateToCalendar();
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 6, bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Sapaan & Notifikasi (Mockup 1:1)
                HomeGreetingHeader(
                  userName: userName,
                  hasUnreadNotification: true,
                  onNotificationTap: () {},
                  onProfileTap: () {
                    context.push(AppRoutes.profile);
                  },
                ),

                // Offline / Connection Issue Banner jika terjadi error
                if (state.errorType == HomeErrorType.network ||
                    state.errorType == HomeErrorType.database)
                  HomeErrorBanner(
                    lastSyncedTime: state.lastSyncedTime,
                    onRetry: controller.refresh,
                  ),

                const SizedBox(height: 10),

                // 2. Goal Progress Card (Mockup 1:1)
                GoalProgressCard(
                  goalTitle: 'Goal: ${state.programTitle}',
                  targetWeightKg: profile?.targetWeightKg ?? 82.0,
                  currentWeightKg: profile?.currentWeightKg ?? 75.8,
                  totalWeeks: state.totalWeeks,
                  currentWeek: state.currentWeek,
                  onTap: onNavigateToProgress,
                ),

                const SizedBox(height: 22),

                // 3. Today's Workout Section (Active / Completed / Rest Day / No Program)
                TodayWorkoutSection(
                  state: state.workoutCardState,
                  sessionTitle: state.sessionFocus,
                  targetMuscles: state.targetMuscles,
                  durationMinutes: state.sessionDurationMinutes,
                  estimatedCalories: state.estimatedCalories,
                  onStartWorkout: startWorkoutSession,
                  onViewPlan: viewWorkoutDetail,
                  onCreateProgram: onNavigateToCalendar,
                  onHydrationTap: openHydrationGuide,
                  onSleepTap: openSleepGuide,
                  onStretchingTap: openRecoveryRoutine,
                ),

                const SizedBox(height: 22),

                // 4. This Week Progress (Kalender 7 Hari, 5 Status - Mockup 1:1)
                WeeklyProgressCalendarCard(
                  days: state.weeklyDays,
                  onSeeDetails: () {
                    if (onNavigateToProgress != null) {
                      onNavigateToProgress!();
                    } else {
                      onNavigateToCalendar();
                    }
                  },
                ),

                const SizedBox(height: 22),

                // 5. Support Your Goal - Panduan Nutrisi (Mockup 1:1)
                SupportGoalNutritionCard(
                  userGoal: profile?.goal ?? 'muscle_gain',
                  onTap: onNavigateToNutrition,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
