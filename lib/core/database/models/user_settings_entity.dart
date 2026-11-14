/// Entity UserSettings yang tersimpan langsung di SQLite tabel user_settings
class UserSettingsEntity {
  final String id;
  final String gender;
  final double targetWeightKg;
  final String trainingIntensity;
  final bool workoutReminder;
  final String reminderTime;
  final bool restDayReminder;
  final bool progressCheckin;
  final bool streakReminder;
  final String language;
  final String theme;
  final bool hapticFeedback;
  final bool soundEffects;
  final bool dataSync;
  final DateTime updatedAt;

  const UserSettingsEntity({
    this.id = 'default_settings',
    this.gender = 'Male',
    this.targetWeightKg = 65.0,
    this.trainingIntensity = 'Moderate',
    this.workoutReminder = true,
    this.reminderTime = '08:00 PM',
    this.restDayReminder = true,
    this.progressCheckin = true,
    this.streakReminder = true,
    this.language = 'English',
    this.theme = 'Light',
    this.hapticFeedback = true,
    this.soundEffects = true,
    this.dataSync = false,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gender': gender,
      'target_weight_kg': targetWeightKg,
      'training_intensity': trainingIntensity,
      'workout_reminder': workoutReminder ? 1 : 0,
      'reminder_time': reminderTime,
      'rest_day_reminder': restDayReminder ? 1 : 0,
      'progress_checkin': progressCheckin ? 1 : 0,
      'streak_reminder': streakReminder ? 1 : 0,
      'language': language,
      'theme': theme,
      'haptic_feedback': hapticFeedback ? 1 : 0,
      'sound_effects': soundEffects ? 1 : 0,
      'data_sync': dataSync ? 1 : 0,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserSettingsEntity.fromMap(Map<String, dynamic> map) {
    bool readBool(String key, {required bool fallback}) {
      final value = map[key];
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.toLowerCase().trim();
        if (normalized == 'true' || normalized == '1') return true;
        if (normalized == 'false' || normalized == '0') return false;
      }
      return fallback;
    }

    return UserSettingsEntity(
      id: map['id']?.toString() ?? 'default_settings',
      gender: map['gender']?.toString() ?? 'Male',
      targetWeightKg: (map['target_weight_kg'] as num?)?.toDouble() ?? 65.0,
      trainingIntensity: map['training_intensity']?.toString() ?? 'Moderate',
      workoutReminder: readBool('workout_reminder', fallback: true),
      reminderTime: map['reminder_time']?.toString() ?? '08:00 PM',
      restDayReminder: readBool('rest_day_reminder', fallback: true),
      progressCheckin: readBool('progress_checkin', fallback: true),
      streakReminder: readBool('streak_reminder', fallback: true),
      language: map['language']?.toString() ?? 'English',
      theme: map['theme']?.toString() ?? 'Light',
      hapticFeedback: readBool('haptic_feedback', fallback: true),
      soundEffects: readBool('sound_effects', fallback: true),
      dataSync: readBool('data_sync', fallback: false),
      updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  UserSettingsEntity copyWith({
    String? id,
    String? gender,
    double? targetWeightKg,
    String? trainingIntensity,
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
    DateTime? updatedAt,
  }) {
    return UserSettingsEntity(
      id: id ?? this.id,
      gender: gender ?? this.gender,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      trainingIntensity: trainingIntensity ?? this.trainingIntensity,
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
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

