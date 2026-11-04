import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'database_tables.dart';
import 'models/user_profile_entity.dart';
import 'models/workout_session_entity.dart';
import 'models/workout_set_entity.dart';
import 'models/body_measurement_entity.dart';

/// AppDatabase: Single Source of Truth untuk Local Persistence (PRD Bagian 7 & 14).
/// - Native (Android / iOS): Menggunakan database SQLite riil via `sqflite`.
/// - Web / Desktop Preview: Menggunakan in-memory reactive fallback agar tidak crash saat di-run di Chrome.
class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  AppDatabase._internal();

  static Database? _database;

  // --- Web In-Memory Fallback State ---
  UserProfileEntity? _webProfile;
  final List<WorkoutSessionEntity> _webSessions = [];
  final List<WorkoutSetEntity> _webSets = [];
  final List<BodyMeasurementEntity> _webMeasurements = [];

  Future<Database?> get database async {
    if (kIsWeb) return null; // Web tidak menggunakan native SQLite driver
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'home_bulking_coach.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(DatabaseTables.createUserProfilesTable);
    await db.execute(DatabaseTables.createWorkoutSessionsTable);
    await db.execute(DatabaseTables.createWorkoutSetsTable);
    await db.execute(DatabaseTables.createBodyMeasurementsTable);

    // Initial Seeder Profil Default (Adi, 67.5 kg, Beginner)
    final now = DateTime.now();
    final defaultUser = _createDefaultUser(now);
    await db.insert(DatabaseTables.userProfiles, defaultUser.toMap());

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
