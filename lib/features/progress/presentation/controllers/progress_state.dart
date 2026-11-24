import '../../domain/models/day_activity.dart';
import '../../domain/models/progress_metrics.dart';
import '../../domain/models/workout_history_item.dart';
import '../../domain/models/movement_volume_data.dart';
import '../../domain/models/progression_milestone.dart';
import '../../domain/models/weight_record.dart';

/// Immutable State untuk halaman Progress
class ProgressState {
  final ProgressMetrics metrics;
  final double currentWeight;
  final double heightCm;
  final double weightChange;
  final String startLabel;
  final String endLabel;
  final double bmiValue;
  final String bmiStatus;
  final List<WorkoutHistoryItem> recentWorkouts;
  final List<WeightRecord> weightHistory;
  final List<DayActivity> weeklyActivity;
  final List<MovementVolumeData> movementVolume;
  final List<ProgressionMilestone> milestones;
  final bool hasActiveProgram;
  final String activeProgramTitle;
  final int activeProgramWeek;
  final int activeProgramTotalWeeks;
  final int activeProgramPercent;
  final bool isLoading;
  final String? errorMessage;

  const ProgressState({
    this.metrics = const ProgressMetrics(),
    this.currentWeight = 0,
    this.heightCm = 0,
    this.weightChange = 0,
    this.startLabel = '',
    this.endLabel = '',
    this.bmiValue = 0,
    this.bmiStatus = '',
    this.recentWorkouts = const [],
    this.weightHistory = const [],
    this.weeklyActivity = const [],
    this.movementVolume = const [],
    this.milestones = const [],
    this.hasActiveProgram = false,
    this.activeProgramTitle = '',
    this.activeProgramWeek = 0,
    this.activeProgramTotalWeeks = 0,
    this.activeProgramPercent = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  ProgressState copyWith({
    ProgressMetrics? metrics,
    double? currentWeight,
    double? heightCm,
    double? weightChange,
    String? startLabel,
    String? endLabel,
    double? bmiValue,
    String? bmiStatus,
    List<WorkoutHistoryItem>? recentWorkouts,
    List<WeightRecord>? weightHistory,
    List<DayActivity>? weeklyActivity,
    List<MovementVolumeData>? movementVolume,
    List<ProgressionMilestone>? milestones,
    bool? hasActiveProgram,
    String? activeProgramTitle,
    int? activeProgramWeek,
    int? activeProgramTotalWeeks,
    int? activeProgramPercent,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProgressState(
      metrics: metrics ?? this.metrics,
      currentWeight: currentWeight ?? this.currentWeight,
      heightCm: heightCm ?? this.heightCm,
      weightChange: weightChange ?? this.weightChange,
      startLabel: startLabel ?? this.startLabel,
      endLabel: endLabel ?? this.endLabel,
      bmiValue: bmiValue ?? this.bmiValue,
      bmiStatus: bmiStatus ?? this.bmiStatus,
      recentWorkouts: recentWorkouts ?? this.recentWorkouts,
      weightHistory: weightHistory ?? this.weightHistory,
      weeklyActivity: weeklyActivity ?? this.weeklyActivity,
      movementVolume: movementVolume ?? this.movementVolume,
      milestones: milestones ?? this.milestones,
      hasActiveProgram: hasActiveProgram ?? this.hasActiveProgram,
      activeProgramTitle: activeProgramTitle ?? this.activeProgramTitle,
      activeProgramWeek: activeProgramWeek ?? this.activeProgramWeek,
      activeProgramTotalWeeks:
          activeProgramTotalWeeks ?? this.activeProgramTotalWeeks,
      activeProgramPercent: activeProgramPercent ?? this.activeProgramPercent,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
