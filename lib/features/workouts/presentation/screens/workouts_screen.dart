import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/dynamic_program_entity.dart';
import '../../../../core/database/models/user_profile_entity.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/app_data_sync.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../exercises/data/datasources/exercise_local_datasource.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../../plans/presentation/screens/plans_screen.dart';

/// Halaman Workouts Utama Sesuai Mockup Referensi (Design System 1:1)
class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final _db = AppDatabase.instance;
  late final ExerciseLocalDatasource _exerciseDatasource;

  bool _isLoading = true;
  int _selectedTabIndex = 0; // 0: My Program, 1: All Workouts
  String _selectedMuscleFilter = 'All';
  String _searchQuery = '';
  bool _isSearchActive = false;

  UserProfileEntity? _profile;
  TrainingProgramEntity? _activeProgram;
  List<SessionWithDetail> _weekSessions = [];
  Set<int> _completedDays = {};
  List<Exercise> _allExercises = [];
  int _completedThisWeekCount = 0;

  static const List<String> _muscleCategories = [
    'All',
    'Chest',
    'Back',
    'Legs',
    'Core',
    'Arms',
    'Shoulders',
  ];

  @override
  void initState() {
    super.initState();
    _exerciseDatasource = ExerciseLocalDatasource(db: _db);
    _loadData();
    AppDataSync.instance.dataRevision.addListener(_onDataSync);
  }

  @override
  void dispose() {
    AppDataSync.instance.dataRevision.removeListener(_onDataSync);
    super.dispose();
  }

  void _onDataSync() {
    if (mounted) _loadData();
  }

  Future<void> _loadData() async {
    try {
      final profile = await _db.getUserProfile();
      final userId = profile.id.isNotEmpty ? profile.id : 'default_user';

      var program = await _db.getActiveTrainingProgram(userId);
      program ??= await _db.getActiveTrainingProgram('default_user');

      final List<SessionWithDetail> sessions = [];
      if (program != null) {
        final rawSessions = await _db.getProgramSessions(program.id);
        for (final s in rawSessions) {
          final detail = await _db.getProgramSessionDetail(s.id);
          if (detail != null) {
            sessions.add(SessionWithDetail(session: s, detail: detail));
          }
        }
      }

      final completedDays = program != null
          ? await _db.getCompletedDayNumbers(program.id)
          : <int>{};
      final thisWeekCount = await _db.getThisWeekCompletedCount();
      final exercises = await _exerciseDatasource.loadExercises();

      if (mounted) {
        setState(() {
          _profile = profile;
          _activeProgram = program;
          _weekSessions = sessions;
          _completedDays = completedDays;
          _completedThisWeekCount = thisWeekCount;
          _allExercises = exercises;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[WorkoutsScreen] Error loading data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Exercise> get _filteredExercises {
    var list = _allExercises;
    if (_selectedMuscleFilter != 'All') {
      final q = _selectedMuscleFilter.toLowerCase();
      list = list.where((e) {
        final cat = e.category.name.toLowerCase();
        final muscles = e.primaryMuscles
            .map((m) => m.en.toLowerCase())
            .join(' ');
        return cat.contains(q) || muscles.contains(q);
      }).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((e) {
        final nameEn = e.name.en.toLowerCase();
        final nameId = e.name.id.toLowerCase();
        return nameEn.contains(q) || nameId.contains(q);
      }).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
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
                    'Workouts',
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                      color: const Color(0xFF141718),
                      letterSpacing: -0.6,
                    ),
                  ),
                  const Spacer(),
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
                    onPressed: _showFilterSheet,
                    icon: const Icon(
                      Icons.tune_rounded,
                      color: Color(0xFF141718),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar (bila aktif)
            if (_isSearchActive)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: TextField(
                  autofocus: true,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search workouts & exercises...',
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
                        color: Color(0xFFD4F836),
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
                        title: 'My Program',
                        isSelected: _selectedTabIndex == 0,
                        onTap: () => setState(() => _selectedTabIndex = 0),
                      ),
                    ),
                    Expanded(
                      child: _buildPillTab(
                        title: 'All Workouts',
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
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFD4F836),
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _loadData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 32),
                        child: _selectedTabIndex == 0
                            ? _buildMyProgramTab()
                            : _buildAllWorkoutsTab(),
                      ),
                    ),
            ),
          ],
        ),
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
          color: isSelected ? const Color(0xFFD4F836) : Colors.transparent,
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

  Widget _buildMyProgramTab() {
    final program = _activeProgram;
    final totalWeeks =
        _profile?.targetTimeframeWeeks ?? program?.durationWeeks ?? 8;
    final currentWeek = program != null
        ? ((DateTime.now().difference(program.startDate).inDays ~/ 7) + 1)
              .clamp(1, totalWeeks)
        : 1;

    final targetWeekly = _profile?.weeklyFrequency ?? 3;
    final totalSessions = totalWeeks * targetWeekly;
    final progressPercent = totalSessions > 0
        ? (_completedDays.length / totalSessions).clamp(0.0, 1.0)
        : 0.12;
    final percentInt = (progressPercent * 100).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A. Section Active Program
          Text(
            'Active Program',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 16.5,
              color: const Color(0xFF141718),
            ),
          ),
          const SizedBox(height: 12),

          InkWell(
            onTap: () {
              if (program != null) {
                context.push(AppRoutes.programDetail, extra: program);
              }
            },
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
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.fitness_center_rounded,
                              color: Color(0xFF65A30D),
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
                              program?.name ?? 'Full Body Adaptive',
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
                              '$totalWeeks weeks • Home workout',
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
                      Text(
                        'Week $currentWeek of $totalWeeks',
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
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
                        Color(0xFFD4F836),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // B. Section This Week
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'This Week',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 16.5,
                  color: const Color(0xFF141718),
                ),
              ),
              Text(
                '$_completedThisWeekCount/$targetWeekly workouts',
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFF6B7280),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // List Sesi Latihan
          if (_weekSessions.isEmpty)
            _buildSampleWeekList()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _weekSessions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final s = _weekSessions[index];
                final dayNumber = s.session.dayNumber;
                final isCompleted = _completedDays.contains(dayNumber);
                final isActiveToday =
                    !isCompleted &&
                    (index == 0 ||
                        _completedDays.contains(
                          _weekSessions[index - 1].session.dayNumber,
                        ));

                final title = s.session.focusLabel.isNotEmpty
                    ? s.session.focusLabel
                    : s.session.name;
                final duration = s.session.targetDurationMinutes > 0
                    ? s.session.targetDurationMinutes
                    : 30;

                return _buildWorkoutSessionCard(
                  dayNumber: dayNumber,
                  title: title,
                  durationMinutes: duration,
                  isCompleted: isCompleted,
                  isActiveToday: isActiveToday,
                  onTap: () {
                    context.push(
                      AppRoutes.workoutDetail,
                      extra: WorkoutDetailArgs(
                        dayNumber: dayNumber,
                        weekDayText: 'Week $currentWeek • Day $dayNumber',
                        workoutTitle: title,
                        targetMusclesText: s.session.focusLabel,
                        durationText: '$duration min',
                        levelText: _profile?.experienceLevel ?? 'Intermediate',
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

  Widget _buildWorkoutSessionCard({
    required int dayNumber,
    required String title,
    required int durationMinutes,
    required bool isCompleted,
    required bool isActiveToday,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActiveToday
                ? const Color(0xFFD4F836)
                : const Color(0xFFE5E7EB),
            width: isActiveToday ? 1.5 : 1.2,
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
                    : (isActiveToday
                          ? const Color(0xFFF9FED8)
                          : const Color(0xFFF3F4F6)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted
                    ? Icons.check_circle_rounded
                    : (isActiveToday
                          ? Icons.play_arrow_rounded
                          : Icons.lock_outline_rounded),
                size: 20,
                color: isCompleted
                    ? const Color(0xFF16A34A)
                    : (isActiveToday
                          ? const Color(0xFF65A30D)
                          : const Color(0xFF9CA3AF)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day $dayNumber',
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
                    '$durationMinutes min',
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isActiveToday)
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFD4F836),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Color(0xFF141718),
                  size: 22,
                ),
              )
            else if (isCompleted)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF16A34A),
                size: 22,
              )
            else
              const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFFD1D5DB),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleWeekList() {
    final sample = [
      {'day': 1, 'title': 'Chest, Quads & Core', 'min': 30, 'active': true},
      {'day': 2, 'title': 'Back & Arms', 'min': 28, 'active': false},
      {'day': 3, 'title': 'Full Body & Cardio', 'min': 32, 'active': false},
    ];

    return Column(
      children: sample.map((d) {
        final isActive = d['active'] as bool;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildWorkoutSessionCard(
            dayNumber: d['day'] as int,
            title: d['title'] as String,
            durationMinutes: d['min'] as int,
            isCompleted: false,
            isActiveToday: isActive,
            onTap: () {},
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAllWorkoutsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal Muscle Category Chips
        SizedBox(
          height: 38,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _muscleCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _muscleCategories[index];
              final isSel = cat == _selectedMuscleFilter;

              return GestureDetector(
                onTap: () => setState(() => _selectedMuscleFilter = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSel
                        ? const Color(0xFFD4F836)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      cat,
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
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _filteredExercises.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final ex = _filteredExercises[index];
            final target = ex.primaryMuscles.isNotEmpty
                ? ex.primaryMuscles.map((m) => m.en).join(', ')
                : ex.category.name;
            final thumb = ex.media.startPose.isNotEmpty
                ? ex.media.startPose
                : ex.media.endPose;

            return InkWell(
              onTap: () => context.push(AppRoutes.exerciseDetail, extra: ex),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1.2,
                  ),
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
                                errorBuilder: (_, __, ___) => const Icon(
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
                            ex.name.en.isNotEmpty ? ex.name.en : ex.name.id,
                            style: AppTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5,
                              color: const Color(0xFF141718),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$target • 10 min',
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
          },
        ),
      ],
    );
  }

  void _showFilterSheet() {
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
                  'Filter by Muscle Group',
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
                  children: _muscleCategories.map((cat) {
                    final isSel = cat == _selectedMuscleFilter;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSel,
                      selectedColor: const Color(0xFFD4F836),
                      backgroundColor: const Color(0xFFF3F4F6),
                      labelStyle: TextStyle(
                        color: const Color(0xFF141718),
                        fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                      ),
                      onSelected: (_) {
                        setState(() => _selectedMuscleFilter = cat);
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
