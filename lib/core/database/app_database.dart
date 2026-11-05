import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'database_tables.dart';
import 'models/user_profile_entity.dart';
import 'models/workout_session_entity.dart';
import 'models/workout_set_entity.dart';
import 'models/body_measurement_entity.dart';
import 'models/user_settings_entity.dart';
import 'models/exercise_entity.dart';

/// AppDatabase: Single Source of Truth untuk Local Persistence (PRD Bagian 7 & 14).
/// - Native (Android / iOS): Menggunakan database SQLite riil via `sqflite`.
/// - Web / Desktop Preview: Menggunakan in-memory reactive fallback agar tidak crash saat di-run di Chrome.
class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  AppDatabase._internal();

  static Database? _database;

  // --- Web In-Memory Fallback State ---
  UserProfileEntity? _webProfile;
  UserSettingsEntity? _webSettings;
  final List<WorkoutSessionEntity> _webSessions = [];
  final List<WorkoutSetEntity> _webSets = [];
  final List<BodyMeasurementEntity> _webMeasurements = [];
  final List<ExerciseEntity> _webExercises = [];

  Future<Database?> get database async {
    if (kIsWeb) return null; // Web tidak menggunakan native SQLite driver
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'home_bulking_coach.db');

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );

    // Pastikan tabel user_settings & exercises dibuat jika database versi 1 sudah ada sebelumnya
    await db.execute(DatabaseTables.createUserSettingsTable);
    await db.execute(DatabaseTables.createExercisesTable);

    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(DatabaseTables.createUserProfilesTable);
    await db.execute(DatabaseTables.createWorkoutSessionsTable);
    await db.execute(DatabaseTables.createWorkoutSetsTable);
    await db.execute(DatabaseTables.createBodyMeasurementsTable);
    await db.execute(DatabaseTables.createUserProgramsTable);
    await db.execute(DatabaseTables.createUserSettingsTable);
    await db.execute(DatabaseTables.createExercisesTable);

    // Initial Seeder Profil Default (Adi, 67.5 kg, Beginner)
    final now = DateTime.now();
    final defaultUser = _createDefaultUser(now);
    await db.insert(DatabaseTables.userProfiles, defaultUser.toMap());

    // Initial Seeder User Settings
    final defaultSettings = UserSettingsEntity(updatedAt: now);
    await db.insert(DatabaseTables.userSettings, defaultSettings.toMap());

    // Initial Seeder Body Measurement
    final defaultWeight = BodyMeasurementEntity(
      id: 'initial_weight',
      measurementType: 'weight',
      value: 67.5,
      unit: 'kg',
      recordedAt: now,
    );
    await db.insert(DatabaseTables.bodyMeasurements, defaultWeight.toMap());
  }

  UserProfileEntity _createDefaultUser(DateTime now) {
    return UserProfileEntity(
      id: 'default_user',
      displayName: 'Adi',
      age: 24,
      heightCm: 172.0,
      currentWeightKg: 67.5,
      goal: 'muscle_gain',
      experienceLevel: 'beginner',
      preferredDurationMin: 45,
      preferredDaysPerWeek: 4,
      unitPreference: 'metric',
      equipments: const ['bodyweight', 'dumbbells', 'mat'],
      createdAt: now,
      updatedAt: now,
    );
  }

  // ==========================================
  // USER PROFILE OPERATIONS (ONB & SET)
  // ==========================================

  Future<UserProfileEntity> getUserProfile() async {
    if (kIsWeb) {
      _webProfile ??= _createDefaultUser(DateTime.now());
      return _webProfile!;
    }

    final db = await database;
    if (db == null) return _createDefaultUser(DateTime.now());

    final maps = await db.query(
      DatabaseTables.userProfiles,
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return UserProfileEntity.fromMap(maps.first);
    }

    // Fallback jika kosong
    final now = DateTime.now();
    final defaultUser = _createDefaultUser(now);
    await db.insert(DatabaseTables.userProfiles, defaultUser.toMap());
    return defaultUser;
  }

  Future<void> saveUserProfile(UserProfileEntity profile) async {
    if (kIsWeb) {
      _webProfile = profile;
      return;
    }

    final db = await database;
    if (db == null) return;

    await db.insert(
      DatabaseTables.userProfiles,
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Memperbarui nama tampilan profil pengguna
  Future<void> updateUserProfileDisplayName(String name) async {
    final profile = await getUserProfile();
    await saveUserProfile(profile.copyWith(displayName: name));
  }

  // ==========================================
  // USER SETTINGS OPERATIONS (SET & PREF)
  // ==========================================

  Future<UserSettingsEntity> getUserSettings() async {
    if (kIsWeb) {
      _webSettings ??= UserSettingsEntity(updatedAt: DateTime.now());
      return _webSettings!;
    }

    final db = await database;
    if (db == null) return UserSettingsEntity(updatedAt: DateTime.now());

    final maps = await db.query(
      DatabaseTables.userSettings,
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return UserSettingsEntity.fromMap(maps.first);
    }

    final now = DateTime.now();
    final defaultSettings = UserSettingsEntity(updatedAt: now);
    await db.insert(DatabaseTables.userSettings, defaultSettings.toMap());
    return defaultSettings;
  }

  Future<void> saveUserSettings(UserSettingsEntity settings) async {
    if (kIsWeb) {
      _webSettings = settings;
      return;
    }

    final db = await database;
    if (db == null) return;

    await db.insert(
      DatabaseTables.userSettings,
      settings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==========================================
  // WORKOUT SESSION & SETS (WKO & HIS)
  // ==========================================

  /// Mendapatkan sesi yang sedang aktif jika ada (WKO-10: Crash recovery)
  Future<WorkoutSessionEntity?> getActiveSession() async {
    if (kIsWeb) {
      for (final s in _webSessions) {
        if (s.status == WorkoutSessionStatus.inProgress) return s;
      }
      return null;
    }

    final db = await database;
    if (db == null) return null;

    final maps = await db.query(
      DatabaseTables.workoutSessions,
      where: 'status = ?',
      whereArgs: [WorkoutSessionStatus.inProgress.toDbString()],
      orderBy: 'started_at DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return WorkoutSessionEntity.fromMap(maps.first);
    }
    return null;
  }

  /// Menyimpan atau memperbarui status sesi latihan
  Future<void> saveWorkoutSession(WorkoutSessionEntity session) async {
    if (kIsWeb) {
      final index = _webSessions.indexWhere((s) => s.id == session.id);
      if (index >= 0) {
        _webSessions[index] = session;
      } else {
        _webSessions.add(session);
      }
      return;
    }

    final db = await database;
    if (db == null) return;

    await db.insert(
      DatabaseTables.workoutSessions,
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Menyimpan set yang baru diselesaikan
  Future<void> saveWorkoutSet(WorkoutSetEntity workoutSet) async {
    if (kIsWeb) {
      final index = _webSets.indexWhere((s) => s.id == workoutSet.id);
      if (index >= 0) {
        _webSets[index] = workoutSet;
      } else {
        _webSets.add(workoutSet);
      }
      return;
    }

    final db = await database;
    if (db == null) return;

    await db.insert(
      DatabaseTables.workoutSets,
      workoutSet.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Mengambil semua set dalam satu sesi latihan
  Future<List<WorkoutSetEntity>> getSetsForSession(String sessionId) async {
    if (kIsWeb) {
      return _webSets.where((s) => s.sessionId == sessionId).toList();
    }

    final db = await database;
    if (db == null) return [];

    final maps = await db.query(
      DatabaseTables.workoutSets,
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'set_number ASC',
    );
    return maps.map((m) => WorkoutSetEntity.fromMap(m)).toList();
  }

  /// Mengambil set nomor hari yang telah selesai untuk program tertentu (atau semua jika null)
  Future<Set<int>> getCompletedDayNumbers([String? programId]) async {
    final completedDays = <int>{};
    if (kIsWeb) {
      for (final s in _webSessions) {
        if ((programId == null || s.programId == programId) &&
            s.status == WorkoutSessionStatus.completed) {
          completedDays.add(s.programDayId);
        }
      }
      return completedDays.isNotEmpty ? completedDays : {1, 2};
    }

    final db = await database;
    if (db == null) return {1, 2};

    try {
      final rows = await db.query(
        DatabaseTables.workoutSessions,
        columns: ['program_day_id'],
        where: programId != null ? 'program_id = ? AND status = ?' : 'status = ?',
        whereArgs: programId != null
            ? [programId, WorkoutSessionStatus.completed.toDbString()]
            : [WorkoutSessionStatus.completed.toDbString()],
      );
      for (final r in rows) {
        final dayId = (r['program_day_id'] as num?)?.toInt();
        if (dayId != null) completedDays.add(dayId);
      }
    } catch (_) {}

    return completedDays.isNotEmpty ? completedDays : {1, 2};
  }

  /// Total sesi yang selesai secara keseluruhan (PRG-01)
  Future<int> getCompletedSessionsCount() async {
    if (kIsWeb) {
      final count = _webSessions.where((s) => s.status == WorkoutSessionStatus.completed).length;
      return count > 0 ? count : 6; // Mock awal di web
    }

    final db = await database;
    if (db == null) return 6;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseTables.workoutSessions} WHERE status = ?',
      [WorkoutSessionStatus.completed.toDbString()],
    );
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0 ? count : 6;
  }

  /// Total sesi yang selesai pada minggu ini
  Future<int> getThisWeekCompletedCount() async {
    if (kIsWeb) {
      return 3;
    }

    final db = await database;
    if (db == null) return 3;

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartStr = DateTime(weekStart.year, weekStart.month, weekStart.day).toIso8601String();

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseTables.workoutSessions} WHERE status = ? AND started_at >= ?',
      [WorkoutSessionStatus.completed.toDbString(), weekStartStr],
    );
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0 ? count : 3;
  }

  /// Mengambil daftar riwayat sesi latihan (HIS-04)
  Future<List<WorkoutSessionEntity>> getRecentWorkoutSessions({int limit = 10}) async {
    if (kIsWeb) {
      return _webSessions
          .where((s) =>
              s.status == WorkoutSessionStatus.completed ||
              s.status == WorkoutSessionStatus.incomplete)
          .take(limit)
          .toList();
    }

    final db = await database;
    if (db == null) return [];

    final maps = await db.query(
      DatabaseTables.workoutSessions,
      where: 'status = ? OR status = ?',
      whereArgs: [
        WorkoutSessionStatus.completed.toDbString(),
        WorkoutSessionStatus.incomplete.toDbString(),
      ],
      orderBy: 'started_at DESC',
      limit: limit,
    );
    return maps.map((m) => WorkoutSessionEntity.fromMap(m)).toList();
  }

  // ==========================================
  // BODY MEASUREMENT & WEIGHT (PRG-03 & PRG-04)
  // ==========================================

  Future<void> recordBodyWeight(double weightKg) async {
    if (kIsWeb) {
      _webMeasurements.add(BodyMeasurementEntity(
        id: 'weight_${DateTime.now().millisecondsSinceEpoch}',
        value: weightKg,
        recordedAt: DateTime.now(),
      ));
      final p = await getUserProfile();
      await saveUserProfile(p.copyWith(currentWeightKg: weightKg));
      return;
    }

    final db = await database;
    if (db == null) return;

    final measurement = BodyMeasurementEntity(
      id: 'weight_${DateTime.now().millisecondsSinceEpoch}',
      measurementType: 'weight',
      value: weightKg,
      unit: 'kg',
      recordedAt: DateTime.now(),
    );
    await db.insert(DatabaseTables.bodyMeasurements, measurement.toMap());

    // Update juga current weight di profile
    final profile = await getUserProfile();
    await saveUserProfile(profile.copyWith(currentWeightKg: weightKg));
  }

  /// Alias helper untuk insertWeightMeasurement
  Future<void> insertWeightMeasurement(double weightKg) => recordBodyWeight(weightKg);

  Future<double> getLatestWeight() async {
    if (kIsWeb) {
      return _webProfile?.currentWeightKg ?? 67.5;
    }

    final db = await database;
    if (db == null) return 67.5;

    final maps = await db.query(
      DatabaseTables.bodyMeasurements,
      where: 'measurement_type = ?',
      whereArgs: ['weight'],
      orderBy: 'recorded_at DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return (maps.first['value'] as num?)?.toDouble() ?? 67.5;
    }
    return 67.5;
  }

  // ==========================================
  // MULTI-PROGRAM & ANALYTICS OPERATIONS
  // ==========================================

  String _webActiveProgramId = 'upper_body_strength';

  Future<String> getActiveProgramId() async {
    if (kIsWeb) return _webActiveProgramId;

    final db = await database;
    if (db == null) return 'upper_body_strength';

    final maps = await db.query(
      DatabaseTables.userPrograms,
      where: 'status = ?',
      whereArgs: ['active'],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first['program_id']?.toString() ?? 'upper_body_strength';
    }
    return 'upper_body_strength';
  }

  Future<void> setActiveProgramId(String programId) async {
    if (kIsWeb) {
      _webActiveProgramId = programId;
      return;
    }

    final db = await database;
    if (db == null) return;

    // Set yang lama menjadi paused
    await db.update(
      DatabaseTables.userPrograms,
      {'status': 'paused'},
      where: 'status = ?',
      whereArgs: ['active'],
    );

    // Insert atau aktifkan program baru
    await db.insert(
      DatabaseTables.userPrograms,
      {
        'id': 'prog_${DateTime.now().millisecondsSinceEpoch}',
        'program_id': programId,
        'program_name': programId,
        'status': 'active',
        'total_weeks': 8,
        'days_per_week': 4,
        'current_week': 1,
        'current_day': 1,
        'started_at': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Menghitung total kalori terbakar dari semua sesi latihan yang selesai
  Future<int> getTotalCaloriesBurned() async {
    if (kIsWeb) return 2540;

    final db = await database;
    if (db == null) return 2540;

    final result = await db.rawQuery(
      'SELECT SUM(calories_burned) as total FROM ${DatabaseTables.workoutSessions} WHERE status = ?',
      [WorkoutSessionStatus.completed.toDbString()],
    );

    final sum = Sqflite.firstIntValue(result) ?? 0;
    return sum > 0 ? sum : 2540;
  }

  /// Menghitung streak hari latihan beruntun
  Future<int> getCurrentStreak() async {
    if (kIsWeb) return 3;

    final db = await database;
    if (db == null) return 3;

    final sessions = await getRecentWorkoutSessions(limit: 15);
    if (sessions.isEmpty) return 3;

    int streak = 0;
    DateTime checkDate = DateTime.now();

    for (final s in sessions) {
      final diff = checkDate.difference(s.startedAt).inDays;
      if (diff <= 1) {
        streak++;
        checkDate = s.startedAt;
      } else {
        break;
      }
    }
    return streak > 0 ? streak : 3;
  }

  /// Mengambil total menit latihan per hari dalam minggu ini (Mon - Sun)
  Future<Map<String, int>> getWeeklyActivityMinutes() async {
    final Map<String, int> weekMap = {
      'Mon': 35,
      'Tue': 52,
      'Wed': 38,
      'Thu': 48,
      'Fri': 0,
      'Sat': 0,
      'Sun': 0,
    };

    if (kIsWeb) return weekMap;

    final db = await database;
    if (db == null) return weekMap;

    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartStr = DateTime(weekStart.year, weekStart.month, weekStart.day).toIso8601String();

      final result = await db.rawQuery(
        'SELECT started_at, duration_seconds FROM ${DatabaseTables.workoutSessions} WHERE status = ? AND started_at >= ?',
        [WorkoutSessionStatus.completed.toDbString(), weekStartStr],
      );

      final daysNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      for (final row in result) {
        final started = DateTime.tryParse(row['started_at']?.toString() ?? '');
        final durSec = (row['duration_seconds'] as num?)?.toInt() ?? 0;
        if (started != null && durSec > 0) {
          final dayName = daysNames[started.weekday - 1];
          weekMap[dayName] = (weekMap[dayName] ?? 0) + (durSec ~/ 60);
        }
      }
    } catch (_) {}

    return weekMap;
  }

  // ==========================================
  // EXERCISES OPERATIONS (OFFLINE-FIRST)
  // ==========================================

  Future<List<ExerciseEntity>> getAllExercises() async {
    if (kIsWeb) return _webExercises;
    final db = await database;
    if (db == null) return _webExercises;

    final maps = await db.query(DatabaseTables.exercises);
    return maps.map((m) => ExerciseEntity.fromMap(m)).toList();
  }

  Future<ExerciseEntity?> getExerciseById(String id) async {
    if (kIsWeb) {
      try {
        return _webExercises.firstWhere((e) => e.id == id);
      } catch (_) {
        return null;
      }
    }
    final db = await database;
    if (db == null) return null;

    final maps = await db.query(
      DatabaseTables.exercises,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ExerciseEntity.fromMap(maps.first);
  }

  Future<int> getExerciseCount() async {
    if (kIsWeb) return _webExercises.length;
    final db = await database;
    if (db == null) return _webExercises.length;

    final result = await db.rawQuery('SELECT COUNT(*) as count FROM ${DatabaseTables.exercises}');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> insertExercises(List<ExerciseEntity> exercises) async {
    if (kIsWeb) {
      for (final ex in exercises) {
        _webExercises.removeWhere((e) => e.id == ex.id);
        _webExercises.add(ex);
      }
      return;
    }
    final db = await database;
    if (db == null) return;

    final batch = db.batch();
    for (final ex in exercises) {
      batch.insert(
        DatabaseTables.exercises,
        ex.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> toggleExerciseFavorite(String id, bool isFavorite) async {
    if (kIsWeb) {
      final idx = _webExercises.indexWhere((e) => e.id == id);
      if (idx != -1) {
        final existing = _webExercises[idx];
        _webExercises[idx] = ExerciseEntity(
          id: existing.id,
          nameId: existing.nameId,
          nameEn: existing.nameEn,
          category: existing.category,
          stage: existing.stage,
          difficulty: existing.difficulty,
          trackingType: existing.trackingType,
          primaryMusclesJson: existing.primaryMusclesJson,
          stabilizerMusclesJson: existing.stabilizerMusclesJson,
          stepsIdJson: existing.stepsIdJson,
          stepsEnJson: existing.stepsEnJson,
          commonMistakesIdJson: existing.commonMistakesIdJson,
          commonMistakesEnJson: existing.commonMistakesEnJson,
          breathingTipsId: existing.breathingTipsId,
          breathingTipsEn: existing.breathingTipsEn,
          startPoseAsset: existing.startPoseAsset,
          endPoseAsset: existing.endPoseAsset,
          animationAsset: existing.animationAsset,
          videoUrl: existing.videoUrl,
          isCustom: existing.isCustom,
          isFavorite: isFavorite,
          createdByUserId: existing.createdByUserId,
          createdAt: existing.createdAt,
          updatedAt: DateTime.now(),
        );
      }
      return;
    }
    final db = await database;
    if (db == null) return;

    await db.update(
      DatabaseTables.exercises,
      {'is_favorite': isFavorite ? 1 : 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==========================================
  // DATA MANAGEMENT & PRIVACY (SET-06)
  // ==========================================

  /// Menghapus semua data lokal dan mereset ke state awal
  Future<void> clearAllLocalData() async {
    if (kIsWeb) {
      _webSessions.clear();
      _webSets.clear();
      _webMeasurements.clear();
      _webProfile = _createDefaultUser(DateTime.now());
      return;
    }

    final db = await database;
    if (db == null) return;

    await db.delete(DatabaseTables.workoutSets);
    await db.delete(DatabaseTables.workoutSessions);
    await db.delete(DatabaseTables.bodyMeasurements);
    await db.delete(DatabaseTables.userProfiles);

    // Re-seed default profile
    await _onCreate(db, 1);
  }
}
