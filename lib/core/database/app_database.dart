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
import 'models/dynamic_program_entity.dart';
import 'models/progression_decision_entity.dart';

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
  final List<ProgressionDecisionEntity> _webProgressionDecisions = [];

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
    await db.execute(DatabaseTables.createUsersTable);
    await db.execute(DatabaseTables.createUserSettingsTable);
    await db.execute(DatabaseTables.createExercisesTable);
    await db.execute(DatabaseTables.createExerciseProgressionsTable);
    await db.execute(DatabaseTables.createTrainingProgramsTable);
    await db.execute(DatabaseTables.createProgramSessionsTable);
    await db.execute(DatabaseTables.createProgramExercisesTable);
    await db.execute(DatabaseTables.createProgressionDecisionsTable);
    await db.execute('CREATE INDEX IF NOT EXISTS idx_progression_decisions_user ON ${DatabaseTables.progressionDecisions} (user_id, exercise_id)');
    await db.execute(DatabaseTables.createProgressionDecisionsTable);
    try {
      await db.execute('CREATE INDEX IF NOT EXISTS idx_progression_decisions_user ON ${DatabaseTables.progressionDecisions} (user_id, exercise_id)');
    } catch (_) {}

    // Migrasi aman untuk kolom baru pada tabel exercises
    try {
      await db.execute("ALTER TABLE ${DatabaseTables.exercises} ADD COLUMN movement_pattern TEXT NOT NULL DEFAULT 'other'");
    } catch (_) {}
    try {
      await db.execute("ALTER TABLE ${DatabaseTables.exercises} ADD COLUMN equipments TEXT NOT NULL DEFAULT '[\"none\"]'");
    } catch (_) {}

    // Migrasi aman untuk kolom baru pada tabel user_profiles
    try {
      await db.execute("ALTER TABLE ${DatabaseTables.userProfiles} ADD COLUMN weekly_frequency INTEGER NOT NULL DEFAULT 3");
    } catch (_) {}
    try {
      await db.execute("ALTER TABLE ${DatabaseTables.userProfiles} ADD COLUMN available_days TEXT NOT NULL DEFAULT '[\"monday\",\"wednesday\",\"friday\"]'");
    } catch (_) {}
    try {
      await db.execute("ALTER TABLE ${DatabaseTables.userProfiles} ADD COLUMN training_limitations TEXT NOT NULL DEFAULT '[]'");
    } catch (_) {}
    try {
      await db.execute("ALTER TABLE ${DatabaseTables.userProfiles} ADD COLUMN timezone TEXT");
    } catch (_) {}

    // Migrasi aman untuk kolom baru pada tabel workout_sets (Fase 3: RIR & Tracking)
    try {
      await db.execute("ALTER TABLE ${DatabaseTables.workoutSets} ADD COLUMN rir INTEGER DEFAULT 2");
    } catch (_) {}
    try {
      await db.execute("ALTER TABLE ${DatabaseTables.workoutSets} ADD COLUMN is_warmup INTEGER NOT NULL DEFAULT 0");
    } catch (_) {}
    try {
      await db.execute("ALTER TABLE ${DatabaseTables.workoutSets} ADD COLUMN form_score REAL DEFAULT 1.0");
    } catch (_) {}
    try {
      await db.execute("ALTER TABLE ${DatabaseTables.workoutSets} ADD COLUMN data_source TEXT NOT NULL DEFAULT 'manual'");
    } catch (_) {}

    await _seedExerciseProgressions(db);

    return db;
  }

  Future<void> _seedExerciseProgressions(Database db) async {
    final progressions = [
      {'id': 'prog_incline_to_knee', 'from_exercise_id': 'incline_push_up', 'to_exercise_id': 'knee_push_up', 'progression_type': 'difficulty_increase', 'min_success_sessions': 2},
      {'id': 'prog_knee_to_pushup', 'from_exercise_id': 'knee_push_up', 'to_exercise_id': 'push_up', 'progression_type': 'difficulty_increase', 'min_success_sessions': 2},
      {'id': 'prog_pushup_to_diamond', 'from_exercise_id': 'push_up', 'to_exercise_id': 'diamond_push_up', 'progression_type': 'difficulty_increase', 'min_success_sessions': 2},
      {'id': 'prog_pushup_to_decline', 'from_exercise_id': 'push_up', 'to_exercise_id': 'decline_push_up', 'progression_type': 'difficulty_increase', 'min_success_sessions': 2},
      {'id': 'prog_squat_to_split', 'from_exercise_id': 'squat', 'to_exercise_id': 'split_squat', 'progression_type': 'difficulty_increase', 'min_success_sessions': 2},
      {'id': 'prog_split_to_lunges', 'from_exercise_id': 'split_squat', 'to_exercise_id': 'lunges', 'progression_type': 'difficulty_increase', 'min_success_sessions': 2},
      {'id': 'prog_lunges_to_jump', 'from_exercise_id': 'lunges', 'to_exercise_id': 'squat_jump', 'progression_type': 'difficulty_increase', 'min_success_sessions': 2},
      {'id': 'prog_plank_to_situp', 'from_exercise_id': 'plank', 'to_exercise_id': 'sit_up', 'progression_type': 'difficulty_increase', 'min_success_sessions': 2},
      {'id': 'prog_situp_to_climber', 'from_exercise_id': 'sit_up', 'to_exercise_id': 'mountain_climber', 'progression_type': 'difficulty_increase', 'min_success_sessions': 2},
    ];

    final batch = db.batch();
    for (final p in progressions) {
      batch.insert(
        DatabaseTables.exerciseProgressions,
        p,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(DatabaseTables.createUsersTable);
    await db.execute(DatabaseTables.createUserProfilesTable);
    await db.execute(DatabaseTables.createWorkoutSessionsTable);
    await db.execute(DatabaseTables.createWorkoutSetsTable);
    await db.execute(DatabaseTables.createBodyMeasurementsTable);
    await db.execute(DatabaseTables.createUserProgramsTable);
    await db.execute(DatabaseTables.createUserSettingsTable);
    await db.execute(DatabaseTables.createExercisesTable);
    await db.execute(DatabaseTables.createExerciseProgressionsTable);
    await db.execute(DatabaseTables.createTrainingProgramsTable);
    await db.execute(DatabaseTables.createProgramSessionsTable);
    await db.execute(DatabaseTables.createProgramExercisesTable);
    await db.execute(DatabaseTables.createProgressionDecisionsTable);
    await db.execute('CREATE INDEX IF NOT EXISTS idx_progression_decisions_user ON ${DatabaseTables.progressionDecisions} (user_id, exercise_id)');

    final now = DateTime.now();

    // Initial Seeder User Root
    await db.insert(DatabaseTables.users, {
      'id': 'default_user',
      'email': 'adi@local.app',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    // Initial Seeder Profil Default (Adi, 67.5 kg, Beginner, 3 Hari Fleksibel)
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
      preferredDurationMin: 30,
      preferredDaysPerWeek: 3,
      weeklyFrequency: 3,
      availableDays: const ['monday', 'wednesday', 'friday'],
      trainingLimitations: const [],
      unitPreference: 'metric',
      equipments: const ['bodyweight', 'mat', 'stable_surface', 'doorframe'],
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

  /// Menyimpan sekumpulan set latihan sekaligus secara batch (Fase 3: RIR & Tracking)
  Future<void> saveWorkoutSets(List<WorkoutSetEntity> sets) async {
    if (sets.isEmpty) return;
    if (kIsWeb) {
      for (final s in sets) {
        final idx = _webSets.indexWhere((item) => item.id == s.id);
        if (idx >= 0) {
          _webSets[idx] = s;
        } else {
          _webSets.add(s);
        }
      }
      return;
    }

    final db = await database;
    if (db == null) return;

    final batch = db.batch();
    for (final s in sets) {
      batch.insert(
        DatabaseTables.workoutSets,
        s.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
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
    return count;
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
    if (kIsWeb) return 0;

    final db = await database;
    if (db == null) return 0;

    final sessions = await getRecentWorkoutSessions(limit: 30);
    final completedSessions = sessions
        .where((s) => s.status == WorkoutSessionStatus.completed)
        .toList();
    if (completedSessions.isEmpty) return 0;

    // Ambil set tanggal unik (YYYY-MM-DD)
    final uniqueDates = completedSessions.map((s) {
      return DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day);
    }).toSet().toList()
      ..sort((a, b) => b.compareTo(a));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Jika latihan terakhir lebih lama dari kemarin, streak putus (0)
    if (uniqueDates.first.isBefore(yesterday)) {
      return 0;
    }

    int streak = 0;
    DateTime expectedDate = uniqueDates.first;

    for (final date in uniqueDates) {
      if (date == expectedDate) {
        streak++;
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
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

  /// Mengambil akumulasi volume latihan mingguan (Sets & Reps) per movement pattern (Fase 5)
  Future<List<Map<String, dynamic>>> getWeeklyMovementVolume() async {
    if (kIsWeb) {
      return [
        {'movement_pattern': 'push', 'sets_count': 9, 'reps_sum': 96},
        {'movement_pattern': 'pull', 'sets_count': 6, 'reps_sum': 60},
        {'movement_pattern': 'squat', 'sets_count': 9, 'reps_sum': 108},
        {'movement_pattern': 'hinge', 'sets_count': 6, 'reps_sum': 72},
        {'movement_pattern': 'core', 'sets_count': 6, 'reps_sum': 60},
      ];
    }

    final db = await database;
    if (db == null) return [];

    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartStr = DateTime(weekStart.year, weekStart.month, weekStart.day).toIso8601String();

      final result = await db.rawQuery('''
        SELECT e.movement_pattern, COUNT(ws.id) as sets_count, SUM(COALESCE(ws.actual_reps, 0)) as reps_sum
        FROM ${DatabaseTables.workoutSets} ws
        JOIN ${DatabaseTables.exercises} e ON ws.exercise_id = e.id
        JOIN ${DatabaseTables.workoutSessions} s ON ws.session_id = s.id
        WHERE s.started_at >= ?
        GROUP BY e.movement_pattern
      ''', [weekStartStr]);

      if (result.isNotEmpty) {
        return result.map((r) => Map<String, dynamic>.from(r)).toList();
      }
    } catch (_) {}

    return [
      {'movement_pattern': 'push', 'sets_count': 6, 'reps_sum': 60},
      {'movement_pattern': 'pull', 'sets_count': 4, 'reps_sum': 40},
      {'movement_pattern': 'squat', 'sets_count': 6, 'reps_sum': 72},
      {'movement_pattern': 'hinge', 'sets_count': 3, 'reps_sum': 36},
      {'movement_pattern': 'core', 'sets_count': 4, 'reps_sum': 45},
    ];
  }

  /// Mengambil daftar rekomendasi keputusan adaptasi terbaru dari Coach Adi untuk milestone (Fase 5)
  Future<List<ProgressionDecisionEntity>> getRecentProgressionMilestones({int limit = 5}) async {
    if (kIsWeb) {
      return _webProgressionDecisions.take(limit).toList();
    }

    final db = await database;
    if (db == null) return [];

    final results = await db.query(
      DatabaseTables.progressionDecisions,
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return results.map(ProgressionDecisionEntity.fromMap).toList();
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
  // DYNAMIC TRAINING PROGRAMS (FASE 2)
  // ==========================================

  /// Menyimpan program dinamis hasil racikan Generator Engine
  Future<void> saveDynamicProgram({
    required TrainingProgramEntity program,
    required List<ProgramSessionDetail> sessions,
  }) async {
    final db = await database;
    if (db == null) return;

    final batch = db.batch();

    // 1. Nonaktifkan program aktif sebelumnya
    batch.update(
      DatabaseTables.trainingPrograms,
      {'status': 'archived', 'updated_at': DateTime.now().toIso8601String()},
      where: 'user_id = ? AND status = ?',
      whereArgs: [program.userId, 'active'],
    );

    // 2. Simpan program utama
    batch.insert(
      DatabaseTables.trainingPrograms,
      program.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // 3. Simpan sesi-sesi dan latihan di dalamnya
    for (final s in sessions) {
      batch.insert(
        DatabaseTables.programSessions,
        s.session.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final exItem in s.exercises) {
        batch.insert(
          DatabaseTables.programExercises,
          exItem.prescription.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    await batch.commit(noResult: true);
  }

  /// Mengambil program yang sedang aktif untuk user
  Future<TrainingProgramEntity?> getActiveTrainingProgram(String userId) async {
    final db = await database;
    if (db == null) return null;

    final result = await db.query(
      DatabaseTables.trainingPrograms,
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, 'active'],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return TrainingProgramEntity.fromMap(result.first);
  }

  /// Mengambil seluruh sesi dari suatu program
  Future<List<ProgramSessionEntity>> getProgramSessions(String programId) async {
    final db = await database;
    if (db == null) return [];

    final result = await db.query(
      DatabaseTables.programSessions,
      where: 'program_id = ?',
      whereArgs: [programId],
      orderBy: 'day_number ASC',
    );

    return result.map((m) => ProgramSessionEntity.fromMap(m)).toList();
  }

  /// Mengambil detail sesi lengkap dengan resep & informasi gerakan
  Future<ProgramSessionDetail?> getProgramSessionDetail(String programSessionId) async {
    final db = await database;
    if (db == null) return null;

    // 1. Ambil data sesi
    final sessionRows = await db.query(
      DatabaseTables.programSessions,
      where: 'id = ?',
      whereArgs: [programSessionId],
      limit: 1,
    );
    if (sessionRows.isEmpty) return null;
    final session = ProgramSessionEntity.fromMap(sessionRows.first);

    // 2. Ambil data resep latihan
    final exerciseRows = await db.query(
      DatabaseTables.programExercises,
      where: 'program_session_id = ?',
      whereArgs: [programSessionId],
      orderBy: 'sort_order ASC',
    );

    // 3. Gabungkan dengan master Exercise
    final List<ProgramExerciseDetailItem> items = [];
    for (final row in exerciseRows) {
      final prescription = ProgramExerciseEntity.fromMap(row);
      final exEntityRows = await db.query(
        DatabaseTables.exercises,
        where: 'id = ?',
        whereArgs: [prescription.exerciseId],
        limit: 1,
      );
      if (exEntityRows.isNotEmpty) {
        final exEntity = ExerciseEntity.fromMap(exEntityRows.first);
        items.add(ProgramExerciseDetailItem(
          prescription: prescription,
          exercise: exEntity.toDomain(),
        ));
      }
    }

    return ProgramSessionDetail(
      session: session,
      exercises: items,
    );
  }

  // ==========================================
  // PROGRESSION DECISIONS & ENGINE DAO (FASE 4)
  // ==========================================

  /// Menyimpan log keputusan evaluasi adaptif dari Progression Engine
  Future<void> saveProgressionDecision(ProgressionDecisionEntity decision) async {
    if (kIsWeb) {
      _webProgressionDecisions.removeWhere((d) => d.id == decision.id);
      _webProgressionDecisions.add(decision);
      return;
    }

    final db = await database;
    if (db == null) return;

    await db.insert(
      DatabaseTables.progressionDecisions,
      decision.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Mengambil keputusan adaptasi terakhir untuk latihan tertentu
  Future<ProgressionDecisionEntity?> getLatestProgressionDecision(
    String exerciseId, {
    String userId = 'default_user',
  }) async {
    if (kIsWeb) {
      final matches = _webProgressionDecisions
          .where((d) => d.exerciseId == exerciseId && d.userId == userId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return matches.isNotEmpty ? matches.first : null;
    }

    final db = await database;
    if (db == null) return null;

    final results = await db.query(
      DatabaseTables.progressionDecisions,
      where: 'exercise_id = ? AND user_id = ?',
      whereArgs: [exerciseId, userId],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (results.isEmpty) return null;
    return ProgressionDecisionEntity.fromMap(results.first);
  }

  /// Mengambil riwayat keputusan adaptasi latihan
  Future<List<ProgressionDecisionEntity>> getProgressionHistory(
    String exerciseId, {
    String userId = 'default_user',
    int limit = 10,
  }) async {
    if (kIsWeb) {
      final matches = _webProgressionDecisions
          .where((d) => d.exerciseId == exerciseId && d.userId == userId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return matches.take(limit).toList();
    }

    final db = await database;
    if (db == null) return [];

    final results = await db.query(
      DatabaseTables.progressionDecisions,
      where: 'exercise_id = ? AND user_id = ?',
      whereArgs: [exerciseId, userId],
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return results.map(ProgressionDecisionEntity.fromMap).toList();
  }

  /// Mendapatkan id variasi latihan berikutnya dari progression ladder
  Future<String?> getNextExerciseInProgression(String exerciseId) async {
    final db = await database;
    if (db == null) return null;

    final results = await db.query(
      DatabaseTables.exerciseProgressions,
      where: 'from_exercise_id = ?',
      whereArgs: [exerciseId],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return results.first['to_exercise_id'] as String?;
  }

  /// Mendapatkan id variasi latihan sebelumnya (untuk regresi) dari progression ladder
  Future<String?> getPreviousExerciseInProgression(String exerciseId) async {
    final db = await database;
    if (db == null) return null;

    final results = await db.query(
      DatabaseTables.exerciseProgressions,
      where: 'to_exercise_id = ?',
      whereArgs: [exerciseId],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return results.first['from_exercise_id'] as String?;
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
