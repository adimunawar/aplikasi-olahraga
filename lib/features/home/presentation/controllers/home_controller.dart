import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/dynamic_program_entity.dart';
import '../../../../core/database/models/workout_session_entity.dart';
import '../../../../core/services/app_data_sync.dart';
import '../../../exercises/data/datasources/exercise_local_datasource.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../../program/domain/models/program_day.dart';
import '../../../program/domain/services/dynamic_program_generator.dart';
import '../../../program/domain/services/program_week_schedule.dart';
import '../widgets/today_workout/today_workout_section.dart';
import '../widgets/weekly_progress_calendar_card.dart';
import 'home_state.dart';

final homeDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final homeExerciseDatasourceProvider = Provider<ExerciseLocalDatasource>((ref) {
  return ExerciseLocalDatasource(db: ref.watch(homeDatabaseProvider));
});

final homeProgramGeneratorProvider = Provider<DynamicProgramGenerator>((ref) {
  return const DynamicProgramGenerator();
});

final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>(
  (ref) {
    final controller = HomeController(
      db: ref.watch(homeDatabaseProvider),
      exerciseDatasource: ref.watch(homeExerciseDatasourceProvider),
      programGenerator: ref.watch(homeProgramGeneratorProvider),
      appDataSync: AppDataSync.instance,
    );
    ref.onDispose(() => controller.dispose());
    return controller;
  },
);

/// Riverpod Controller untuk Orkestrasi State & Logika Bisnis Home Screen
class HomeController extends StateNotifier<HomeState> {
  final AppDatabase _db;
  final ExerciseLocalDatasource _exerciseDatasource;
  final DynamicProgramGenerator _programGenerator;
  final AppDataSync _appDataSync;

  int _lastKnownRevision = -1;
  bool _isLoadingHomeData = false;
  bool _reloadRequested = false;

  HomeController({
    required this._db,
    required this._exerciseDatasource,
    required this._programGenerator,
    required this._appDataSync,
  }) : super(const HomeState()) {
    _init();
  }

  void _init() {
    _lastKnownRevision = _appDataSync.dataRevision.value;
    _appDataSync.dataRevision.addListener(_onDataRevisionChanged);
    loadHomeData();
  }

  @override
  void dispose() {
    _appDataSync.dataRevision.removeListener(_onDataRevisionChanged);
    super.dispose();
  }

  void _onDataRevisionChanged() {
    final currentRevision = _appDataSync.dataRevision.value;
    if (currentRevision != _lastKnownRevision) {
      _lastKnownRevision = currentRevision;
      loadHomeData(forceReload: true);
    }
  }

  /// Menghitung minggu ke-N program secara presisi berdasarkan tanggal mulai (startDate)
  static int calculateProgramWeek({
    required DateTime startDate,
    required DateTime targetDate,
    required int totalWeeks,
  }) {
    return ProgramWeekSchedule.currentWeek(
      programStartDate: startDate,
      today: targetDate,
      totalWeeks: totalWeeks,
    );
  }

  String _formatDayShortEn(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(weekday - 1).clamp(0, 6)];
  }

  /// Memuat data Home secara optimal.
  /// Menghindari query berulang saat tab switch jika data belum basi/berubah.
  Future<void> loadHomeData({bool forceReload = false}) async {
    if (_isLoadingHomeData) {
      _reloadRequested = true;
      return;
    }
    _isLoadingHomeData = true;

    try {
      final now = DateTime.now();
      final today = ProgramWeekSchedule.dateOnly(now);

      // Keep cached Home data for a short period unless the database changed.
      if (!forceReload &&
          state.lastLoadedAt != null &&
          state.userProfile != null &&
          now.day == state.lastLoadedAt!.day &&
          now.month == state.lastLoadedAt!.month &&
          now.year == state.lastLoadedAt!.year &&
          now.difference(state.lastLoadedAt!).inMinutes < 15 &&
          _appDataSync.dataRevision.value == _lastKnownRevision) {
        return;
      }

      if (state.userProfile == null) {
        state = state.copyWith(isLoading: true, errorType: HomeErrorType.none);
      }

      try {
        var profile = await _db.getUserProfile();

        String goalLabel = 'Gain Weight & Build Muscle';
        final goal = profile.goal.toLowerCase();
        if (goal.contains('fat') ||
            goal.contains('weight_loss') ||
            goal.contains('cut')) {
          goalLabel = 'Fat Loss & Conditioning';
        } else if (goal.contains('maintain') || goal.contains('fit')) {
          goalLabel = 'Maintain & Stay Fit';
        }

        final configuredFrequency = profile.weeklyFrequency > 0
            ? profile.weeklyFrequency
            : (profile.preferredDaysPerWeek > 0
                  ? profile.preferredDaysPerWeek
                  : 3);
        final targetWeekly = configuredFrequency.clamp(2, 6).toInt();
        if (profile.weeklyFrequency != targetWeekly ||
            profile.preferredDaysPerWeek != targetWeekly) {
          profile = profile.copyWith(
            weeklyFrequency: targetWeekly,
            preferredDaysPerWeek: targetWeekly,
            updatedAt: profile.updatedAt,
          );
          await _db.saveUserProfile(profile);
        }

        final userId = profile.id.isNotEmpty ? profile.id : 'default_user';
        var activeProgram = await _db.getActiveTrainingProgram(userId);
        activeProgram ??= await _db.getActiveTrainingProgram('default_user');

        var sessions = activeProgram != null
            ? await _db.getProgramSessions(activeProgram.id)
            : <ProgramSessionEntity>[];

        final needsProgramRegeneration =
            activeProgram == null ||
            sessions.isEmpty ||
            sessions.length != targetWeekly ||
            activeProgram.weeklyFrequency != targetWeekly;
        final scheduleStartDate =
            activeProgram == null ||
                activeProgram.weeklyFrequency != targetWeekly
            ? (activeProgram == null ? now : profile.updatedAt)
            : activeProgram.startDate;

        // Normalize legacy/default schedules as well as onboarding data.
        // The first available day always matches the program's start weekday.
        final alignedAvailableDays =
            ProgramWeekSchedule.availableWeekdaysForFrequency(
              startDate: scheduleStartDate,
              frequency: targetWeekly,
            );
        if (!listEquals(profile.availableDays, alignedAvailableDays)) {
          profile = profile.copyWith(
            availableDays: alignedAvailableDays,
            updatedAt: profile.updatedAt,
          );
          await _db.saveUserProfile(profile);
        }

        // Regenerate only if the active program is missing or its session
        // count/frequency no longer matches the user's profile.
        if (needsProgramRegeneration) {
          try {
            final catalog = await _exerciseDatasource.loadExercises();
            final startingPushId = profile.experienceLevel == 'advanced'
                ? 'diamond_push_up'
                : profile.experienceLevel == 'intermediate'
                ? 'push_up'
                : 'knee_push_up';

            final generated = _programGenerator.generate(
              userProfile: profile,
              catalogExercises: catalog,
              startingPushExerciseId: startingPushId,
              startDate: scheduleStartDate,
            );

            await _db.saveDynamicProgram(
              program: generated.program,
              sessions: generated.sessions,
            );
            activeProgram = generated.program;
            sessions = await _db.getProgramSessions(activeProgram.id);
          } catch (e) {
            debugPrint('[HomeController] Program generation error: $e');
            state = state.copyWith(
              errorType: HomeErrorType.programGeneration,
              errorMessage: 'Gagal membuat program latihan dinamis: $e',
            );
          }
        }

        final totalWeeks = profile.targetTimeframeWeeks > 0
            ? profile.targetTimeframeWeeks
            : 12;
        final programStartDate = activeProgram?.startDate ?? profile.updatedAt;
        final currentWeek = ProgramWeekSchedule.currentWeek(
          programStartDate: programStartDate,
          today: today,
          totalWeeks: totalWeeks,
        );

        // Resolve today's workout from the same schedule used by Workouts.
        final todayScheduled = activeProgram == null
            ? null
            : ProgramWeekSchedule.sessionForDate(
                programStartDate: programStartDate,
                date: today,
                availableDays: profile.availableDays,
                sessions: sessions,
                totalWeeks: totalWeeks,
              );

        final programWorkoutHistory = activeProgram == null
            ? <WorkoutSessionEntity>[]
            : await _db.getWorkoutSessionsForProgram(activeProgram.id);

        final todayExercises = <Exercise>[];
        var focusLabel = 'Upper Body (Push)';
        var musclesLabel = 'Chest, Shoulders, Triceps';
        final sessionDuration = profile.preferredDurationMin > 0
            ? profile.preferredDurationMin
            : 45;
        var effectiveSessionDuration = sessionDuration;
        var calories = (effectiveSessionDuration * 6.2).round();
        ProgramDay? programDay;

        if (todayScheduled != null) {
          final nextSession = todayScheduled.session;
          focusLabel = nextSession.name.isNotEmpty
              ? nextSession.name
              : 'Upper Body (Push)';
          musclesLabel = nextSession.focusLabel.isNotEmpty
              ? nextSession.focusLabel
              : 'Chest, Shoulders, Triceps';
          effectiveSessionDuration = nextSession.targetDurationMinutes > 0
              ? nextSession.targetDurationMinutes
              : sessionDuration;
          calories = (effectiveSessionDuration * 6.2).round();

          final detail = await _db.getProgramSessionDetail(nextSession.id);
          final workoutItems = <WorkoutItem>[];

          if (detail != null && detail.exercises.isNotEmpty) {
            todayExercises.addAll(
              detail.exercises.map((item) => item.exercise),
            );
            workoutItems.addAll(
              detail.exercises.map((item) {
                return WorkoutItem(
                  exerciseId: item.exercise.id,
                  sets: item.prescription.targetSets,
                  reps: item.prescription.minReps,
                  restSeconds: item.prescription.restSeconds,
                  isMain: item.prescription.stage == 'main',
                  stage: item.prescription.stage,
                );
              }),
            );
          }

          programDay = ProgramDay(
            day: nextSession.dayNumber,
            week: currentWeek,
            type: WorkoutTypeCode.f,
            focus: LocalizedString(id: focusLabel, en: focusLabel),
            isRest: false,
            isRetestMilestone: false,
            items: workoutItems,
          );
        }

        final isCompletedToday =
            todayScheduled != null &&
            programWorkoutHistory.any((session) {
              return session.programDayId == todayScheduled.session.dayNumber &&
                  session.status == WorkoutSessionStatus.completed &&
                  ProgramWeekSchedule.dateOnly(session.scheduledDate) == today;
            });

        final isScheduledTrainingDay = todayScheduled != null;
        final isRestDay = !isScheduledTrainingDay && !isCompletedToday;

        // Calendar follows the active program's weekly cycle.
        final calendarWeekStart = ProgramWeekSchedule.startDateForWeek(
          programStartDate: programStartDate,
          weekNumber: currentWeek,
        );

        // Use the same schedule engine as today's workout.
        final scheduledDates =
            ProgramWeekSchedule.build(
                  programStartDate: programStartDate,
                  weekNumber: currentWeek,
                  availableDays: profile.availableDays,
                  sessions: sessions,
                )
                .map((item) => ProgramWeekSchedule.dateOnly(item.scheduledDate))
                .toSet();

        final daysList = <DayProgressData>[];
        for (var i = 0; i < 7; i++) {
          final date = calendarWeekStart.add(Duration(days: i));
          final dateOnly = ProgramWeekSchedule.dateOnly(date);
          final isToday = dateOnly == today;
          final isPast = dateOnly.isBefore(today);

          final isCompleted = programWorkoutHistory.any(
            (session) =>
                session.status == WorkoutSessionStatus.completed &&
                ProgramWeekSchedule.dateOnly(session.scheduledDate) == dateOnly,
          );

          final daysFromProgramStart = dateOnly
              .difference(ProgramWeekSchedule.dateOnly(programStartDate))
              .inDays;
          final isInsideProgram =
              activeProgram != null &&
              daysFromProgramStart >= 0 &&
              daysFromProgramStart < totalWeeks * 7;
          final isTrainingScheduled =
              isInsideProgram && scheduledDates.contains(dateOnly);

          DayActivityState dayState;
          if (isCompleted) {
            dayState = DayActivityState.completed;
          } else if (!isInsideProgram) {
            dayState = DayActivityState.rest;
          } else if (isToday) {
            dayState = isTrainingScheduled
                ? DayActivityState.today
                : DayActivityState.rest;
          } else if (isPast) {
            dayState = isTrainingScheduled
                ? DayActivityState.missed
                : DayActivityState.rest;
          } else {
            dayState = isTrainingScheduled
                ? DayActivityState.upcoming
                : DayActivityState.rest;
          }

          daysList.add(
            DayProgressData(
              dayName: _formatDayShortEn(date.weekday),
              state: dayState,
              date: date,
              isToday: isToday,
            ),
          );
        }

        final workoutCardState = activeProgram == null
            ? WorkoutCardState.noProgram
            : isCompletedToday
            ? WorkoutCardState.completed
            : (isRestDay ? WorkoutCardState.restDay : WorkoutCardState.active);

        state = state.copyWith(
          isLoading: false,
          errorType: HomeErrorType.none,
          userProfile: profile,
          activeProgram: activeProgram,
          todayProgram: programDay,
          todayExercises: todayExercises,
          programTitle: goalLabel,
          sessionFocus: focusLabel,
          targetMuscles: musclesLabel,
          sessionDurationMinutes: effectiveSessionDuration,
          estimatedCalories: calories,
          currentWeek: currentWeek,
          totalWeeks: totalWeeks,
          weeklyDays: daysList,
          workoutCardState: workoutCardState,
          hasProgram: activeProgram != null,
          isTodayRestDay: isRestDay,
          isCompletedToday: isCompletedToday,
          lastLoadedAt: now,
        );
      } catch (e) {
        debugPrint('[HomeController] Database / load error: $e');
        state = state.copyWith(
          isLoading: false,
          errorType: HomeErrorType.database,
          errorMessage: 'Database load error: $e',
        );
      }
    } finally {
      _isLoadingHomeData = false;
      if (_reloadRequested) {
        _reloadRequested = false;
        await loadHomeData(forceReload: true);
      }
    }
  }

  /// Memaksa refresh data saat pull-to-refresh
  Future<void> refresh() async {
    await loadHomeData(forceReload: true);
  }

  /// Menandai seluruh notifikasi telah dibaca (menghilangkan badge merah)
  void markNotificationsAsRead() {
    state = state.copyWith(hasUnreadNotifications: false);
  }
}
