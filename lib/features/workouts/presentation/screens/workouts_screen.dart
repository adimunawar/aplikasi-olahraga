import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/dynamic_program_entity.dart';
import '../../../../core/database/models/user_profile_entity.dart';
import '../../../../core/database/models/workout_session_entity.dart';
import '../../../../core/services/app_data_sync.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';
import '../../../exercises/data/datasources/exercise_local_datasource.dart';
import '../../../exercises/data/repositories/exercise_repository_impl.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../../program/domain/services/program_week_schedule.dart';
import '../../domain/models/exercise_muscle_filter.dart';
import '../../domain/models/workouts_snapshot.dart';
import '../widgets/workouts_widgets.dart';

/// Loader yang bisa diganti saat widget test (tanpa menyentuh SQLite).
typedef WorkoutsDataLoader = Future<WorkoutsSnapshot> Function();

/// Halaman Workouts Utama (Pure Composition, < 180 lines, Full Theme Support)
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
  late final ExerciseRepositoryImpl _exerciseRepository;

  bool _isLoading = true;
  Object? _loadError;
  DateTime? _loadedDate;
  Timer? _midnightTimer;

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
    _exerciseRepository = ExerciseRepositoryImpl(_exerciseDatasource);
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
    final exercises = await _exerciseRepository.getExercises();

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
      if (!mounted || requestId != _loadRequestId) return;

      final today = ProgramWeekSchedule.dateOnly(DateTime.now());
      final dateChanged =
          _loadedDate == null || !_isSameDate(_loadedDate!, today);
      final programChanged = _activeProgram?.id != snapshot.program?.id;

      setState(() {
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

      final hasCachedData = _activeProgram != null || _allExercises.isNotEmpty;
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

    return list.where((exercise) {
      final haystack = <String>[
        exercise.name.id,
        exercise.name.en,
        for (final muscle in exercise.primaryMuscles) ...[muscle.id, muscle.en],
        exercise.category.localizedName('id'),
        exercise.category.localizedName('en'),
      ].join(' ').toLowerCase();

      return haystack.contains(query);
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _isSearchActive = false;
      _selectedMuscleFilter = ExerciseMuscleFilter.all;
    });
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          t.workouts.title,
          style: AppTypography.headlineLarge.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.7,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          if (_isAllWorkoutsTab)
            WorkoutsAppBarActions(
              isSearchActive: _isSearchActive,
              selectedMuscleFilter: _selectedMuscleFilter,
              onToggleSearch: () {
                setState(() {
                  _isSearchActive = !_isSearchActive;
                  _searchQuery = '';
                });
              },
              onOpenFilter: () {
                showMuscleFilterSheet(
                  context: context,
                  currentFilter: _selectedMuscleFilter,
                  onFilterSelected: (filter) =>
                      setState(() => _selectedMuscleFilter = filter),
                );
              },
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: WorkoutsPillToggle(
              selectedTabIndex: _selectedTabIndex,
              onTabChanged: (index) {
                setState(() {
                  _selectedTabIndex = index;
                  if (index == 0) {
                    _isSearchActive = false;
                    _searchQuery = '';
                  }
                });
              },
              myProgramTitle: t.workouts.tabs.myProgram,
              allWorkoutsTitle: t.workouts.tabs.allWorkouts,
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (_isAllWorkoutsTab && _isSearchActive)
              WorkoutsSearchBar(
                onSearchChanged: (val) => setState(() => _searchQuery = val),
              ),
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

    if (_loadError != null && _activeProgram == null && _allExercises.isEmpty) {
      return WorkoutsErrorState(onRetry: () => _loadData(showLoading: true));
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 12, bottom: 32),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.topCenter,
              children: [...previousChildren, ?currentChild],
            );
          },
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: KeyedSubtree(
            key: ValueKey(_selectedTabIndex),
            child: _selectedTabIndex == 0
                ? WorkoutsMyProgramTab(
                    activeProgram: _activeProgram,
                    profile: _profile,
                    programSessions: _programSessions,
                    programWorkoutHistory: _programWorkoutHistory,
                    activeSession: _activeSession,
                    selectedWeek: _selectedWeek,
                    onWeekSelected: (week) =>
                        setState(() => _selectedWeek = week),
                  )
                : WorkoutsAllWorkoutsTab(
                    exercises: _filteredExercises,
                    selectedMuscleFilter: _selectedMuscleFilter,
                    onMuscleFilterSelected: (filter) =>
                        setState(() => _selectedMuscleFilter = filter),
                    onClearFilters: _clearFilters,
                  ),
          ),
        ),
      ),
    );
  }
}
