import 'dart:convert';

/// Entity UserProfile (PRD Bagian 14 & ONB-01 s/d ONB-10)
class UserProfileEntity {
  final String id;
  final String displayName;
  final int age;
  final double heightCm;
  final double currentWeightKg;
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
    required this.age,
    required this.heightCm,
    required this.currentWeightKg,
    this.goal = 'muscle_gain',
    this.experienceLevel = 'beginner',
    this.preferredDurationMin = 45,
    this.preferredDaysPerWeek = 3,
    this.weeklyFrequency = 3,
    this.availableDays = const ['monday', 'wednesday', 'friday'],
    this.trainingLimitations = const [],
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
      'age': age,
      'height_cm': heightCm,
      'current_weight_kg': currentWeightKg,
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
    List<String> parsedEquipments = [];
    final eq = map['equipments'];
    if (eq is String) {
      try {
        final decoded = jsonDecode(eq);
        if (decoded is List) {
          parsedEquipments = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {
        parsedEquipments = eq.split(',').map((s) => s.trim()).toList();
      }
    }

    List<String> parsedAvailableDays = ['monday', 'wednesday', 'friday'];
    final rawDays = map['available_days'];
    if (rawDays is String) {
      try {
        final decoded = jsonDecode(rawDays);
        if (decoded is List) {
          parsedAvailableDays = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }

    List<String> parsedLimitations = [];
    final rawLimit = map['training_limitations'];
    if (rawLimit is String) {
      try {
        final decoded = jsonDecode(rawLimit);
        if (decoded is List) {
          parsedLimitations = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }

    final freq = (map['weekly_frequency'] as num?)?.toInt() ??
        (map['preferred_days_per_week'] as num?)?.toInt() ??
        3;

    return UserProfileEntity(
      id: map['id']?.toString() ?? 'default_user',
      displayName: map['display_name']?.toString() ?? 'Adi',
      age: (map['age'] as num?)?.toInt() ?? 24,
      heightCm: (map['height_cm'] as num?)?.toDouble() ?? 172.0,
      currentWeightKg: (map['current_weight_kg'] as num?)?.toDouble() ?? 67.5,
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
          : ['bodyweight', 'dumbbells', 'mat'],
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
    int? age,
    double? heightCm,
    double? currentWeightKg,
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
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
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
}

