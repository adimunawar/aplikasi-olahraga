import '../../domain/models/day_activity.dart';
import '../../domain/models/progress_metrics.dart';
import '../../domain/models/workout_history_item.dart';

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
  final List<DayActivity> weeklyActivity;
  final String activeProgramTitle;
  final int activeProgramWeek;
  final int activeProgramTotalWeeks;
  final int activeProgramPercent;
  final bool isLoading;
  final String? errorMessage;

  const ProgressState({
    this.metrics = const ProgressMetrics(),
    this.currentWeight = 58.0,
    this.heightCm = 174.0,
    this.weightChange = -1.0,
    this.startLabel = '60 kg\n(Oct 25)',
    this.endLabel = '58 kg\n(Nov 5)',
    this.bmiValue = 19.2,
    this.bmiStatus = 'Healthy',
    this.recentWorkouts = const [],
    this.weeklyActivity = const [],
    this.activeProgramTitle = 'Upper Body Strength',
    this.activeProgramWeek = 3,
    this.activeProgramTotalWeeks = 8,
    this.activeProgramPercent = 37,
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
    List<DayActivity>? weeklyActivity,
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
      weeklyActivity: weeklyActivity ?? this.weeklyActivity,
      activeProgramTitle: activeProgramTitle ?? this.activeProgramTitle,
      activeProgramWeek: activeProgramWeek ?? this.activeProgramWeek,
      activeProgramTotalWeeks: activeProgramTotalWeeks ?? this.activeProgramTotalWeeks,
      activeProgramPercent: activeProgramPercent ?? this.activeProgramPercent,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

