import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/body_measurement_entity.dart';
import '../../../../core/database/models/dynamic_program_entity.dart';
import '../../../../core/database/models/user_profile_entity.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/app_data_sync.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../exercises/data/datasources/exercise_local_datasource.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../../program/domain/models/program_day.dart';
import '../../../program/domain/services/dynamic_program_generator.dart';
import '../widgets/plans_overview_tab.dart';
import '../widgets/plans_workout_split_tab.dart';
import '../widgets/plans_progress_tab.dart';

class SessionWithDetail {
  final ProgramSessionEntity session;
  final ProgramSessionDetail detail;

  const SessionWithDetail({required this.session, required this.detail});
}

/// Halaman Your Training Plan
/// 100% Sesuai Mockup Row 2: Overview, Workout Split, Progress
class PlansScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;
  final bool isOnboarding;

  const PlansScreen({
    super.key,
    this.initialTabIndex = 0,
    this.isOnboarding = false,
  });

  @override
  ConsumerState<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends ConsumerState<PlansScreen>
    with SingleTickerProviderStateMixin {
  final _db = AppDatabase.instance;
  late TabController _tabController;

  UserProfileEntity? _profile;
  TrainingProgramEntity? _program;
  List<SessionWithDetail> _sessions = [];
  List<BodyMeasurementEntity> _weightHistory = [];
  int _completedTotalWorkouts = 0;

  int _currentActiveWeek = 1;
  int _totalWeeks = 12;
  bool _isLoading = true;
  bool _isFetching = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 2),
    );
    _loadPlanData();
    AppDataSync.instance.dataRevision.addListener(_onDataSync);
  }

  @override
  void dispose() {
    _tabController.dispose();
    AppDataSync.instance.dataRevision.removeListener(_onDataSync);
    super.dispose();
  }

  void _onDataSync() {
    if (mounted) {
      _loadPlanData();
    }
  }

  Future<void> _loadPlanData() async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      final profile = await _db.getUserProfile();
      final userId = profile.id.isNotEmpty ? profile.id : 'default_user';

      var program = await _db.getActiveTrainingProgram(userId);
      program ??= await _db.getActiveTrainingProgram('default_user');

      final List<SessionWithDetail> sessionList = [];
      if (program != null) {
        final rawSessions = await _db.getProgramSessions(program.id);
        for (final s in rawSessions) {
          final detail = await _db.getProgramSessionDetail(s.id);
          if (detail != null) {
            sessionList.add(SessionWithDetail(session: s, detail: detail));
          }
        }
      }

      // Auto-generate / Auto-heal jika program belum ada atau sesi tidak sinkron
      final targetWeekly = profile.weeklyFrequency > 0
          ? profile.weeklyFrequency
          : 4;
      if (program == null ||
          sessionList.isEmpty ||
          sessionList.length != targetWeekly) {
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
          program = generated.program;

          sessionList.clear();
          final newRawSessions = await _db.getProgramSessions(program.id);
          for (final s in newRawSessions) {
            final detail = await _db.getProgramSessionDetail(s.id);
            if (detail != null) {
              sessionList.add(SessionWithDetail(session: s, detail: detail));
            }
          }
        } catch (e) {
          debugPrint('[PlansScreen] Error generating dynamic program: $e');
        }
      }

      final thisWeekCount = await _db.getThisWeekCompletedCount();
      final totalCompleted = await _db.getCompletedSessionsCount();
      final weightLogs = await _db.getWeightHistory();

      final totalWeeks = profile.targetTimeframeWeeks > 0
          ? profile.targetTimeframeWeeks
          : (program?.durationWeeks ?? 12);
      final activeWeek = ((thisWeekCount ~/ targetWeekly) + 1).clamp(
        1,
        totalWeeks,
      );

      if (mounted) {
        setState(() {
          _profile = profile;
          _program = program;
          _sessions = sessionList;
          _weightHistory = weightLogs;
          _completedTotalWorkouts = totalCompleted;
          _currentActiveWeek = activeWeek;
          _totalWeeks = totalWeeks;
          _hasError = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[PlansScreen] Error loading data: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } finally {
      _isFetching = false;
    }
  }

  void _showSwitchProgramModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Text(
                'Switch Training Focus',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Customize your program focus or re-align with your current fitness goal.',
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFF6B7280),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),

              _buildProgramOption(
                title: 'Gain Weight & Build Muscle',
                desc: 'Hypertrophy focused volume • 12 Weeks',
                goalKey: 'bulking',
                icon: Icons.fitness_center_rounded,
              ),
              const SizedBox(height: 10),
              _buildProgramOption(
                title: 'Lose Weight & Reduce Fat',
                desc: 'Metabolic conditioning & fat burning • 12 Weeks',
                goalKey: 'fat_loss',
                icon: Icons.local_fire_department_rounded,
              ),
              const SizedBox(height: 10),
              _buildProgramOption(
                title: 'Maintain & Stay Fit',
                desc: 'Functional calisthenics & core strength • 12 Weeks',
                goalKey: 'maintenance',
                icon: Icons.favorite_rounded,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgramOption({
    required String title,
    required String desc,
    required String goalKey,
    required IconData icon,
  }) {
    final isSelected = _profile?.goal.toLowerCase().contains(goalKey) == true;

    return Material(
      color: isSelected ? const Color(0xFFF4F9ED) : const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () async {
          Navigator.pop(context);
          if (_profile != null) {
            setState(() => _isLoading = true);
            final updatedProfile = _profile!.copyWith(goal: goalKey);
            await _db.saveUserProfile(updatedProfile);

            // Re-generate program dinamis
            final exerciseDatasource = ExerciseLocalDatasource(db: _db);
            final catalog = await exerciseDatasource.loadExercises();
            final startingPushId = updatedProfile.experienceLevel == 'advanced'
                ? 'diamond_push_up'
                : updatedProfile.experienceLevel == 'intermediate'
                ? 'push_up'
                : 'knee_push_up';

            final generated = const DynamicProgramGenerator().generate(
              userProfile: updatedProfile,
              catalogExercises: catalog,
              startingPushExerciseId: startingPushId,
            );

            await _db.saveDynamicProgram(
              program: generated.program,
              sessions: generated.sessions,
            );

            await _loadPlanData();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Program updated to $title!'),
                  backgroundColor: AppColors.darkCharcoal,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF84CC16)
                  : const Color(0xFFE5E7EB),
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF84CC16)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? AppColors.darkCharcoal
                      : const Color(0xFF4B5563),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFF6B7280),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF84CC16),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditScheduleModal() {
    if (_profile == null) return;
    final currentDays = List<String>.from(_profile!.availableDays);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Edit Schedule',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select workout days per week (${currentDays.length} days selected)',
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children:
                        [
                          {'key': 'monday', 'label': 'Mon'},
                          {'key': 'tuesday', 'label': 'Tue'},
                          {'key': 'wednesday', 'label': 'Wed'},
                          {'key': 'thursday', 'label': 'Thu'},
                          {'key': 'friday', 'label': 'Fri'},
                          {'key': 'saturday', 'label': 'Sat'},
                          {'key': 'sunday', 'label': 'Sun'},
                        ].map((day) {
                          final isSelected = currentDays.any(
                            (d) => d.toLowerCase() == day['key']!.toLowerCase(),
                          );
                          return FilterChip(
                            label: Text(day['label']!),
                            selected: isSelected,
                            selectedColor: const Color(0xFFD4F836),
                            checkmarkColor: AppColors.darkCharcoal,
                            labelStyle: TextStyle(
                              color: AppColors.darkCharcoal,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.transparent
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            onSelected: (selected) {
                              setModalState(() {
                                if (selected) {
                                  if (!currentDays.contains(day['key'])) {
                                    currentDays.add(day['key']!);
                                  }
                                } else {
                                  if (currentDays.length > 1) {
                                    currentDays.removeWhere(
                                      (d) =>
                                          d.toLowerCase() ==
                                          day['key']!.toLowerCase(),
                                    );
                                  }
                                }
                              });
                            },
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        setState(() => _isLoading = true);
                        final updatedProfile = _profile!.copyWith(
                          availableDays: currentDays,
                          weeklyFrequency: currentDays.length,
                          preferredDaysPerWeek: currentDays.length,
                        );
                        await _db.saveUserProfile(updatedProfile);
                        await _loadPlanData();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Schedule updated: ${currentDays.length} workout days / week!',
                              ),
                              backgroundColor: AppColors.darkCharcoal,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF84CC16),
                        foregroundColor: AppColors.darkCharcoal,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Save Schedule',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLogWeightModal() {
    double tempWeight = _profile?.currentWeightKg ?? 75.0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                32 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Log Today's Weight",
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Track your progress to keep your plan adaptive.',
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Weight Stepper
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        onPressed: () {
                          if (tempWeight > 35) {
                            setModalState(() => tempWeight -= 0.5);
                          }
                        },
                        icon: const Icon(Icons.remove_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFF3F4F6),
                          foregroundColor: AppColors.darkCharcoal,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Text(
                        '${tempWeight.toStringAsFixed(1)} kg',
                        style: AppTypography.headlineLarge.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      const SizedBox(width: 24),
                      IconButton.filledTonal(
                        onPressed: () {
                          if (tempWeight < 250) {
                            setModalState(() => tempWeight += 0.5);
                          }
                        },
                        icon: const Icon(Icons.add_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFF3F4F6),
                          foregroundColor: AppColors.darkCharcoal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _db.recordBodyWeight(tempWeight);
                        AppDataSync.instance.notifyDataChanged();
                        await _loadPlanData();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Weight logged: ${tempWeight.toStringAsFixed(1)} kg!',
                              ),
                              backgroundColor: AppColors.darkCharcoal,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.limeAccent,
                        foregroundColor: AppColors.darkCharcoal,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Save Weight',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _startWorkoutSession(SessionWithDetail s) async {
    final exercises = s.detail.exercises.map((e) => e.exercise).toList();
    final workoutItems = s.detail.exercises.map((e) {
      return WorkoutItem(
        exerciseId: e.exercise.id,
        sets: e.prescription.targetSets,
        reps: e.prescription.minReps,
        restSeconds: e.prescription.restSeconds,
        isMain: e.prescription.stage == 'main',
        stage: e.prescription.stage,
      );
    }).toList();

    final programDay = ProgramDay(
      day: s.session.dayNumber,
      week: _currentActiveWeek,
      type: WorkoutTypeCode.f,
      focus: LocalizedString(
        id: s.session.focusLabel,
        en: s.session.focusLabel,
      ),
      isRest: false,
      isRetestMilestone: false,
      items: workoutItems,
    );

    await context.push(
      AppRoutes.workoutSession,
      extra: WorkoutSessionArgs(day: programDay, exercises: exercises),
    );
    if (mounted) {
      _loadPlanData();
    }
  }

  Future<void> _previewSession(SessionWithDetail s) async {
    await context.push(
      AppRoutes.workoutDetail,
      extra: WorkoutDetailArgs(
        dayNumber: s.session.dayNumber,
        weekDayText: 'Week $_currentActiveWeek • Day ${s.session.dayNumber}',
        workoutTitle: s.session.focusLabel,
        targetMusclesText: _program?.name ?? 'Full Body',
        durationText: '${s.session.targetDurationMinutes} min',
        levelText: _profile?.experienceLevel ?? 'Beginner',
      ),
    );
    if (mounted) {
      _loadPlanData();
    }
  }

  Future<void> _completeOnboardingAndGoHome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);
    ref.read(hasCompletedOnboardingProvider.notifier).state = true;
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _completeOnboardingAndStartWorkout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);
    ref.read(hasCompletedOnboardingProvider.notifier).state = true;
    if (_sessions.isNotEmpty) {
      _startWorkoutSession(_sessions.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF84CC16)),
        ),
      );
    }

    final totalScheduledWorkouts =
        (_profile?.weeklyFrequency ?? 4) * _totalWeeks;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: widget.isOnboarding
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF141718)),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.pushReplacement(AppRoutes.planReady);
                  }
                },
              )
            : (context.canPop()
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF141718)),
                    onPressed: () => context.pop(),
                  )
                : null),
        title: Text(
          'Your Training Plan',
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: const Color(0xFF141718),
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_horiz_rounded,
              color: Color(0xFF141718),
            ),
            onPressed: _showSwitchProgramModal,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1.2),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF84CC16),
              indicatorWeight: 3.0,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: const Color(0xFF141718),
              unselectedLabelColor: const Color(0xFF9CA3AF),
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Workout Split'),
                Tab(text: 'Progress'),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: widget.isOnboarding
          ? Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: AppButton.primary(
                text: 'Get Started ➔',
                size: AppButtonSize.large,
                onPressed: _completeOnboardingAndGoHome,
              ),
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Overview
          PlansOverviewTab(
            profile: _profile,
            program: _program,
            onSwitchProgram: _showSwitchProgramModal,
          ),

          // Tab 2: Workout Split
          PlansWorkoutSplitTab(
            profile: _profile,
            program: _program,
            sessions: _sessions,
            onSessionTap: _previewSession,
            onEditSchedule: _showEditScheduleModal,
          ),

          // Tab 3: Progress
          PlansProgressTab(
            profile: _profile,
            weightHistory: _weightHistory,
            completedWorkouts: _completedTotalWorkouts,
            totalScheduledWorkouts: totalScheduledWorkouts,
            currentWeek: _currentActiveWeek,
            totalWeeks: _totalWeeks,
            hasError: _hasError,
            onRetry: _loadPlanData,
            onLogWeight: _showLogWeightModal,
            onStartWorkout: () {
              if (widget.isOnboarding) {
                _completeOnboardingAndStartWorkout();
              } else if (_sessions.isNotEmpty) {
                _startWorkoutSession(_sessions.first);
              }
            },
          ),
        ],
      ),
    );
  }
}
