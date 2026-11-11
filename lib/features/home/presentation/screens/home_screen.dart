import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_app/core/database/models/workout_session_entity.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/dynamic_program_entity.dart';
import '../../../../core/database/models/user_profile_entity.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/app_data_sync.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../../exercises/data/datasources/exercise_local_datasource.dart';
import '../../../exercises/data/repositories/exercise_repository_impl.dart';
import '../../../program/domain/models/program_day.dart';
import '../../../program/domain/services/dynamic_program_generator.dart';
import '../../../program/data/datasources/program_local_datasource.dart';
import '../../../program/data/repositories/program_repository_impl.dart';

import '../widgets/dark_hero_header.dart';
import '../widgets/this_weeks_progress_card.dart';
import '../widgets/todays_workout_card.dart';
import '../widgets/your_stats_section.dart';
import '../widgets/explore_programs_carousel.dart';

/// Halaman Home Utama Baru (100% Sesuai Mockup Referensi Dark Hero & Full Dinamis dari Database)
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
  final _programRepo = ProgramRepositoryImpl(ProgramLocalDatasource());
  final _exerciseRepo = ExerciseRepositoryImpl(ExerciseLocalDatasource());
  final _db = AppDatabase.instance;

  UserProfileEntity? _userProfile;
  ProgramDay? _todayProgram;
  List<Exercise> _todayExercises = [];

  int _streakDays = 0;
  int _completedThisWeek = 0;
  int _weeklyTarget = 3;
  int _progressPercent = 0;
  int _totalDurationMinutes = 0;
  bool _isCompletedToday = false;
  int _todayCompletedMinutes = 0;

  String _programTitle = 'Muscle Gain (Bulking)';
  String _nextSessionFocus = 'Upper Body Strength';
  int _nextSessionDurationMinutes = 25;
  List<WeeklyDayProgress> _weeklyDays = [];
  bool _isLoading = true;

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

  Future<void> _loadTodayData() async {
    final profile = await _db.getUserProfile();
    final streak = await _db.getCurrentStreak();
    final thisWeekCount = await _db.getThisWeekCompletedCount();
    final recentSessions = await _db.getRecentWorkoutSessions(limit: 30);

    // 1. Goal & Program Title
    String goalStr = 'Muscle Gain (Bulking)';
    final g = profile.goal.toLowerCase();
    if (g.contains('fat') || g.contains('weight_loss')) {
      goalStr = 'Fat Loss & Shred';
    } else if (g.contains('strength')) {
      goalStr = 'Build Pure Strength';
    } else if (g.contains('endurance') || g.contains('tone')) {
      goalStr = 'Tone & Lean Fit';
    }

    final targetWeekly = profile.weeklyFrequency > 0
        ? profile.weeklyFrequency
        : (profile.preferredDaysPerWeek > 0 ? profile.preferredDaysPerWeek : 3);
    final percent = targetWeekly > 0
        ? ((thisWeekCount / targetWeekly) * 100).round().clamp(0, 100)
        : 0;

    // Hitung total durasi latihan minggu ini dari sesi completed
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfMonday = DateTime(monday.year, monday.month, monday.day);
    int totalMinutes = 0;
    for (final s in recentSessions) {
      if (s.status == WorkoutSessionStatus.completed &&
          s.startedAt.isAfter(startOfMonday)) {
        totalMinutes += (s.durationSeconds / 60).round();
      }
    }

    // 2. Baca / Generate Dynamic Training Program (Fase 2)
    final userId = profile.id.isNotEmpty ? profile.id : 'default_user';
    var activeProgram = await _db.getActiveTrainingProgram(userId);
    activeProgram ??= await _db.getActiveTrainingProgram('default_user');

    List<ProgramSessionEntity> sessions = [];
    if (activeProgram != null) {
      sessions = await _db.getProgramSessions(activeProgram.id);
    }

    // Auto-heal jika program belum ada, atau sesi kosong, atau frekuensi berubah
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
        debugPrint('[HomeScreen] Auto-generate dynamic program: $e');
      }
    }

    List<Exercise> todayExercises = [];
    String sessionFocus = 'Upper Body Strength';
    int sessionDuration = 25;
    ProgramDay? programDay;

    if (activeProgram != null && sessions.isNotEmpty) {
      final nextIndex = thisWeekCount % sessions.length;
      final nextSession = sessions[nextIndex];
      sessionFocus = nextSession.focusLabel.isNotEmpty
          ? nextSession.focusLabel
          : 'Upper Body Strength';
      sessionDuration = nextSession.targetDurationMinutes > 0
          ? nextSession.targetDurationMinutes
          : 25;

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
      } else {
        workoutItems = todayExercises
            .map(
              (e) => WorkoutItem(
                exerciseId: e.id,
                sets: 3,
                reps: 10,
                restSeconds: 60,
                isMain: true,
                stage: 'main',
              ),
            )
            .toList();
      }

      programDay = ProgramDay(
        day: nextSession.dayNumber,
        week: (thisWeekCount ~/ targetWeekly) + 1,
        type: WorkoutTypeCode.f,
        focus: LocalizedString(id: sessionFocus, en: sessionFocus),
        isRest: false,
        isRetestMilestone: false,
        items: workoutItems,
      );
    }

    // Fallback jika database belum ada latihan
    if (todayExercises.isEmpty) {
      final dayNum = await _programRepo.getCurrentProgramDay();
      programDay = await _programRepo.getDay(dayNum);
      final allExercises = await _exerciseRepo.getExercises();
      final exercisesMap = {for (final e in allExercises) e.id: e};
      todayExercises =
          programDay?.items
              .map((item) => exercisesMap[item.exerciseId])
              .whereType<Exercise>()
              .toList() ??
          [];
      if (programDay != null) {
        sessionFocus = programDay.focus.id.isNotEmpty
            ? programDay.focus.id
            : 'Upper Body Strength';
      }
    }

    // 3. Kalender Mingguan 7 Hari (Mon - Sun)
    final List<WeeklyDayProgress> daysList = [];
    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      final isToday =
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;

      final isCompleted = recentSessions.any(
        (s) =>
            s.status == WorkoutSessionStatus.completed &&
            s.startedAt.year == date.year &&
            s.startedAt.month == date.month &&
            s.startedAt.day == date.day,
      );

      daysList.add(
        WeeklyDayProgress(
          dayName: _formatDayShortEn(date.weekday),
          isCompleted: isCompleted,
          isToday: isToday,
        ),
      );
    }

    bool isCompletedToday = false;
    int todayCompletedMinutes = 0;
    for (final s in recentSessions) {
      if (s.status == WorkoutSessionStatus.completed &&
          s.startedAt.year == now.year &&
          s.startedAt.month == now.month &&
          s.startedAt.day == now.day) {
        isCompletedToday = true;
        todayCompletedMinutes = (s.durationSeconds / 60).round();
        break;
      }
    }

    if (mounted) {
      setState(() {
        _userProfile = profile;
        _streakDays = streak;
        _completedThisWeek = thisWeekCount;
        _weeklyTarget = targetWeekly;
        _progressPercent = percent;
        _totalDurationMinutes = totalMinutes;
        _isCompletedToday = isCompletedToday;
        _todayCompletedMinutes = todayCompletedMinutes;
        _programTitle = activeProgram?.name.isNotEmpty == true
            ? activeProgram!.name
            : goalStr;
        _nextSessionFocus = sessionFocus;
        _nextSessionDurationMinutes = sessionDuration;
        _todayProgram = programDay;
        _todayExercises = todayExercises;
        _weeklyDays = daysList;
        _isLoading = false;
      });
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
          workoutTitle: _nextSessionFocus,
          targetMusclesText: _programTitle,
          durationText: '$_nextSessionDurationMinutes min',
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
        backgroundColor: Color(0xFF141718),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF84CC16)),
        ),
      );
    }

    final explorePrograms = const [
      ExploreProgramItem(
        id: 'upper_body_strength',
        title: 'Upper Body Strength',
        durationText: '8 Minggu',
        levelText: 'Beginner',
        imageAsset: 'assets/images/coach_crossed_arms.png',
      ),
      ExploreProgramItem(
        id: 'build_muscle',
        title: 'Build Muscle',
        durationText: '4 Minggu',
        levelText: 'Beginner',
        imageAsset: 'assets/images/coach_flex.png',
      ),
      ExploreProgramItem(
        id: 'build_strength',
        title: 'Build Strength',
        durationText: '4 Minggu',
        levelText: 'Beginner',
        imageAsset: 'assets/images/coach_hero.png',
      ),
      ExploreProgramItem(
        id: 'fat_loss',
        title: 'Fat Loss',
        durationText: '4 Minggu',
        levelText: 'Beginner',
        imageAsset: 'assets/images/coach_character.png',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // 1. Header Atas Gelap dengan Karakter Coach Adi
            Container(
              color: const Color(0xFF141718),
              child: SafeArea(
                bottom: false,
                child: DarkHeroHeader(
                  userName: _userProfile?.displayName.isNotEmpty == true
                      ? _userProfile!.displayName
                      : 'Adi',
                  programName: _programTitle,
                  onProgramTap: _viewWorkoutDetail,
                  onNotificationTap: () {},
                ),
              ),
            ),

            // 2. Konten Utama (Cards)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Card 1: This Week's Progress (Real days count, circular ring %, 7 days checklist)
                  ThisWeeksProgressCard(
                    completedDays: _completedThisWeek,
                    targetDays: _weeklyTarget,
                    progressPercent: _progressPercent,
                    days: _weeklyDays,
                  ),

                  const SizedBox(height: 16),

                  // Card 2: Today's Workout (Real dynamic session title, duration, exercises, ▶ Start Workout)
                  TodaysWorkoutCard(
                    sessionTitle: _nextSessionFocus,
                    durationMinutes: _nextSessionDurationMinutes,
                    exerciseCount: _todayExercises.isNotEmpty
                        ? _todayExercises.length
                        : 5,
                    isCompletedToday: _isCompletedToday,
                    todayCompletedMinutes: _todayCompletedMinutes,
                    onStartWorkout: _startWorkoutSession,
                    exerciseImageAsset: 'assets/images/exercises/push_up.webp',
                  ),

                  const SizedBox(height: 20),

                  // Card 3: Your Stats (Real Workouts This Week, Real Duration min, Real Day Streak)
                  YourStatsSection(
                    workoutsThisWeek: _completedThisWeek,
                    totalDurationMinutes: _totalDurationMinutes,
                    dayStreak: _streakDays,
                    onViewProgress:
                        widget.onNavigateToProgress ??
                        widget.onNavigateToCalendar,
                  ),

                  const SizedBox(height: 22),

                  // Card 4: Bagian "Jelajahi Program" yang disukai user (Lihat Semua >)
                  ExploreProgramsCarousel(
                    programs: explorePrograms,
                    onSeeAll: widget.onNavigateToExercises,
                    onProgramTap: (item) {
                      context.push(AppRoutes.programDetail, extra: item.id);
                    },
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
