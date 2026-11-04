import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/workout_session_entity.dart';
import '../../../../core/database/models/workout_set_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../../program/domain/models/program_day.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final ProgramDay day;
  final List<Exercise> exercises;

  const WorkoutSessionScreen({
    super.key,
    required this.day,
    required this.exercises,
  });

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  final _db = AppDatabase.instance;
  late final String _sessionId;
  late final DateTime _startedAt;

  int _currentExerciseIndex = 0;
  int _currentSetIndex = 0; // 0-based
  int _actualReps = 8;
  int _actualDurationSec = 20;

  // Rest Timer State
  bool _isResting = false;
  int _restRemainingSeconds = 60;
  Timer? _restTimer;

  // Completed log: exerciseId -> list of actual reps or seconds
  final Map<String, List<int>> _completedSetLogs = {};

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _sessionId = 'session_${_startedAt.millisecondsSinceEpoch}';

    // Enable wakelock so display does not sleep during active workout
    WakelockPlus.enable();
    _initCurrentSetTarget();
    _initSessionInDb();
  }

  Future<void> _initSessionInDb() async {
    final session = WorkoutSessionEntity(
      id: _sessionId,
      programId: 'program_30_days',
      programDayId: widget.day.day,
      programTitle: widget.day.focus.id,
      scheduledDate: DateTime.now(),
      startedAt: _startedAt,
      status: WorkoutSessionStatus.inProgress,
    );
    await _db.saveWorkoutSession(session);
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  void _initCurrentSetTarget() {
    final item = _currentWorkoutItem;
    if (item != null) {
      if (item.isDurationBased) {
        _actualDurationSec = item.durationSec ?? 20;
      } else {
        _actualReps = item.reps ?? 8;
      }
    }
  }

  WorkoutItem? get _currentWorkoutItem {
    if (_currentExerciseIndex < widget.day.items.length) {
      return widget.day.items[_currentExerciseIndex];
    }
    return null;
  }

  Exercise? get _currentExercise {
    if (_currentExerciseIndex < widget.exercises.length) {
      return widget.exercises[_currentExerciseIndex];
    }
    return null;
  }

  void _completeCurrentSet() {
    final item = _currentWorkoutItem;
    if (item == null) return;

    final logValue = item.isDurationBased ? _actualDurationSec : _actualReps;
    _completedSetLogs.putIfAbsent(item.exerciseId, () => []).add(logValue);

    // Save set to SQLite incrementally (WKO-10)
    final setEntity = WorkoutSetEntity(
      id: 'set_${_sessionId}_${item.exerciseId}_${_currentSetIndex + 1}',
      sessionId: _sessionId,
      exerciseId: item.exerciseId,
      setNumber: _currentSetIndex + 1,
      targetReps: item.reps,
      actualReps: item.isDurationBased ? null : _actualReps,
      durationSeconds: item.isDurationBased ? _actualDurationSec : null,
      status: WorkoutSetStatus.completed,
    );
    _db.saveWorkoutSet(setEntity);

    // Check if there are more sets for this exercise
    if (_currentSetIndex + 1 < item.sets) {
      _startRestTimer(item.restSeconds);
    } else {
      // Check if there are more exercises in this session
      if (_currentExerciseIndex + 1 < widget.day.items.length) {
        _startRestTimer(item.restSeconds);
      } else {
        // Workout Finished!
        _showWorkoutSummaryDialog();
      }
    }
  }

  void _startRestTimer(int durationSeconds) {
    setState(() {
      _isResting = true;
      _restRemainingSeconds = durationSeconds;
    });

    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restRemainingSeconds > 1) {
        setState(() {
          _restRemainingSeconds--;
        });
      } else {
        _skipRest();
      }
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() {
      _isResting = false;
      final item = _currentWorkoutItem;
      if (item != null && _currentSetIndex + 1 < item.sets) {
        _currentSetIndex++;
      } else {
        _currentExerciseIndex++;
        _currentSetIndex = 0;
      }
      _initCurrentSetTarget();
    });
  }

  void _addRestTime(int extraSeconds) {
    setState(() {
      _restRemainingSeconds += extraSeconds;
    });
  }

  void _showWorkoutSummaryDialog() {
    int totalSets = 0;
    int totalReps = 0;
    _completedSetLogs.forEach((_, logs) {
      totalSets += logs.length;
      totalReps += logs.fold(0, (sum, val) => sum + val);
    });

    // Save finished session to DB (HIS-02)
    final endedAt = DateTime.now();
    final durationSeconds = endedAt.difference(_startedAt).inSeconds;
    _db.saveWorkoutSession(WorkoutSessionEntity(
      id: _sessionId,
      programId: 'program_30_days',
      programDayId: widget.day.day,
      programTitle: widget.day.focus.id,
      scheduledDate: _startedAt,
      startedAt: _startedAt,
      endedAt: endedAt,
      durationSeconds: durationSeconds,
      status: WorkoutSessionStatus.completed,
    ));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: AppColors.electricLime, size: 28),
              const SizedBox(width: 10),
              Text(
                'SESI SELESAI!',
                style: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Luar biasa! Anda telah menyelesaikan seluruh sesi latihan hari ini.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryMetric('TOTAL SET', '$totalSets'),
                    Container(width: 1, height: 30, color: AppColors.divider),
                    _buildSummaryMetric('TOTAL REP/DETIK', '$totalReps'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '💡 Jangan lupa penuhi target protein harian Anda untuk mendukung sintesis protein otot.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.iceCyan),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricLime,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Return to Today Screen
                },
                child: Text(
                  'KEMBALI KE BERANDA',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryMetric(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: AppColors.textDim, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.tabularMetricSmall.copyWith(
            color: AppColors.electricLime,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = _currentWorkoutItem;
    final exercise = _currentExercise;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _confirmExitSession();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          backgroundColor: AppColors.canvas,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
            onPressed: _confirmExitSession,
          ),
          title: Text(
            'HARI ${widget.day.day} • ${widget.day.type.code}',
            style: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${_currentExerciseIndex + 1} / ${widget.day.items.length}',
                  style: AppTypography.tabularMetricSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: _isResting ? _buildRestTimerView() : _buildActiveSetView(item, exercise),
      ),
    );
  }

  void _confirmExitSession() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Akhiri Sesi Latihan?',
            style: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary),
          ),
          content: Text(
            'Progres sesi ini belum selesai. Anda yakin ingin keluar sekarang?',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Lanjutkan', style: TextStyle(color: AppColors.textDim)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.coral,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final endedAt = DateTime.now();
                final durationSeconds = endedAt.difference(_startedAt).inSeconds;
                await _db.saveWorkoutSession(WorkoutSessionEntity(
                  id: _sessionId,
                  programId: 'program_30_days',
                  programDayId: widget.day.day,
                  programTitle: widget.day.focus.id,
                  scheduledDate: _startedAt,
                  startedAt: _startedAt,
                  endedAt: endedAt,
                  durationSeconds: durationSeconds,
                  status: WorkoutSessionStatus.incomplete,
                ));
                if (mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Exit session
                }
              },
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActiveSetView(WorkoutItem? item, Exercise? exercise) {
    if (item == null || exercise == null) {
      return const SizedBox.shrink();
    }

    final isDuration = item.isDurationBased;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // Exercise Title & Category
            Text(
              exercise.category.localizedName('id').toUpperCase(),
              style: AppTypography.labelCaps.copyWith(
                color: AppColors.electricLime,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              exercise.name.id,
              style: AppTypography.displayMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 18),

            // Set Indicators: 1, 2, 3
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(item.sets, (index) {
                final isDone = index < _currentSetIndex;
                final isCurrent = index == _currentSetIndex;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppColors.electricLime
                        : isCurrent
                            ? AppColors.electricLime.withValues(alpha: 0.2)
                            : AppColors.surfaceRaised,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrent
                          ? AppColors.electricLime
                          : isDone
                              ? AppColors.electricLime
                              : AppColors.divider,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check, size: 20, color: Colors.black)
                        : Text(
                            '${index + 1}',
                            style: AppTypography.labelLarge.copyWith(
                              color: isCurrent ? AppColors.electricLime : AppColors.textDim,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                );
              }),
            ),

            const Spacer(),

            // Target vs Actual Reps Stepper Box
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Text(
                    isDuration
                        ? 'TARGET: ${item.durationSec} DETIK'
                        : 'TARGET: ${item.reps} REPS',
                    style: AppTypography.labelCaps.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Minus Button
                      IconButton(
                        iconSize: 48,
                        color: AppColors.textSecondary,
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                        onPressed: () {
                          setState(() {
                            if (isDuration) {
                              if (_actualDurationSec > 5) _actualDurationSec -= 5;
                            } else {
                              if (_actualReps > 1) _actualReps--;
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 24),
                      // Value Display
                      Text(
                        isDuration ? '$_actualDurationSec' : '$_actualReps',
                        style: AppTypography.timerDisplay.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Plus Button
                      IconButton(
                        iconSize: 48,
                        color: AppColors.electricLime,
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        onPressed: () {
                          setState(() {
                            if (isDuration) {
                              _actualDurationSec += 5;
                            } else {
                              _actualReps++;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Catat rep/durasi sebenarnya yang berhasil Anda lakukan',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textDim),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Hypertrophy form tip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.warmAmber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warmAmber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tips_and_updates_outlined, color: AppColors.warmAmber, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Otot tumbuh maksimal saat set dikerjakan hingga 1-2 rep mendekati gagal.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.warmAmber),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Big CTA: Complete Set
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricLime,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _completeCurrentSet,
                child: Text(
                  'SELESAIKAN SET ${_currentSetIndex + 1}',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildRestTimerView() {
    final nextItem = _currentWorkoutItem;
    final nextExercise = _currentExercise;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            Text(
              'WAKTU ISTIRAHAT OTOT',
              style: AppTypography.labelCaps.copyWith(
                color: AppColors.iceCyan,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tarik napas dalam, minum air, dan rilekskan otot',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            // Big Rest Timer Countdown
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(color: AppColors.iceCyan, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.iceCyan.withValues(alpha: 0.15),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(_restRemainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_restRemainingSeconds % 60).toString().padLeft(2, '0')}',
                      style: AppTypography.timerDisplay.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 54,
                      ),
                    ),
                    Text(
                      'DETIK',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.iceCyan,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // +15s Rest Button
            OutlinedButton.icon(
              onPressed: () => _addRestTime(15),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.iceCyan.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add, color: AppColors.iceCyan),
              label: Text(
                '+15 Detik Istirahat',
                style: AppTypography.labelLarge.copyWith(color: AppColors.iceCyan),
              ),
            ),

            const Spacer(),

            // Next Up Preview Card
            if (nextExercise != null && nextItem != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.skip_next_rounded, color: AppColors.electricLime, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BERIKUTNYA:',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textDim,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            '${nextExercise.name.id} (Set ${_currentSetIndex + 1})',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Skip Rest CTA
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricLime,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _skipRest,
                child: Text(
                  'LEWATI ISTIRAHAT & MULAI',
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
  }
}

