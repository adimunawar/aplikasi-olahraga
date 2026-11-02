import 'dart:math' as math;
import '../models/user_profile.dart';
import '../../program/domain/models/program_day.dart';

class TargetCalculator {
  static const Map<int, double> _weekFactors = {
    1: 0.60,
    2: 0.65,
    3: 0.70,
    4: 0.75,
    5: 0.75,
  };

  /// Calculates target reps or duration for a given exercise and week,
  /// honoring test results or fallback user profile.
  static WorkoutItem calculateTarget({
    required WorkoutItem baseItem,
    required int week,
    required UserProfile profile,
    Map<String, int>? testResults, // exerciseId -> max reps/duration
  }) {
    final factor = _weekFactors[week] ?? 0.75;
    final testResult = testResults?[baseItem.exerciseId];

    if (testResult != null && testResult > 0) {
      if (baseItem.isDurationBased) {
        // Plank or time-based: lower bound 15 seconds
        final calculatedSeconds = math.max(15, (testResult * factor).round());
        return baseItem.copyWith(durationSec: calculatedSeconds);
      } else {
        // Rep-based: lower bound 3 reps
        final calculatedReps = math.max(3, (testResult * factor).round());
        return baseItem.copyWith(reps: calculatedReps);
      }
    }

    // Direct test not available, check parent exercise for variations:
    // e.g. diamond push up / incline push up based on push_up test
    if (baseItem.exerciseId == 'incline_push_up' && testResults?.containsKey('push_up') == true) {
      final parentScore = testResults!['push_up']!;
      final calculatedReps = math.max(3, (parentScore * factor * 1.2).round());
      return baseItem.copyWith(reps: calculatedReps);
    }

    if (baseItem.exerciseId == 'diamond_push_up' && testResults?.containsKey('push_up') == true) {
      final parentScore = testResults!['push_up']!;
      final calculatedReps = math.max(3, (parentScore * factor * 0.6).round());
      return baseItem.copyWith(reps: calculatedReps);
    }

    if (baseItem.exerciseId == 'lunges' && testResults?.containsKey('squat') == true) {
      final parentScore = testResults!['squat']!;
      final calculatedReps = math.max(3, (parentScore * factor * 0.8).round());
      return baseItem.copyWith(reps: calculatedReps);
    }

    // Fallback: apply profile multiplier
    final multiplier = profile.fallbackLevel.fallbackMultiplier;
    if (baseItem.isDurationBased) {
      final fallbackSec = math.max(15, ((baseItem.durationSec ?? 20) * multiplier).round());
      return baseItem.copyWith(durationSec: fallbackSec);
    } else {
      final fallbackReps = math.max(3, ((baseItem.reps ?? 8) * multiplier).round());
      return baseItem.copyWith(reps: fallbackReps);
    }
  }
}

