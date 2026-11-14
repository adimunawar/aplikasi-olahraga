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

final homeControllerProvider =
    StateNotifierProvider<HomeController, HomeState>((ref) {
  final controller = HomeController(
    db: ref.watch(homeDatabaseProvider),
    exerciseDatasource: ref.watch(homeExerciseDatasourceProvider),
    programGenerator: ref.watch(homeProgramGeneratorProvider),
    appDataSync: AppDataSync.instance,
  );
  ref.onDispose(() => controller.dispose());
  return controller;
});

/// Riverpod Controller untuk Orkestrasi State & Logika Bisnis Home Screen
class HomeController extends StateNotifier<HomeState> {
  final AppDatabase _db;
  final ExerciseLocalDatasource _exerciseDatasource;
  final DynamicProgramGenerator _programGenerator;
  final AppDataSync _appDataSync;

  int _lastKnownRevision = -1;

  HomeController({
    required this._db,
    required this._exerciseDatasource,
    required this._programGenerator,
    required this._appDataSync,
  })  : super(const HomeState()) {
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
    final startDay = DateTime(startDate.year, startDate.month, startDate.day);
    final currentDay =
        DateTime(targetDate.year, targetDate.month, targetDate.day);

    if (currentDay.isBefore(startDay)) {
      return 1;
    }

    final daysElapsed = currentDay.difference(startDay).inDays;
    final weekNumber = (daysElapsed ~/ 7) + 1;
    return weekNumber.clamp(1, totalWeeks > 0 ? totalWeeks : 12);
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

  /// Memuat data Home secara optimal.
  /// Menghindari query berulang saat tab switch jika data belum basi/berubah.
  Future<void> loadHomeData({bool forceReload = false}) async {
    final now = DateTime.now();

    // Optimasi Reload: jika tidak dipaksa reload dan data masih mutakhir di hari yang sama, gunakan cache
    if (!forceReload &&
        state.lastLoadedAt != null &&
        state.userProfile != null &&
        now.day == state.lastLoadedAt!.day &&
        now.difference(state.lastLoadedAt!).inMinutes < 15 &&
        _appDataSync.dataRevision.value == _lastKnownRevision) {
      return;
    }

    // Set loading hanya jika sebelumnya belum ada data sama sekali
    if (state.userProfile == null) {
      state = state.copyWith(isLoading: true, errorType: HomeErrorType.none);
    }

    try {
      // 1. Ambil Profil & Data Workout dari Database Lokal
      final profile = await _db.getUserProfile();
      final thisWeekCount = await _db.getThisWeekCompletedCount();
      final recentSessions = await _db.getRecentWorkoutSessions(limit: 30);

      final monday = now.subtract(Duration(days: now.weekday - 1));

      // Format Goal
      String goalLabel = 'Gain Weight & Build Muscle';
      final g = profile.goal.toLowerCase();
      if (g.contains('fat') || g.contains('weight_loss') || g.contains('cut')) {
        goalLabel = 'Fat Loss & Conditioning';
      } else if (g.contains('maintain') || g.contains('fit')) {
        goalLabel = 'Maintain & Stay Fit';
      }

      final targetWeekly = profile.weeklyFrequency > 0
          ? profile.weeklyFrequency
          : (profile.preferredDaysPerWeek > 0
              ? profile.preferredDaysPerWeek
              : 3);

      // 2. Program Latihan Aktif
      final userId = profile.id.isNotEmpty ? profile.id : 'default_user';
      var activeProgram = await _db.getActiveTrainingProgram(userId);
      activeProgram ??= await _db.getActiveTrainingProgram('default_user');

      List<ProgramSessionEntity> sessions = [];
      if (activeProgram != null) {
        sessions = await _db.getProgramSessions(activeProgram.id);
      }

      // Auto-heal / Generate Dynamic Program jika belum ada
      if (activeProgram == null ||
          sessions.isEmpty ||
          sessions.length != targetWeekly) {
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

      // 3. Perhitungan Minggu Program Presisi (Berdasarkan startDate, bukan hitungan sesi)
      final totalWeeks = profile.targetTimeframeWeeks > 0
          ? profile.targetTimeframeWeeks
          : 12;
      final programStartDate = activeProgram?.startDate ?? profile.createdAt;
      final currentWeek = calculateProgramWeek(
        startDate: programStartDate,
        targetDate: now,
        totalWeeks: totalWeeks,
      );

      // 4. Deteksi Sesi Hari Ini
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
          week: currentWeek, // Menggunakan perhitungan kalender yang presisi
          type: WorkoutTypeCode.f,
          focus: LocalizedString(id: focusLabel, en: focusLabel),
          isRest: false,
          isRetestMilestone: false,
          items: workoutItems,
        );
      }

      // 5. Cek Status Selesai Hari Ini
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

      final isRestDay = !isScheduledTrainingDay && !isCompletedToday;

      // 6. Data 7 Hari Mingguan dengan 5 Status Presisi
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

        DayActivityState dayState;
        if (isCompleted) {
          dayState = DayActivityState.completed;
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
              : (isRestDay
                  ? WorkoutCardState.restDay
                  : WorkoutCardState.active);

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
        sessionDurationMinutes: sessionDuration,
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
  }

  /// Memaksa refresh data saat pull-to-refresh
  Future<void> refresh() async {
    await loadHomeData(forceReload: true);
  }
}
