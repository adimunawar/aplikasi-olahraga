import 'dart:convert';

/// Entity UserProfile (PRD Bagian 14 & ONB-01 s/d ONB-10)
class UserProfileEntity {
  final String id;
  final String displayName;
  final String gender;
  final int age;
  final double heightCm;
  final double currentWeightKg;
  final double targetWeightKg;
  final int targetTimeframeWeeks;
  final String goal;
  final String experienceLevel;
  final int preferredDurationMin;
  final int preferredDaysPerWeek;
  final int weeklyFrequency;
  final List<String> availableDays;
  final List<String> trainingLimitations;
  final String? timezone;
  final String unitPreference;
  final List<String> equipments;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfileEntity({
    required this.id,
    required this.displayName,
    this.gender = 'male',
    required this.age,
    required this.heightCm,
    required this.currentWeightKg,
    this.targetWeightKg = 82.0,
    this.targetTimeframeWeeks = 12,
    this.goal = 'muscle_gain',
    this.experienceLevel = 'beginner',
    this.preferredDurationMin = 45,
    this.preferredDaysPerWeek = 4,
    this.weeklyFrequency = 4,
    this.availableDays = const ['monday', 'wednesday', 'friday', 'sunday'],
    this.trainingLimitations = const ['none'],
    this.timezone,
    this.unitPreference = 'metric',
    required this.equipments,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'display_name': displayName,
      'gender': gender,
      'age': age,
      'height_cm': heightCm,
      'current_weight_kg': currentWeightKg,
      'target_weight_kg': targetWeightKg,
      'target_timeframe_weeks': targetTimeframeWeeks,
      'goal': goal,
      'experience_level': experienceLevel,
      'preferred_duration_min': preferredDurationMin,
      'preferred_days_per_week': preferredDaysPerWeek,
      'weekly_frequency': weeklyFrequency,
      'available_days': jsonEncode(availableDays),
      'training_limitations': jsonEncode(trainingLimitations),
      'timezone': timezone,
      'unit_preference': unitPreference,
      'equipments': jsonEncode(equipments),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserProfileEntity.fromMap(Map<String, dynamic> map) {
    List<String> parseStringList(
      dynamic raw, {
      required List<String> fallback,
    }) {
      if (raw is List) {
        return raw.map((value) => value.toString()).toList();
      }

      if (raw is String) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is List) {
            return decoded.map((value) => value.toString()).toList();
          }
        } catch (_) {
          return raw
              .split(',')
              .map((value) => value.trim())
              .where((value) => value.isNotEmpty)
              .toList();
        }
      }

      return fallback;
    }

    final parsedEquipments = parseStringList(
      map['equipments'],
      fallback: const ['bodyweight', 'dumbbell'],
    );
    final parsedAvailableDays = parseStringList(
      map['available_days'],
      fallback: const ['monday', 'wednesday', 'friday'],
    );
    final parsedLimitations = parseStringList(
      map['training_limitations'],
      fallback: const [],
    );

    final freq = (map['weekly_frequency'] as num?)?.toInt() ??
        (map['preferred_days_per_week'] as num?)?.toInt() ??
        3;

    return UserProfileEntity(
      id: map['id']?.toString() ?? 'default_user',
      displayName: map['display_name']?.toString() ?? 'User',
      gender: map['gender']?.toString() ?? 'male',
      age: (map['age'] as num?)?.toInt() ?? 28,
      heightCm: (map['height_cm'] as num?)?.toDouble() ?? 170.0,
      currentWeightKg: (map['current_weight_kg'] as num?)?.toDouble() ?? 75.0,
      targetWeightKg: (map['target_weight_kg'] as num?)?.toDouble() ?? 82.0,
      targetTimeframeWeeks: (map['target_timeframe_weeks'] as num?)?.toInt() ?? 12,
      goal: map['goal']?.toString() ?? 'muscle_gain',
      experienceLevel: map['experience_level']?.toString() ?? 'beginner',
      preferredDurationMin: (map['preferred_duration_min'] as num?)?.toInt() ?? 45,
      preferredDaysPerWeek: freq,
      weeklyFrequency: freq,
      availableDays: parsedAvailableDays,
      trainingLimitations: parsedLimitations,
      timezone: map['timezone']?.toString(),
      unitPreference: map['unit_preference']?.toString() ?? 'metric',
      equipments: parsedEquipments.isNotEmpty
          ? parsedEquipments
          : ['bodyweight', 'dumbbell'],
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  UserProfileEntity copyWith({
    String? id,
    String? displayName,
    String? gender,
    int? age,
    double? heightCm,
    double? currentWeightKg,
    double? targetWeightKg,
    int? targetTimeframeWeeks,
    String? goal,
    String? experienceLevel,
    int? preferredDurationMin,
    int? preferredDaysPerWeek,
    int? weeklyFrequency,
    List<String>? availableDays,
    List<String>? trainingLimitations,
    String? timezone,
    String? unitPreference,
    List<String>? equipments,
    DateTime? updatedAt,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      targetTimeframeWeeks: targetTimeframeWeeks ?? this.targetTimeframeWeeks,
      goal: goal ?? this.goal,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      preferredDurationMin: preferredDurationMin ?? this.preferredDurationMin,
      preferredDaysPerWeek: preferredDaysPerWeek ?? this.preferredDaysPerWeek,
      weeklyFrequency: weeklyFrequency ?? this.weeklyFrequency,
      availableDays: availableDays ?? this.availableDays,
      trainingLimitations: trainingLimitations ?? this.trainingLimitations,
      timezone: timezone ?? this.timezone,
      unitPreference: unitPreference ?? this.unitPreference,
      equipments: equipments ?? this.equipments,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Convenience aliases
  int get durationPreferenceMinutes => preferredDurationMin;
  List<String> get availableEquipment => equipments;
}

