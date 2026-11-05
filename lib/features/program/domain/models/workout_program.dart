import 'package:flutter/foundation.dart';
import '../../../exercises/domain/models/exercise.dart';
import 'program_day.dart';

/// Level / Tingkat Kesulitan Program
enum ProgramDifficulty {
  beginner,
  intermediate,
  advanced;

  String get label {
    switch (this) {
      case ProgramDifficulty.beginner:
        return 'Beginner';
      case ProgramDifficulty.intermediate:
        return 'Intermediate';
      case ProgramDifficulty.advanced:
        return 'Advanced';
    }
  }
}

/// Kategori / Tujuan Program
enum ProgramCategory {
  bulking,
  strength,
  fatLoss,
  core,
  mobility;

  String get label {
    switch (this) {
      case ProgramCategory.bulking:
        return 'Bulking';
      case ProgramCategory.strength:
        return 'Strength';
      case ProgramCategory.fatLoss:
        return 'Fat Loss';
      case ProgramCategory.core:
        return 'Core & Stability';
      case ProgramCategory.mobility:
        return 'Mobility';
    }
  }
}

/// Model Minggu dalam Program (Level 2 dalam Hirarki Program)
@immutable
class ProgramWeek {
  final int weekNumber;
  final String? title; // contoh: 'Foundation', 'Progressive Hypertrophy'
  final List<ProgramDay> days; // 7 hari (Mon - Sun, latihan & rest)

  const ProgramWeek({
    required this.weekNumber,
    this.title,
    required this.days,
  });

  int get workoutDaysCount => days.where((d) => !d.isRest).length;
  int get restDaysCount => days.where((d) => d.isRest).length;

  factory ProgramWeek.fromJson(Map<String, dynamic> json) {
    return ProgramWeek(
      weekNumber: (json['week_number'] as num?)?.toInt() ?? 1,
      title: json['title'] as String? ?? json['focus_theme'] as String?,
      days: ((json['program_days'] ?? json['days']) as List?)
              ?.map((e) => ProgramDay.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'week_number': weekNumber,
        if (title != null) 'title': title,
        'days': days.map((e) => e.toJson()).toList(),
      };
}

/// Model Program Latihan Fleksibel (Single Source of Truth Multi-Program)
/// Mendukung durasi berapa pun (4 minggu, 8 minggu, 12 minggu),
/// frekuensi berapa pun (3, 4, atau 5 hari/minggu), dan berbagai fokus latihan.
@immutable
class WorkoutProgram {
  final String id;
  final LocalizedString title;
  final LocalizedString description;
  final ProgramCategory category;
  final ProgramDifficulty difficulty;
  final int totalWeeks;
  final int daysPerWeek;
  final String bannerAsset;
  final String? coachPoseAsset;
  final List<ProgramWeek> weeks;

  const WorkoutProgram({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.totalWeeks,
    required this.daysPerWeek,
    required this.bannerAsset,
    this.coachPoseAsset,
    required this.weeks,
  });

  WorkoutProgram copyWith({
    String? id,
    LocalizedString? title,
    LocalizedString? description,
    ProgramCategory? category,
    ProgramDifficulty? difficulty,
    int? totalWeeks,
    int? daysPerWeek,
    String? bannerAsset,
    String? coachPoseAsset,
    List<ProgramWeek>? weeks,
  }) {
    return WorkoutProgram(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      bannerAsset: bannerAsset ?? this.bannerAsset,
      coachPoseAsset: coachPoseAsset ?? this.coachPoseAsset,
      weeks: weeks ?? this.weeks,
    );
  }

  /// Total seluruh sesi latihan dalam program ini (tidak termasuk rest day)
  int get totalWorkouts => totalWeeks * daysPerWeek;

  /// Hitung persentase progres program (0.0 - 1.0)
  double calculateProgress(int completedDays) {
    if (totalWorkouts <= 0) return 0.0;
    return (completedDays / totalWorkouts).clamp(0.0, 1.0);
  }

  /// Ambil jadwal minggu tertentu (misal Week 3)
  ProgramWeek? getWeek(int weekNumber) {
    try {
      return weeks.firstWhere((w) => w.weekNumber == weekNumber);
    } catch (_) {
      return weeks.isNotEmpty ? weeks.first : null;
    }
  }

  factory WorkoutProgram.fromJson(Map<String, dynamic> json) {
    final parsedTitle = _parseLocalizedString(json, 'title');
    final parsedDesc = _parseLocalizedString(json, 'description');

    return WorkoutProgram(
      id: json['id'] as String? ?? 'upper_body_strength',
      title: parsedTitle.en.isNotEmpty ? parsedTitle : _fallbackTitle(json['id']?.toString()),
      description: parsedDesc.en.isNotEmpty
          ? parsedDesc
          : const LocalizedString(
              id: 'Program latihan terstruktur untuk membentuk otot di rumah.',
              en: 'Structured workout program to build strength and muscle at home.',
            ),
      category: _parseCategory(json['category'] as String?),
      difficulty: _parseDifficulty(json['difficulty'] as String?),
      totalWeeks: (json['total_weeks'] as num?)?.toInt() ?? 8,
      daysPerWeek: (json['days_per_week'] as num?)?.toInt() ?? 4,
      bannerAsset: json['banner_asset'] as String? ??
          json['banner_url'] as String? ??
          'assets/images/Home Workout Push-Up Guide.png',
      coachPoseAsset: json['coach_pose_asset'] as String? ?? json['coach_pose_url'] as String?,
      weeks: ((json['program_weeks'] ?? json['weeks']) as List?)
              ?.map((e) => ProgramWeek.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );
  }

  static LocalizedString _parseLocalizedString(Map<String, dynamic> json, String key) {
    final direct = json[key];
    if (direct is Map) {
      final id = direct['id']?.toString() ?? '';
      final en = direct['en']?.toString() ?? id;
      return LocalizedString(id: id, en: en);
    }
    if (direct is String && direct.isNotEmpty) {
      return LocalizedString(id: direct, en: direct);
    }

    final enVal = json['${key}_en']?.toString();
    final idVal = json['${key}_id']?.toString();
    if ((enVal != null && enVal.isNotEmpty) || (idVal != null && idVal.isNotEmpty)) {
      return LocalizedString(
        id: (idVal != null && idVal.isNotEmpty) ? idVal : (enVal ?? ''),
        en: (enVal != null && enVal.isNotEmpty) ? enVal : (idVal ?? ''),
      );
    }

    return const LocalizedString(id: '', en: '');
  }

  static LocalizedString _fallbackTitle(String? id) {
    if (id == null || id.isEmpty) {
      return const LocalizedString(id: 'Upper Body Strength', en: 'Upper Body Strength');
    }
    final formatted = id
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
    return LocalizedString(id: formatted, en: formatted);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': {'id': title.id, 'en': title.en},
        'description': {'id': description.id, 'en': description.en},
        'category': category.name,
        'difficulty': difficulty.name,
        'total_weeks': totalWeeks,
        'days_per_week': daysPerWeek,
        'banner_asset': bannerAsset,
        if (coachPoseAsset != null) 'coach_pose_asset': coachPoseAsset,
        'weeks': weeks.map((w) => w.toJson()).toList(),
      };

  static ProgramCategory _parseCategory(String? val) {
    switch (val?.toLowerCase().trim()) {
      case 'strength':
        return ProgramCategory.strength;
      case 'fat_loss':
        return ProgramCategory.fatLoss;
      case 'core':
        return ProgramCategory.core;
      case 'mobility':
        return ProgramCategory.mobility;
      case 'bulking':
      default:
        return ProgramCategory.bulking;
    }
  }

  static ProgramDifficulty _parseDifficulty(String? val) {
    switch (val?.toLowerCase().trim()) {
      case 'intermediate':
        return ProgramDifficulty.intermediate;
      case 'advanced':
        return ProgramDifficulty.advanced;
      case 'beginner':
      default:
        return ProgramDifficulty.beginner;
    }
  }
}

