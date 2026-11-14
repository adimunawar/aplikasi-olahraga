import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_app/core/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/dynamic_program_entity.dart';
import '../../../../core/database/models/user_profile_entity.dart';
import '../../../../core/database/models/workout_session_entity.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/app_data_sync.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../../exercises/data/datasources/exercise_local_datasource.dart';
import '../../../exercises/data/repositories/exercise_repository_impl.dart';
import '../../../program/domain/models/program_day.dart';
import '../../../program/domain/services/dynamic_program_generator.dart';
import '../../../program/data/datasources/program_local_datasource.dart';
import '../../../program/data/repositories/program_repository_impl.dart';

import '../widgets/goal_progress_card.dart';
import '../widgets/home_error_banner.dart';
import '../widgets/home_greeting_header.dart';
import '../widgets/home_loading_skeleton.dart';
import '../widgets/support_goal_nutrition_card.dart';
import '../widgets/today_workout/today_workout_section.dart';
import '../widgets/weekly_progress_calendar_card.dart';

/// Halaman Home Utama Redesign 1:1 Sesuai Mockup Referensi (Light Premium + Lime Green)
class HomeScreen extends StatefulWidget {
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
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = AppDatabase.instance;

  UserProfileEntity? _userProfile;
  ProgramDay? _todayProgram;
  List<Exercise> _todayExercises = [];

  String _programTitle = 'Gain Weight & Build Muscle';
  String _sessionFocus = 'Upper Body (Push)';
  String _targetMuscles = 'Chest, Shoulders, Triceps';
  int _sessionDurationMinutes = 45;
  int _estimatedCalories = 280;

  bool _isLoading = true;
  bool _hasProgram = true;
  bool _isTodayRestDay = false;
  bool _hasSyncError = false;
  final String _lastSyncedTime = 'Today, 10:30 AM';

  List<DayProgressData> _weeklyDays = [];
  int _currentWeek = 1;
  int _totalWeeks = 12;

  @override
  void initState() {
    super.initState();
    _loadTodayData();
    AppDataSync.instance.dataRevision.addListener(_onDataSync);
  }

  @override
  void dispose() {
    AppDataSync.instance.dataRevision.removeListener(_onDataSync);
    super.dispose();
  }

  void _onDataSync() {
    if (mounted) {
      _loadTodayData();
    }
  }

  String _formatDayShortEn(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(weekday - 1).clamp(0, 6)];
  }

  String _weekdayToString(int weekday) {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    return days[(weekday - 1).clamp(0, 6)];
  }

  Future<void> _loadTodayData() async {
    try {
      final profile = await _db.getUserProfile();
      final thisWeekCount = await _db.getThisWeekCompletedCount();
      final recentSessions = await _db.getRecentWorkoutSessions(limit: 30);

      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));

      // 1. Goal Label
      String goalLabel = 'Gain Weight & Build Muscle';
      final g = profile.goal.toLowerCase();
      if (g.contains('fat') || g.contains('weight_loss') || g.contains('cut')) {
        goalLabel = 'Fat Loss & Conditioning';
      } else if (g.contains('maintain') || g.contains('fit')) {
        goalLabel = 'Maintain & Stay Fit';
      }

      final targetWeekly = profile.weeklyFrequency > 0
          ? profile.weeklyFrequency
          : (profile.preferredDaysPerWeek > 0 ? profile.preferredDaysPerWeek : 3);

      // 2. Baca / Generate Dynamic Training Program
      final userId = profile.id.isNotEmpty ? profile.id : 'default_user';
      var activeProgram = await _db.getActiveTrainingProgram(userId);
      activeProgram ??= await _db.getActiveTrainingProgram('default_user');

      List<ProgramSessionEntity> sessions = [];
      if (activeProgram != null) {
        sessions = await _db.getProgramSessions(activeProgram.id);
      }

      // Auto-heal jika program belum ada atau sesi kosong
      if (activeProgram == null || sessions.isEmpty || sessions.length != targetWeekly) {
        try {
          final exerciseDatasource = ExerciseLocalDatasource(db: _db);
          final catalog = await exerciseDatasource.loadExercises();
          final startingPushId = profile.experienceLevel == 'advanced'
              ? 'diamond_push_up'
              : profile.experienceLevel == 'intermediate'
                  ? 'push_up'
                  : 'knee_push_up';

          final generated = const DynamicProgramGenerator().generate(
            userProfile: profile,
            catalogExercises: catalog,
            startingPushExerciseId: startingPushId,
          );

          await _db.saveDynamicProgram(
            program: generated.program,
            sessions: generated.sessions,
          );
          activeProgram = generated.program;
          sessions = await _db.getProgramSessions(activeProgram.id);
        } catch (e) {
          debugPrint('[HomeScreen] Auto-generate program error: $e');
        }
      }

      List<Exercise> todayExercises = [];
      String focusLabel = 'Upper Body (Push)';
      String musclesLabel = 'Chest, Shoulders, Triceps';
      int sessionDuration = profile.preferredDurationMin > 0
          ? profile.preferredDurationMin
          : 45;
      int calories = (sessionDuration * 6.2).round();
      ProgramDay? programDay;

      final todayStr = _weekdayToString(now.weekday);
      final isScheduledTrainingDay = profile.availableDays.contains(todayStr);

      if (activeProgram != null && sessions.isNotEmpty) {
        final nextIndex = thisWeekCount % sessions.length;
        final nextSession = sessions[nextIndex];
        focusLabel = nextSession.name.isNotEmpty
            ? nextSession.name
            : 'Upper Body (Push)';
        musclesLabel = nextSession.focusLabel.isNotEmpty
            ? nextSession.focusLabel
            : 'Chest, Shoulders, Triceps';
        sessionDuration = nextSession.targetDurationMinutes > 0
            ? nextSession.targetDurationMinutes
            : profile.preferredDurationMin;
        calories = (sessionDuration * 6.2).round();

        final detail = await _db.getProgramSessionDetail(nextSession.id);
        List<WorkoutItem> workoutItems = [];

        if (detail != null && detail.exercises.isNotEmpty) {
          todayExercises = detail.exercises.map((e) => e.exercise).toList();
          workoutItems = detail.exercises.map((e) {
            return WorkoutItem(
              exerciseId: e.exercise.id,
              sets: e.prescription.targetSets,
              reps: e.prescription.minReps,
              restSeconds: e.prescription.restSeconds,
              isMain: e.prescription.stage == 'main',
              stage: e.prescription.stage,
            );
          }).toList();
        }

        programDay = ProgramDay(
          day: nextSession.dayNumber,
          week: (thisWeekCount ~/ targetWeekly) + 1,
          type: WorkoutTypeCode.f,
          focus: LocalizedString(id: focusLabel, en: focusLabel),
          isRest: false,
          isRetestMilestone: false,
          items: workoutItems,
        );
      }

      // 3. Status Selesai Hari Ini
      bool isCompletedToday = false;
      for (final s in recentSessions) {
        if (s.status == WorkoutSessionStatus.completed &&
            s.startedAt.year == now.year &&
            s.startedAt.month == now.month &&
            s.startedAt.day == now.day) {
          isCompletedToday = true;
          break;
        }
      }

      // Rest Day condition: Bukan hari latihan terjadwal ATAU latihan hari ini sudah tuntas
      final isRestDay = !isScheduledTrainingDay || isCompletedToday;

      // 4. Data 7 Hari Mingguan (Mon - Sun) dengan 5 Status Presisi
      final List<DayProgressData> daysList = [];
      for (int i = 0; i < 7; i++) {
        final date = monday.add(Duration(days: i));
        final isToday = date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
        final isPast = date.isBefore(DateTime(now.year, now.month, now.day));

        final isCompleted = recentSessions.any(
          (s) =>
              s.status == WorkoutSessionStatus.completed &&
              s.startedAt.year == date.year &&
              s.startedAt.month == date.month &&
              s.startedAt.day == date.day,
        );

        final dayStr = _weekdayToString(date.weekday);
        final isTrainingScheduled = profile.availableDays.contains(dayStr);

        DayActivityState state;
        if (isCompleted) {
          state = DayActivityState.completed;
        } else if (isToday) {
          state = isTrainingScheduled
              ? DayActivityState.today
              : DayActivityState.rest;
        } else if (isPast) {
          state = isTrainingScheduled
              ? DayActivityState.missed
              : DayActivityState.rest;
        } else {
          // Future days
          state = isTrainingScheduled
              ? DayActivityState.upcoming
              : DayActivityState.rest;
        }

        daysList.add(
          DayProgressData(
            dayName: _formatDayShortEn(date.weekday),
            state: state,
            date: date,
          ),
        );
      }

      final programStartDate = activeProgram?.startDate ?? profile.createdAt;
      final diffWeeks = (now.difference(programStartDate).inDays / 7).floor() + 1;
      final currentWeek = diffWeeks.clamp(1, profile.targetTimeframeWeeks);

      if (mounted) {
        setState(() {
          _userProfile = profile;
          _programTitle = goalLabel;
          _sessionFocus = focusLabel;
          _targetMuscles = musclesLabel;
          _sessionDurationMinutes = sessionDuration;
          _estimatedCalories = calories;
          _todayProgram = programDay;
          _todayExercises = todayExercises;
          _weeklyDays = daysList;
          _hasProgram = activeProgram != null;
          _isTodayRestDay = isRestDay;
          _currentWeek = currentWeek;
          _totalWeeks = profile.targetTimeframeWeeks > 0
              ? profile.targetTimeframeWeeks
              : 12;
          _hasSyncError = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[HomeScreen] Load error: $e');
      if (mounted) {
        setState(() {
          _hasSyncError = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _startWorkoutSession() async {
    final day = _todayProgram;
    if (day != null && !day.isRest) {
      await context.push(
        AppRoutes.workoutSession,
        extra: WorkoutSessionArgs(day: day, exercises: _todayExercises),
      );
      if (mounted) {
        _loadTodayData();
      }
    } else {
      widget.onNavigateToCalendar();
    }
  }

  Future<void> _viewWorkoutDetail() async {
    final day = _todayProgram;
    if (day != null) {
      await context.push(
        AppRoutes.workoutDetail,
        extra: WorkoutDetailArgs(
          dayNumber: day.day,
          weekDayText: 'Week ${day.week} • Day ${day.day}',
          workoutTitle: _sessionFocus,
          targetMusclesText: _targetMuscles,
          durationText: '$_sessionDurationMinutes min',
          levelText: _userProfile?.experienceLevel ?? 'Beginner',
        ),
      );
      if (mounted) {
        _loadTodayData();
      }
    } else {
      widget.onNavigateToCalendar();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF9FAFB),
        body: SafeArea(
          child: HomeLoadingSkeleton(),
        ),
      );
    }

    final profile = _userProfile;
    final userName = profile?.displayName.isNotEmpty == true
        ? profile!.displayName
        : 'Adi';

    final workoutCardState = !_hasProgram
        ? WorkoutCardState.noProgram
        : (_isTodayRestDay ? WorkoutCardState.restDay : WorkoutCardState.active);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadTodayData,
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

                // Offline / Error Banner jika sync bermasalah
                if (_hasSyncError)
                  HomeErrorBanner(
                    lastSyncedTime: _lastSyncedTime,
                    onRetry: _loadTodayData,
                  ),

                const SizedBox(height: 10),

                // 2. Goal Progress Card (Mockup 1:1)
                GoalProgressCard(
                  goalTitle: 'Goal: $_programTitle',
                  targetWeightKg: profile?.targetWeightKg ?? 82.0,
                  currentWeightKg: profile?.currentWeightKg ?? 75.8,
                  weightDeltaKg: profile != null
                      ? (profile.currentWeightKg - profile.targetWeightKg).abs()
                      : 0.8,
                  totalWeeks: _totalWeeks,
                  currentWeek: _currentWeek,
                  onTap: _viewWorkoutDetail,
                ),

                const SizedBox(height: 22),

                // 3. Today's Workout Section (Active / Rest Day / No Program)
                TodayWorkoutSection(
                  state: workoutCardState,
                  sessionTitle: _sessionFocus,
                  targetMuscles: _targetMuscles,
                  durationMinutes: _sessionDurationMinutes,
                  estimatedCalories: _estimatedCalories,
                  onStartWorkout: _startWorkoutSession,
                  onViewPlan: _viewWorkoutDetail,
                  onCreateProgram: widget.onNavigateToCalendar,
                ),

                const SizedBox(height: 22),

                // 4. This Week Progress (Kalender 7 Hari, 5 Status - Mockup 1:1)
                WeeklyProgressCalendarCard(
                  days: _weeklyDays,
                  onSeeDetails: () {
                    if (widget.onNavigateToProgress != null) {
                      widget.onNavigateToProgress!();
                    } else {
                      widget.onNavigateToCalendar();
                    }
                  },
                ),

                const SizedBox(height: 22),

                // 5. Support Your Goal - Panduan Nutrisi (Mockup 1:1)
                SupportGoalNutritionCard(
                  userGoal: profile?.goal ?? 'muscle_gain',
                  onTap: widget.onNavigateToNutrition,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
