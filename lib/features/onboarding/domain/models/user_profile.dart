import 'package:flutter/foundation.dart';

enum WorkoutGoal {
  hypertrophy, // Membentuk otot (default)
  strength,    // Kekuatan
  endurance;   // Daya tahan

  static WorkoutGoal fromString(String val) {
    switch (val.toLowerCase()) {
      case 'strength':
        return WorkoutGoal.strength;
      case 'endurance':
        return WorkoutGoal.endurance;
      case 'hypertrophy':
      default:
        return WorkoutGoal.hypertrophy;
    }
  }

  String localizedTitle(String langCode) {
    final isEn = langCode.toLowerCase().startsWith('en');
    switch (this) {
      case WorkoutGoal.hypertrophy:
        return isEn ? 'Muscle Hypertrophy' : 'Membentuk Otot';
      case WorkoutGoal.strength:
        return isEn ? 'Raw Strength' : 'Kekuatan';
      case WorkoutGoal.endurance:
        return isEn ? 'Muscle Endurance' : 'Daya Tahan';
    }
  }
}

enum FitnessLevel {
  beginner,
  intermediate,
  advanced;

  static FitnessLevel fromString(String val) {
    switch (val.toLowerCase()) {
      case 'beginner':
        return FitnessLevel.beginner;
      case 'advanced':
        return FitnessLevel.advanced;
      case 'intermediate':
      default:
        return FitnessLevel.intermediate;
    }
  }

  double get fallbackMultiplier {
    switch (this) {
      case FitnessLevel.beginner:
        return 0.7;
      case FitnessLevel.intermediate:
        return 1.0;
      case FitnessLevel.advanced:
        return 1.3;
    }
  }
}

@immutable
class UserProfile {
  final WorkoutGoal goal;
  final int daysPerWeek;
  final int age;
  final double heightCm;
  final double weightKg;
  final FitnessLevel fallbackLevel;
  final List<String> readinessFlags; // PAR-Q answers
  final double proteinFactor;        // e.g. 1.6 g/kg
  final List<String> foodExclusions; // Allergens or preferences

  const UserProfile({
    this.goal = WorkoutGoal.hypertrophy,
    this.daysPerWeek = 4,
    this.age = 25,
    this.heightCm = 170.0,
    this.weightKg = 65.0,
    this.fallbackLevel = FitnessLevel.intermediate,
    this.readinessFlags = const [],
    this.proteinFactor = 1.6,
    this.foodExclusions = const [],
  });

  /// Recommended daily protein intake target in grams (e.g. 65 kg * 1.6 = 104 g)
  double get dailyProteinTargetG => (weightKg * proteinFactor).roundToDouble();

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      goal: WorkoutGoal.fromString(json['goal'] as String? ?? 'hypertrophy'),
      daysPerWeek: json['days_per_week'] as int? ?? 4,
      age: json['age'] as int? ?? 25,
      heightCm: (json['height_cm'] as num?)?.toDouble() ?? 170.0,
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 65.0,
      fallbackLevel: FitnessLevel.fromString(json['fallback_level'] as String? ?? 'intermediate'),
      readinessFlags: (json['readiness_flags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      proteinFactor: (json['protein_factor'] as num?)?.toDouble() ?? 1.6,
      foodExclusions: (json['food_exclusions'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'goal': goal.name,
        'days_per_week': daysPerWeek,
        'age': age,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'fallback_level': fallbackLevel.name,
        'readiness_flags': readinessFlags,
        'protein_factor': proteinFactor,
        'food_exclusions': foodExclusions,
      };
}

