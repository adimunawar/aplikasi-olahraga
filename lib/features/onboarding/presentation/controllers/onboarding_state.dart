/// Immutable UI state for the 8-step onboarding flow.
class OnboardingState {
  static const int totalSteps = 8;

  final int currentStep;
  final bool isCreatingPlan;
  final String goal;
  final String gender;
  final int age;
  final double heightCm;
  final double currentWeightKg;
  final double targetWeightKg;
  final String level;
  final int daysPerWeek;
  final int durationMin;
  final List<String> equipments;
  final List<String> limitations;

  const OnboardingState({
    this.currentStep = 0,
    this.isCreatingPlan = false,
    this.goal = 'muscle_gain',
    this.gender = 'male',
    this.age = 28,
    this.heightCm = 170.0,
    this.currentWeightKg = 75.0,
    this.targetWeightKg = 82.0,
    this.level = 'beginner',
    this.daysPerWeek = 4,
    this.durationMin = 45,
    this.equipments = const ['bodyweight'],
    this.limitations = const ['none'],
  });

  OnboardingState copyWith({
    int? currentStep,
    bool? isCreatingPlan,
    String? goal,
    String? gender,
    int? age,
    double? heightCm,
    double? currentWeightKg,
    double? targetWeightKg,
    String? level,
    int? daysPerWeek,
    int? durationMin,
    List<String>? equipments,
    List<String>? limitations,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      isCreatingPlan: isCreatingPlan ?? this.isCreatingPlan,
      goal: goal ?? this.goal,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      level: level ?? this.level,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      durationMin: durationMin ?? this.durationMin,
      equipments: equipments ?? this.equipments,
      limitations: limitations ?? this.limitations,
    );
  }
}
