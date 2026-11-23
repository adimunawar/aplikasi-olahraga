import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/dynamic_program_entity.dart';
import '../../../../core/database/models/workout_session_entity.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../exercises/data/datasources/exercise_local_datasource.dart';
import '../../../exercises/data/repositories/exercise_repository_impl.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../../program/domain/models/program_day.dart';
import '../../../program/domain/services/program_week_schedule.dart';
import '../../../workout_session/domain/models/exercise_prescription.dart';

class _CalendarDayData {
  final int sequenceDay;
  final DateTime date;
  final ProgramDay day;
  final List<Exercise> exercises;
  final Map<String, WorkoutExercisePrescription> prescriptions;
  final bool isCompleted;
  final String? activeSessionId;

  const _CalendarDayData({
    required this.sequenceDay,
    required this.date,
    required this.day,
    required this.exercises,
    required this.prescriptions,
    required this.isCompleted,
    this.activeSessionId,
  });
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _db = AppDatabase.instance;
  final _exerciseRepo = ExerciseRepositoryImpl(ExerciseLocalDatasource());

  List<_CalendarDayData> _allDays = [];
  int _leadingEmptyDays = 0;
  String? _activeProgramId;
  String? _activeProgramName;
  String? _loadError;
  bool _hasActiveProgram = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgram();
  }

  Future<void> _loadProgram() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      // Refresh the cloud-first exercise catalog before reading session details.
      // The repository stores successful cloud results in SQLite and falls back
      // to the local catalog when Supabase is unavailable.
      await _exerciseRepo.getExercises();

      final profile = await _db.getUserProfile();
      final userId = profile.id.isNotEmpty ? profile.id : 'default_user';

      var program = await _db.getActiveTrainingProgram(userId);
      program ??= await _db.getActiveTrainingProgram('default_user');

      if (program == null) {
        if (mounted) {
          setState(() {
            _allDays = [];
            _activeProgramId = null;
            _activeProgramName = null;
            _hasActiveProgram = false;
            _isLoading = false;
          });
        }
        return;
      }

      final activeProgram = program;
      final sessions = await _db.getProgramSessions(activeProgram.id);
      if (sessions.isEmpty) {
        if (mounted) {
          setState(() {
            _allDays = [];
            _activeProgramId = activeProgram.id;
            _activeProgramName = activeProgram.name;
            _hasActiveProgram = false;
            _loadError =
                'Your active program does not have a workout schedule yet.';
            _isLoading = false;
          });
        }
        return;
      }

      final detailsBySessionId = <String, ProgramSessionDetail>{};
      for (final session in sessions) {
        final detail = await _db.getProgramSessionDetail(session.id);
        if (detail != null) {
          detailsBySessionId[session.id] = detail;
        }
      }

      final workoutHistory = await _db.getWorkoutSessionsForProgram(
        activeProgram.id,
      );
      final totalWeeks = profile.targetTimeframeWeeks > 0
          ? profile.targetTimeframeWeeks
          : activeProgram.durationWeeks;
      final programStartDate = ProgramWeekSchedule.dateOnly(
        activeProgram.startDate,
      );
      final today = ProgramWeekSchedule.dateOnly(DateTime.now());
      final days = <_CalendarDayData>[];
      final leadingEmptyDays = today.weekday - 1;

      // The calendar is a rolling 30-day view built from the active program's
      // weekly sessions and the same availability rules used by Home and Plans.
      for (var offset = 0; offset < 30; offset++) {
        final date = today.add(Duration(days: offset));
        final sequenceDay = offset + 1;
        final week = ProgramWeekSchedule.currentWeek(
          programStartDate: programStartDate,
          today: date,
          totalWeeks: totalWeeks,
        );
        final daysFromProgramStart = date.difference(programStartDate).inDays;
        final isInsideProgram =
            daysFromProgramStart >= 0 && daysFromProgramStart < totalWeeks * 7;

        final scheduled = isInsideProgram
            ? ProgramWeekSchedule.sessionForDate(
                programStartDate: programStartDate,
                date: date,
                availableDays: profile.availableDays,
                sessions: sessions,
                totalWeeks: totalWeeks,
              )
            : null;

        final dayHistory = workoutHistory
            .where(
              (record) =>
                  ProgramWeekSchedule.dateOnly(record.scheduledDate) == date,
            )
            .toList();
        final isCompleted = dayHistory.any(
          (record) => record.status == WorkoutSessionStatus.completed,
        );
        final inProgressRecords = dayHistory
            .where((record) => record.status == WorkoutSessionStatus.inProgress)
            .toList();

        if (scheduled == null) {
          final restDay = ProgramDay(
            day: sequenceDay,
            week: week,
            type: WorkoutTypeCode.r,
            focus: 'Istirahat & Pemulihan',
            isRest: true,
            isRetestMilestone: false,
            items: const [],
          );

          days.add(
            _CalendarDayData(
              sequenceDay: sequenceDay,
              date: date,
              day: restDay,
              exercises: const [],
              prescriptions: const {},
              isCompleted: isCompleted,
            ),
          );
          continue;
        }

        final detail = detailsBySessionId[scheduled.session.id];
        final detailItems =
            detail?.exercises ?? const <ProgramExerciseDetailItem>[];
        final exercises = detailItems.map((item) => item.exercise).toList();
        final prescriptions = <String, WorkoutExercisePrescription>{
          for (final item in detailItems)
            item.exercise.id: WorkoutExercisePrescription.fromProgramExercise(
              item.prescription,
              trackingType: item.exercise.trackingType,
            ),
        };
        final workoutItems = detailItems.map((item) {
          final exercise = item.exercise;
          final prescription = item.prescription;
          final isDuration = exercise.trackingType == TrackingType.duration;

          return WorkoutItem(
            exerciseId: exercise.id,
            sets: prescription.targetSets,
            reps: isDuration ? null : prescription.minReps,
            durationSec: isDuration ? prescription.maxReps : null,
            restSeconds: prescription.restSeconds,
            isMain: prescription.stage == 'main',
            stage: prescription.stage,
          );
        }).toList();

        final workoutDay = ProgramDay(
          day: scheduled.session.dayNumber,
          week: week,
          type: _resolveWorkoutType(scheduled.session.focusLabel),
          focus: scheduled.session.focusLabel,
          isRest: false,
          isRetestMilestone: false,
          items: workoutItems,
          title: scheduled.session.name,
          estimatedDurationMinutes: scheduled.session.targetDurationMinutes,
        );

        days.add(
          _CalendarDayData(
            sequenceDay: sequenceDay,
            date: date,
            day: workoutDay,
            exercises: exercises,
            prescriptions: prescriptions,
            isCompleted: isCompleted,
            activeSessionId: inProgressRecords.isEmpty
                ? null
                : inProgressRecords.first.id,
          ),
        );
      }

      if (mounted) {
        setState(() {
          _allDays = days;
          _leadingEmptyDays = leadingEmptyDays;
          _activeProgramId = activeProgram.id;
          _activeProgramName = activeProgram.name;
          _hasActiveProgram = true;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _allDays = [];
          _hasActiveProgram = false;
          _loadError = 'Could not load your workout schedule: $error';
          _isLoading = false;
        });
      }
    }
  }

  WorkoutTypeCode _resolveWorkoutType(String focusLabel) {
    final label = focusLabel.toLowerCase();

    if (label.contains('leg') ||
        label.contains('lower') ||
        label.contains('quad') ||
        label.contains('glute') ||
        label.contains('hamstring') ||
        label.contains('calf') ||
        label.contains('lunge') ||
        label.contains('squat')) {
      return WorkoutTypeCode.k;
    }

    if (label.contains('push') ||
        label.contains('chest') ||
        label.contains('shoulder') ||
        label.contains('triceps')) {
      return WorkoutTypeCode.p;
    }

    if (label.contains('core') || label.contains('ab')) {
      return WorkoutTypeCode.c;
    }

    return WorkoutTypeCode.f;
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  void _showDayDetailsSheet(_CalendarDayData entry) {
    final day = entry.day;
    final isToday = _isSameDate(entry.date, DateTime.now());
    final color = AppColors.forWorkoutCode(day.type.code);
    final exerciseNames = {
      for (final exercise in entry.exercises) exercise.id: exercise.name.id,
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: color),
                          ),
                          child: Text(
                            day.type.code,
                            style: AppTypography.labelLarge.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'DAY ${entry.sequenceDay} / 30',
                          style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    if (isToday)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.electricLime.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'TODAY',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.electricLime,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  MaterialLocalizations.of(context)
                      .formatMediumDate(entry.date),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textDim,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  day.focus,
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                if (day.isRest)
                  Text(
                    'No workout is scheduled for this day. Use it to recover and prepare for your next session.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                else ...[
                  Text(
                    'TARGET EXERCISES',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textDim,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (day.items.isEmpty)
                    Text(
                      'Exercise details are not available for this session yet.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )
                  else
                    ...day.items.map((item) {
                      final repsText = item.isDurationBased
                          ? '${item.sets} x ${item.durationSec}s'
                          : '${item.sets} x ${item.reps ?? '—'} reps';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                exerciseNames[item.exerciseId] ??
                                    item.exerciseId,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              repsText,
                              style: AppTypography.tabularMetricSmall.copyWith(
                                color: AppColors.electricLime,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
                const SizedBox(height: 24),
                if (!day.isRest && entry.exercises.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.electricLime,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        context.push(
                          AppRoutes.workoutSession,
                          extra: WorkoutSessionArgs(
                            day: day,
                            exercises: entry.exercises,
                            programId: _activeProgramId,
                            scheduledDate: entry.date,
                            activeSessionId: entry.activeSessionId,
                            prescriptions: entry.prescriptions,
                          ),
                        );
                      },
                      child: Text(
                        entry.activeSessionId != null
                            ? 'RESUME WORKOUT'
                            : 'START WORKOUT',
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.canvas,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.electricLime),
        ),
      );
    }

    if (!_hasActiveProgram) {
      final hasError = _loadError != null;
      return Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          backgroundColor: AppColors.canvas,
          elevation: 0,
          title: Text(
            'WORKOUT SCHEDULE',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 1.0,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasError
                      ? Icons.event_busy_rounded
                      : Icons.calendar_month_rounded,
                  size: 48,
                  color: AppColors.textDim,
                ),
                const SizedBox(height: 16),
                Text(
                  hasError ? 'Schedule unavailable' : 'No active workout plan',
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _loadError ?? 'Create or activate a workout plan to see your personalized schedule here.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricLime,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: hasError
                      ? _loadProgram
                      : () => context.go(AppRoutes.plans),
                  child: Text(hasError ? 'TRY AGAIN' : 'OPEN MY PLAN'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        title: Text(
          'NEXT 30 DAYS',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_activeProgramName != null) ...[
              Text(
                _activeProgramName!,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
            ],
            _buildLegend(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                  .map(
                    (dayName) => SizedBox(
                      width: 44,
                      child: Center(
                        child: Text(
                          dayName,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textDim,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.85,
              ),
              itemCount: _leadingEmptyDays + _allDays.length,
              itemBuilder: (context, index) {
                if (index < _leadingEmptyDays) {
                  return const SizedBox.shrink();
                }
                final entry = _allDays[index - _leadingEmptyDays];
                final day = entry.day;
                final isToday = _isSameDate(entry.date, DateTime.now());
                final color = AppColors.forWorkoutCode(day.type.code);

                return GestureDetector(
                  onTap: () => _showDayDetailsSheet(entry),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppColors.electricLime.withValues(alpha: 0.15)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isToday
                            ? AppColors.electricLime
                            : color.withValues(alpha: 0.35),
                        width: isToday ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          entry.sequenceDay.toString(),
                          style: AppTypography.bodySmall.copyWith(
                            color: isToday
                                ? AppColors.electricLime
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: entry.isCompleted
                                ? AppColors.electricLime.withValues(alpha: 0.25)
                                : color.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: entry.isCompleted
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: AppColors.electricLime,
                                  )
                                : Text(
                                    day.type.code,
                                    style: AppTypography.labelSmall.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Your schedule follows the active program and selected training days. Rest days are calculated automatically.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem('P', 'Push', AppColors.pushWorkout),
          _legendItem('K', 'Legs', AppColors.legsWorkout),
          _legendItem('C', 'Core', AppColors.coreWorkout),
          _legendItem('F', 'Full', AppColors.fullBodyWorkout),
          _legendItem('R', 'Rest', AppColors.restDay),
        ],
      ),
    );
  }

  Widget _legendItem(String code, String name, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 5),
        Text(
          '$code:$name',
          style: AppTypography.bodySmall.copyWith(
            fontSize: 10,
            color: AppColors.textDim,
          ),
        ),
      ],
    );
  }
}
