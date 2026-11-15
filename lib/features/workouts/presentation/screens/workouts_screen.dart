import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/dynamic_program_entity.dart';
import '../../../../core/database/models/user_profile_entity.dart';
import '../../../../core/database/models/workout_session_entity.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/app_data_sync.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../i18n/strings.g.dart';
import '../../../exercises/data/datasources/exercise_local_datasource.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../../program/domain/models/program_lifecycle.dart';
import '../../../program/domain/services/program_lifecycle_calculator.dart';
import '../../../program/domain/services/program_week_schedule.dart';
import '../../domain/models/exercise_muscle_filter.dart';
import '../../domain/models/workouts_snapshot.dart';
import '../../domain/services/week_progress_calculator.dart';
import '../widgets/weekly_schedule_selector.dart';

/// Loader yang bisa diganti saat widget test (tanpa menyentuh SQLite).
typedef WorkoutsDataLoader = Future<WorkoutsSnapshot> Function();

/// Halaman Workouts Utama Sesuai Mockup Referensi (Design System 1:1)
class WorkoutsScreen extends StatefulWidget {
  final WorkoutsDataLoader? dataLoader;

  const WorkoutsScreen({super.key, this.dataLoader});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen>
    with WidgetsBindingObserver {
  final _db = AppDatabase.instance;
  late final ExerciseLocalDatasource _exerciseDatasource;

  bool _isLoading = true;
  Object? _loadError;
  DateTime? _loadedDate;
  Timer? _midnightTimer;

  /// Latest-request-wins: refresh dari lifecycle, AppDataSync, timer, dan
  /// pull-to-refresh bisa selesai tidak berurutan.
  int _loadRequestId = 0;
  bool _refreshErrorShown = false;

  int _selectedTabIndex = 0; // 0: My Program, 1: All Workouts
  ExerciseMuscleFilter _selectedMuscleFilter = ExerciseMuscleFilter.all;
  String _searchQuery = '';
  bool _isSearchActive = false;

  UserProfileEntity? _profile;
  TrainingProgramEntity? _activeProgram;
  List<ProgramSessionEntity> _programSessions = [];
  List<WorkoutSessionEntity> _programWorkoutHistory = [];
  List<Exercise> _allExercises = [];
  WorkoutSessionEntity? _activeSession;
  int? _selectedWeek;

  @override
  void initState() {
    super.initState();
    _exerciseDatasource = ExerciseLocalDatasource(db: _db);
    WidgetsBinding.instance.addObserver(this);
    AppDataSync.instance.dataRevision.addListener(_onDataSync);
    _loadData();
    _scheduleMidnightRefresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppDataSync.instance.dataRevision.removeListener(_onDataSync);
    _midnightTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Screen lives inside StatefulShellRoute, jadi initState hanya sekali.
      _loadData();
      _scheduleMidnightRefresh();
    }
  }

  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(
      nextMidnight.difference(now) + const Duration(seconds: 1),
      () {
        if (!mounted) return;
        _loadData();
        _scheduleMidnightRefresh();
      },
    );
  }

  void _onDataSync() {
    if (mounted) _loadData();
  }

  Future<WorkoutsSnapshot> _loadFromDatabase() async {
    final profile = await _db.getUserProfile();
    final userId = profile.id.isNotEmpty ? profile.id : 'default_user';

    var program = await _db.getActiveTrainingProgram(userId);
    program ??= await _db.getActiveTrainingProgram('default_user');

    final sessions = program != null
        ? await _db.getProgramSessions(program.id)
        : <ProgramSessionEntity>[];
    final workoutHistory = program != null
        ? await _db.getWorkoutSessionsForProgram(program.id)
        : <WorkoutSessionEntity>[];
    final activeSession = await _db.getActiveSession();
    final exercises = await _exerciseDatasource.loadExercises();

    return WorkoutsSnapshot(
      profile: profile,
      program: program,
      sessions: sessions,
      history: workoutHistory,
      exercises: exercises,
      activeSession: activeSession,
    );
  }

  Future<void> _loadData({bool showLoading = false}) async {
    final requestId = ++_loadRequestId;

    if (showLoading && mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      final snapshot = await (widget.dataLoader ?? _loadFromDatabase)();
      // Abaikan hasil request lama yang selesai setelah request yang lebih baru.
      if (!mounted || requestId != _loadRequestId) return;

      final today = ProgramWeekSchedule.dateOnly(DateTime.now());
      final dateChanged =
          _loadedDate == null || !_isSameDate(_loadedDate!, today);
      final programChanged = _activeProgram?.id != snapshot.program?.id;

      setState(() {
        // Jangan pertahankan pilihan minggu lama ketika tanggal/program
        // berganti; biarkan layar kembali mengikuti current week.
        if (dateChanged || programChanged) _selectedWeek = null;

        _profile = snapshot.profile;
        _activeProgram = snapshot.program;
        _programSessions = snapshot.sessions;
        _programWorkoutHistory = snapshot.history;
        _allExercises = snapshot.exercises;
        _activeSession = snapshot.activeSession;
        _isLoading = false;
        _loadError = null;
        _refreshErrorShown = false;
        _loadedDate = today;
      });
    } catch (error) {
      debugPrint('[WorkoutsScreen] Error loading data: $error');
      if (!mounted || requestId != _loadRequestId) return;

      setState(() {
        _isLoading = false;
        _loadError = error;
      });

      // Refresh gagal padahal data lama masih ada: beri tahu user tanpa
      // menghapus tampilan yang sudah ter-load.
      final hasCachedData =
          _activeProgram != null || _allExercises.isNotEmpty;
      if (hasCachedData && !_refreshErrorShown) {
        _refreshErrorShown = true;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                Translations.of(context).workouts.errorState.refreshFailed,
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    }
  }

  bool get _isAllWorkoutsTab => _selectedTabIndex == 1;

  List<Exercise> get _filteredExercises {
    var list = _allExercises
        .where((exercise) => _selectedMuscleFilter.matches(exercise))
        .toList();

    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return list;

    list = list.where((exercise) {
      final haystack = <String>[
        exercise.name.id,
        exercise.name.en,
        for (final muscle in exercise.primaryMuscles) ...[
          muscle.id,
          muscle.en,
        ],
        exercise.category.localizedName('id'),
        exercise.category.localizedName('en'),
      ].join(' ').toLowerCase();

      return haystack.contains(query);
    }).toList();

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header: Workouts + Search + Filter
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 10),
              child: Row(
                children: [
                  Text(
                    t.workouts.title,
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                      color: const Color(0xFF141718),
                      letterSpacing: -0.6,
                    ),
                  ),
                  const Spacer(),
                  // Search & filter hanya relevan untuk All Workouts.
                  if (_isAllWorkoutsTab) ...[
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isSearchActive = !_isSearchActive;
                          _searchQuery = '';
                        });
                      },
                      icon: Icon(
                        _isSearchActive
                            ? Icons.close_rounded
                            : Icons.search_rounded,
                        color: const Color(0xFF141718),
                        size: 24,
                      ),
                    ),
                    IconButton(
                      tooltip: t.workouts.filter.title,
                      onPressed: () => _showFilterSheet(t),
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(
                            Icons.tune_rounded,
                            color: Color(0xFF141718),
                            size: 24,
                          ),
                          // Penanda filter otot sedang aktif.
                          if (_selectedMuscleFilter != ExerciseMuscleFilter.all)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFF9FAFB),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Search Bar (hanya di All Workouts)
            if (_isAllWorkoutsTab && _isSearchActive)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: TextField(
                  autofocus: true,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: t.workouts.searchHint,
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF9CA3AF),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

            // 2. Pill Toggle: [ My Program ] | [ All Workouts ]
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildPillTab(
                        title: t.workouts.tabs.myProgram,
                        isSelected: _selectedTabIndex == 0,
                        onTap: () => setState(() {
                          _selectedTabIndex = 0;
                          _isSearchActive = false;
                          _searchQuery = '';
                        }),
                      ),
                    ),
                    Expanded(
                      child: _buildPillTab(
                        title: t.workouts.tabs.allWorkouts,
                        isSelected: _selectedTabIndex == 1,
                        onTap: () => setState(() => _selectedTabIndex = 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 3. Tab Body
            Expanded(child: _buildBody(t)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(Translations t) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // Kegagalan database tidak boleh terlihat seperti "belum punya program".
    if (_loadError != null && _activeProgram == null && _allExercises.isEmpty) {
      return _buildErrorState(t);
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        child: _selectedTabIndex == 0
            ? _buildMyProgramTab(t)
            : _buildAllWorkoutsTab(t),
      ),
    );
  }

  Widget _buildPillTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            title,
            style: AppTypography.titleSmall.copyWith(
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 13.5,
              color: isSelected
                  ? const Color(0xFF141718)
                  : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMyProgramTab(Translations t) {
    final program = _activeProgram;
    if (program == null) {
      return _buildProgramEmptyState(t);
    }

    final configuredWeeks = _profile?.targetTimeframeWeeks ?? 0;
    final totalWeeks = configuredWeeks > 0
        ? configuredWeeks
        : (program.durationWeeks > 0 ? program.durationWeeks : 8);
    final today = ProgramWeekSchedule.dateOnly(DateTime.now());

    // Hitung dulu progres per minggu untuk mendapatkan total sesi program,
    // lalu tentukan lifecycle. currentWeek saja tidak cukup karena nilainya
    // selalu di-clamp dan membuat program yang sudah lewat tampak aktif.
    final progressWithActiveLifecycle = WeekProgressCalculator.calculate(
      programStartDate: program.startDate,
      totalWeeks: totalWeeks,
      currentWeek: ProgramWeekSchedule.currentWeek(
        programStartDate: program.startDate,
        today: today,
        totalWeeks: totalWeeks,
      ),
      availableDays: _profile?.availableDays ?? const [],
      sessions: _programSessions,
      history: _programWorkoutHistory,
    );

    final totalProgramSessions = progressWithActiveLifecycle.fold<int>(
      0,
      (sum, item) => sum + item.totalSessions,
    );
    final completedProgramSessions = progressWithActiveLifecycle.fold<int>(
      0,
      (sum, item) => sum + item.completedSessions,
    );

    final lifecycle = ProgramLifecycleCalculator.resolve(
      programStartDate: program.startDate,
      totalWeeks: totalWeeks,
      today: today,
      storedStatus: program.status,
      completedSessions: completedProgramSessions,
      totalSessions: totalProgramSessions,
    );
    final currentWeek = lifecycle.currentWeek;

    final weekProgress = lifecycle.state == ProgramLifecycle.active
        ? progressWithActiveLifecycle
        : WeekProgressCalculator.calculate(
            programStartDate: program.startDate,
            totalWeeks: totalWeeks,
            currentWeek: currentWeek,
            availableDays: _profile?.availableDays ?? const [],
            sessions: _programSessions,
            history: _programWorkoutHistory,
            lifecycle: lifecycle.state,
          );

    final selectedWeek = (_selectedWeek ?? currentWeek)
        .clamp(1, totalWeeks)
        .toInt();

    final weeklySessions = ProgramWeekSchedule.build(
      programStartDate: program.startDate,
      weekNumber: selectedWeek,
      availableDays: _profile?.availableDays ?? const [],
      sessions: _programSessions,
    );

    final progressByWeek = {
      for (final item in weekProgress) item.weekNumber: item,
    };
    final selectedProgress = progressByWeek[selectedWeek];
    final completedThisWeek = selectedProgress?.completedSessions ?? 0;

    // Hitung unik per program-day + tanggal supaya record duplikat tidak
    // menggelembungkan persentase.
    final progressPercent = lifecycle.completionRate;
    final percentInt = (progressPercent * 100).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A. Active Program
          Text(
            t.workouts.activeProgram.title,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 16.5,
              color: const Color(0xFF141718),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () =>
                context.push(AppRoutes.programDetail, extra: program.id),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            'assets/images/coach_hero.png',
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.fitness_center_rounded,
                              color: AppColors.primary,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              program.name,
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 15.5,
                                color: const Color(0xFF141718),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              t.workouts.activeProgram.weeksHomeWorkout(
                                weeks: totalWeeks,
                              ),
                              style: AppTypography.bodySmall.copyWith(
                                color: const Color(0xFF6B7280),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF9CA3AF),
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _programLifecycleLabel(t, lifecycle),
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 12,
                            color: _programLifecycleColor(lifecycle.state),
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '$percentInt%',
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progressPercent,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // B. Selected program week
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.workouts.weeklySchedule.title,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 16.5,
                  color: const Color(0xFF141718),
                ),
              ),
              Text(
                t.workouts.weeklySchedule.workoutCount(
                  completed: completedThisWeek,
                  total: weeklySessions.length,
                ),
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFF6B7280),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          WeeklyScheduleSelector(
            selectedWeek: selectedWeek,
            currentWeek: currentWeek,
            totalWeeks: totalWeeks,
            weekProgress: progressByWeek,
            onWeekSelected: (week) => setState(() => _selectedWeek = week),
          ),

          if (selectedWeek > currentWeek ||
              lifecycle.state == ProgramLifecycle.notStarted) ...[
            const SizedBox(height: 14),
            _buildWeekPreviewNotice(t),
          ],

          const SizedBox(height: 16),

          if (weeklySessions.isEmpty)
            _buildNoScheduledWorkouts(t)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: weeklySessions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final scheduled = weeklySessions[index];
                final session = scheduled.session;
                final record = _findWorkoutRecord(scheduled);
                final activeSession = _activeSession;
                final isCompleted =
                    record?.status == WorkoutSessionStatus.completed;
                final isToday = _isSameDate(scheduled.scheduledDate, today);
                final isCurrentSelectedWeek = selectedWeek == currentWeek;
                final isInProgress =
                    activeSession != null &&
                    // Wajib: tanpa ini, sesi program lama bisa
                    // dianggap milik program baru yang kebetulan punya
                    // Day dan tanggal yang sama.
                    activeSession.programId == program.id &&
                    activeSession.programDayId == session.dayNumber &&
                    _isSameDate(
                      activeSession.scheduledDate,
                      scheduled.scheduledDate,
                    );
                // Hanya sesi hari ini pada program yang masih berjalan yang
                // boleh dimulai. Pratinjau/riwayat dibuka read-only.
                final isActiveToday =
                    lifecycle.canStartWorkout &&
                    isCurrentSelectedWeek &&
                    isToday &&
                    !isCompleted &&
                    !isInProgress;
                final isMissed =
                    !isCompleted &&
                    !isInProgress &&
                    scheduled.scheduledDate.isBefore(today);
                final isReadOnly = !(isActiveToday || isInProgress);

                final title = session.focusLabel.isNotEmpty
                    ? session.focusLabel
                    : session.name;
                final duration = session.targetDurationMinutes > 0
                    ? session.targetDurationMinutes
                    : 30;
                final dateText = MaterialLocalizations.of(
                  context,
                ).formatMediumDate(scheduled.scheduledDate);

                return _buildWorkoutSessionCard(
                  t: t,
                  dayNumber: session.dayNumber,
                  dateText: dateText,
                  title: title,
                  durationMinutes: duration,
                  isCompleted: isCompleted,
                  isInProgress: isInProgress,
                  isActiveToday: isActiveToday,
                  isMissed: isMissed,
                  onTap: () {
                    context.push(
                      AppRoutes.workoutDetail,
                      extra: WorkoutDetailArgs(
                        dayNumber: session.dayNumber,
                        weekNumber: selectedWeek,
                        programId: program.id,
                        weekDayText:
                            'Week $selectedWeek • Day ${session.dayNumber}',
                        workoutTitle: title,
                        targetMusclesText: session.focusLabel,
                        durationText: '$duration min',
                        levelText: _profile?.experienceLevel ?? 'Beginner',
                        scheduledDate: scheduled.scheduledDate,
                        readOnly: isReadOnly,
                        activeSessionId: isInProgress
                            ? activeSession.id
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  String _programLifecycleLabel(Translations t, ProgramLifecycleInfo lifecycle) {
    switch (lifecycle.state) {
      case ProgramLifecycle.notStarted:
        final date = MaterialLocalizations.of(
          context,
        ).formatMediumDate(lifecycle.startDate);
        return t.workouts.activeProgram.status.notStarted(date: date);
      case ProgramLifecycle.completed:
        return t.workouts.activeProgram.status.completed;
      case ProgramLifecycle.expired:
        return t.workouts.activeProgram.status.expired;
      case ProgramLifecycle.active:
        return t.workouts.activeProgram.weekOf(
          current: lifecycle.currentWeek,
          total: lifecycle.totalWeeks,
        );
    }
  }

  Color _programLifecycleColor(ProgramLifecycle state) {
    switch (state) {
      case ProgramLifecycle.notStarted:
        return const Color(0xFF6B7280);
      case ProgramLifecycle.active:
        return const Color(0xFF6B7280);
      case ProgramLifecycle.completed:
        return const Color(0xFF15803D);
      case ProgramLifecycle.expired:
        return const Color(0xFFB45309);
    }
  }

  WorkoutSessionEntity? _findWorkoutRecord(ProgramWeekSession scheduled) {
    final targetDate = ProgramWeekSchedule.dateOnly(scheduled.scheduledDate);
    final matchingRecords = _programWorkoutHistory.where((record) {
      return record.programDayId == scheduled.session.dayNumber &&
          _isSameDate(record.scheduledDate, targetDate);
    }).toList();

    for (final record in matchingRecords.reversed) {
      if (record.status == WorkoutSessionStatus.completed) return record;
    }
    return matchingRecords.isNotEmpty ? matchingRecords.last : null;
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  Widget _buildWeekPreviewNotice(Translations t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.visibility_rounded,
            size: 18,
            color: Color(0xFFB45309),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.workouts.weeklySchedule.previewTitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t.workouts.weeklySchedule.previewNotice,
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.35,
                    color: Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramEmptyState(Translations t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.fitness_center_rounded,
              size: 42,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 12),
            Text(
              t.workouts.emptyState.noProgramTitle,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF141718),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              t.workouts.emptyState.noProgramSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoScheduledWorkouts(Translations t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        t.workouts.weeklySchedule.empty,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12.5),
      ),
    );
  }

  Widget _buildWorkoutSessionCard({
    required Translations t,
    required int dayNumber,
    required String dateText,
    required String title,
    required int durationMinutes,
    required bool isCompleted,
    required bool isInProgress,
    required bool isActiveToday,
    required bool isMissed,
    required VoidCallback? onTap,
  }) {
    // Sesi yang belum waktunya dimulai bukan "terkunci": user tetap bisa
    // melihat rencananya, hanya belum bisa memulai. Jadi pakai "Terjadwal".
    final statusText = isCompleted
        ? t.workouts.session.status.completed
        : isInProgress
        ? t.workouts.session.status.inProgress
        : isActiveToday
        ? t.workouts.session.status.readyToStart
        : isMissed
        ? t.workouts.session.status.missed
        : t.workouts.session.status.scheduled;

    final isHighlighted = isInProgress || isActiveToday;

    final statusColor = isCompleted
        ? const Color(0xFF16A34A)
        : isInProgress
        ? const Color(0xFFB45309)
        : isActiveToday
        ? const Color(0xFF65A30D)
        : const Color(0xFF9CA3AF);

    final leadingIcon = isCompleted
        ? Icons.check_circle_rounded
        : isInProgress
        ? Icons.play_circle_fill_rounded
        : isActiveToday
        ? Icons.play_arrow_rounded
        : isMissed
        ? Icons.event_busy_rounded
        : Icons.calendar_today_rounded;

    final trailingIcon = isCompleted
        ? Icons.check_circle_rounded
        : isInProgress
        ? Icons.play_circle_fill_rounded
        : isActiveToday
        ? Icons.play_arrow_rounded
        : isMissed
        ? Icons.event_busy_rounded
        : Icons.calendar_today_rounded;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isHighlighted ? AppColors.primary : const Color(0xFFE5E7EB),
            width: isHighlighted ? 1.5 : 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x04000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFFF0FDF4)
                    : (isHighlighted
                          ? const Color(0xFFF9FED8)
                          : const Color(0xFFF3F4F6)),
                shape: BoxShape.circle,
              ),
              child: Icon(leadingIcon, size: 20, color: statusColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.workouts.session.date(n: dayNumber, date: dateText),
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: const Color(0xFF141718),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${t.workouts.session.min(min: durationMinutes)} • $statusText',
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(trailingIcon, color: statusColor, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildAllWorkoutsTab(Translations t) {
    final langCode = LocaleSettings.currentLocale.languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal Muscle Category Chips
        SizedBox(
          height: 38,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: ExerciseMuscleFilter.values.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = ExerciseMuscleFilter.values[index];
              final isSel = filter == _selectedMuscleFilter;

              return GestureDetector(
                onTap: () => setState(() => _selectedMuscleFilter = filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.primary : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      _getCategoryLabel(t, filter),
                      style: TextStyle(
                        fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 13,
                        color: isSel
                            ? const Color(0xFF141718)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // List Latihan
        if (_filteredExercises.isEmpty)
          _buildExerciseEmptyState(t)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _filteredExercises.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return _buildExerciseCard(
                _filteredExercises[index],
                langCode,
              );
            },
          ),
      ],
    );
  }

  Widget _buildExerciseCard(Exercise exercise, String langCode) {
    final localizedName = exercise.name.get(langCode);
    final name = localizedName.trim().isNotEmpty
        ? localizedName
        : exercise.name.id;

    final primaryMuscle = exercise.primaryMuscles.isNotEmpty
        ? exercise.primaryMuscles.first.get(langCode)
        : exercise.category.localizedName(langCode);
    final difficulty = exercise.difficulty.localizedName(langCode);

    final thumb = exercise.media.startPose.isNotEmpty
        ? exercise.media.startPose
        : exercise.media.endPose;

    return InkWell(
      onTap: () => context.push(AppRoutes.exerciseDetail, extra: exercise),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: thumb.isNotEmpty
                    ? Image.asset(
                        thumb,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.fitness_center_rounded,
                          color: Color(0xFF65A30D),
                          size: 26,
                        ),
                      )
                    : const Icon(
                        Icons.fitness_center_rounded,
                        color: Color(0xFF65A30D),
                        size: 26,
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      color: const Color(0xFF141718),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$primaryMuscle • $difficulty',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9CA3AF),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseEmptyState(Translations t) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 40,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 12),
          Text(
            t.workouts.allWorkouts.emptyTitle,
            textAlign: TextAlign.center,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: const Color(0xFF141718),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            t.workouts.allWorkouts.emptySubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12.5),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _clearFilters,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF3F6212),
            ),
            child: Text(
              t.workouts.allWorkouts.clearFilters,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Translations t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 44,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 12),
            Text(
              t.workouts.errorState.title,
              textAlign: TextAlign.center,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF141718),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              t.workouts.errorState.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12.5),
            ),
            const SizedBox(height: 16),
            AppButton.primary(
              text: t.workouts.errorState.retry,
              isFullWidth: false,
              width: 150,
              onPressed: () => _loadData(showLoading: true),
            ),
          ],
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _isSearchActive = false;
      _selectedMuscleFilter = ExerciseMuscleFilter.all;
    });
  }

  String _getCategoryLabel(Translations t, ExerciseMuscleFilter filter) {
    switch (filter) {
      case ExerciseMuscleFilter.all:
        return t.workouts.categories.all;
      case ExerciseMuscleFilter.chest:
        return t.workouts.categories.chest;
      case ExerciseMuscleFilter.back:
        return t.workouts.categories.back;
      case ExerciseMuscleFilter.legs:
        return t.workouts.categories.legs;
      case ExerciseMuscleFilter.core:
        return t.workouts.categories.core;
      case ExerciseMuscleFilter.arms:
        return t.workouts.categories.arms;
      case ExerciseMuscleFilter.shoulders:
        return t.workouts.categories.shoulders;
    }
  }

  void _showFilterSheet(Translations t) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  t.workouts.filter.title,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: const Color(0xFF141718),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: ExerciseMuscleFilter.values.map((filter) {
                    final isSel = filter == _selectedMuscleFilter;
                    return ChoiceChip(
                      label: Text(_getCategoryLabel(t, filter)),
                      selected: isSel,
                      selectedColor: AppColors.primary,
                      backgroundColor: const Color(0xFFF3F4F6),
                      labelStyle: TextStyle(
                        color: const Color(0xFF141718),
                        fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                      ),
                      onSelected: (_) {
                        setState(() => _selectedMuscleFilter = filter);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
