/// Immutable state untuk layar Profile dan seluruh sub-halaman editnya
class ProfileState {
  final String displayName;
  final String journeyStatus;
  final int age;
  final String gender;
  final double currentWeight;
  final double currentHeight;
  final double currentBmi;
  final double targetWeight;
  final String goal;
  final String experienceLevel;
  final int preferredDaysPerWeek;
  final int preferredDurationMin;
  final String trainingIntensity;
  final String unitPreference;

  // Reminders Settings
  final bool workoutReminder;
  final String reminderTime;
  final bool restDayReminder;
  final bool progressCheckin;
  final bool streakReminder;

  // App Settings
  final String language;
  final String theme;
  final bool hapticFeedback;
  final bool soundEffects;
  final bool dataSync;

  final String lastUpdatedDate;
  final bool isLoading;
  final String? errorMessage;

  const ProfileState({
    this.displayName = 'Adi Munawar',
    this.journeyStatus = 'Bulking journey • Beginner',
    this.age = 29,
    this.gender = 'male',
    this.currentWeight = 58.0,
    this.currentHeight = 174.0,
    this.currentBmi = 19.2,
    this.targetWeight = 65.0,
    this.goal = 'Build Muscle (Bulking)',
    this.experienceLevel = 'Beginner',
    this.preferredDaysPerWeek = 4,
    this.preferredDurationMin = 45,
    this.trainingIntensity = 'Moderate',
    this.unitPreference = 'Metric (kg, cm)',
    this.workoutReminder = true,
    this.reminderTime = '08:00 PM',
    this.restDayReminder = true,
    this.progressCheckin = true,
    this.streakReminder = true,
    this.language = 'English',
    this.theme = 'Light',
    this.hapticFeedback = true,
    this.soundEffects = true,
    this.dataSync = true,
    this.lastUpdatedDate = 'Nov 5, 2026',
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    String? displayName,
    String? journeyStatus,
    int? age,
    String? gender,
    double? currentWeight,
    double? currentHeight,
    double? currentBmi,
    double? targetWeight,
    String? goal,
    String? experienceLevel,
    int? preferredDaysPerWeek,
    int? preferredDurationMin,
    String? trainingIntensity,
    String? unitPreference,
    bool? workoutReminder,
    String? reminderTime,
    bool? restDayReminder,
    bool? progressCheckin,
    bool? streakReminder,
    String? language,
    String? theme,
    bool? hapticFeedback,
    bool? soundEffects,
    bool? dataSync,
    String? lastUpdatedDate,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState(
      displayName: displayName ?? this.displayName,
      journeyStatus: journeyStatus ?? this.journeyStatus,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      currentWeight: currentWeight ?? this.currentWeight,
      currentHeight: currentHeight ?? this.currentHeight,
      currentBmi: currentBmi ?? this.currentBmi,
      targetWeight: targetWeight ?? this.targetWeight,
      goal: goal ?? this.goal,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      preferredDaysPerWeek: preferredDaysPerWeek ?? this.preferredDaysPerWeek,
      preferredDurationMin: preferredDurationMin ?? this.preferredDurationMin,
      trainingIntensity: trainingIntensity ?? this.trainingIntensity,
      unitPreference: unitPreference ?? this.unitPreference,
      workoutReminder: workoutReminder ?? this.workoutReminder,
      reminderTime: reminderTime ?? this.reminderTime,
      restDayReminder: restDayReminder ?? this.restDayReminder,
      progressCheckin: progressCheckin ?? this.progressCheckin,
      streakReminder: streakReminder ?? this.streakReminder,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      soundEffects: soundEffects ?? this.soundEffects,
      dataSync: dataSync ?? this.dataSync,
      lastUpdatedDate: lastUpdatedDate ?? this.lastUpdatedDate,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
