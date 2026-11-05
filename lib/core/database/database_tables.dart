/// Definisi Tabel SQLite sesuai PRD v2 Bagian 14 (Conceptual Data Model)
class DatabaseTables {
  DatabaseTables._();

  static const String userProfiles = 'user_profiles';
  static const String workoutSessions = 'workout_sessions';
  static const String workoutSets = 'workout_sets';
  static const String bodyMeasurements = 'body_measurements';
  static const String userPrograms = 'user_programs';
  static const String userSettings = 'user_settings';

  static const String createUserProfilesTable = '''
    CREATE TABLE IF NOT EXISTS $userProfiles (
      id TEXT PRIMARY KEY,
      display_name TEXT NOT NULL,
      age INTEGER NOT NULL,
      height_cm REAL NOT NULL,
      current_weight_kg REAL NOT NULL,
      goal TEXT NOT NULL DEFAULT 'muscle_gain',
      experience_level TEXT NOT NULL DEFAULT 'beginner',
      preferred_duration_min INTEGER NOT NULL DEFAULT 45,
      preferred_days_per_week INTEGER NOT NULL DEFAULT 4,
      unit_preference TEXT NOT NULL DEFAULT 'metric',
      equipments TEXT NOT NULL,
      active_program_id TEXT NOT NULL DEFAULT 'upper_body_strength',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
  ''';

  static const String createWorkoutSessionsTable = '''
    CREATE TABLE IF NOT EXISTS $workoutSessions (
      id TEXT PRIMARY KEY,
      program_id TEXT NOT NULL,
      program_day_id INTEGER NOT NULL,
      program_title TEXT NOT NULL,
      scheduled_date TEXT NOT NULL,
      started_at TEXT NOT NULL,
      ended_at TEXT,
      duration_seconds INTEGER NOT NULL DEFAULT 0,
      calories_burned INTEGER NOT NULL DEFAULT 0,
      status TEXT NOT NULL, -- 'in_progress', 'completed', 'incomplete', 'abandoned'
      notes TEXT
    );
  ''';

  static const String createWorkoutSetsTable = '''
    CREATE TABLE IF NOT EXISTS $workoutSets (
      id TEXT PRIMARY KEY,
      session_id TEXT NOT NULL,
      exercise_id TEXT NOT NULL,
      set_number INTEGER NOT NULL,
      target_reps INTEGER,
      actual_reps INTEGER,
      target_load_kg REAL,
      actual_load_kg REAL,
      duration_seconds INTEGER,
      status TEXT NOT NULL, -- 'completed', 'skipped', 'failed'
      FOREIGN KEY (session_id) REFERENCES $workoutSessions (id) ON DELETE CASCADE
    );
  ''';

  static const String createBodyMeasurementsTable = '''
    CREATE TABLE IF NOT EXISTS $bodyMeasurements (
      id TEXT PRIMARY KEY,
      measurement_type TEXT NOT NULL DEFAULT 'weight',
      value REAL NOT NULL,
      unit TEXT NOT NULL DEFAULT 'kg',
      recorded_at TEXT NOT NULL
    );
  ''';

  static const String createUserProgramsTable = '''
    CREATE TABLE IF NOT EXISTS $userPrograms (
      id TEXT PRIMARY KEY,
      program_id TEXT NOT NULL,
      program_name TEXT NOT NULL,
      status TEXT NOT NULL, -- 'active', 'completed', 'paused'
      total_weeks INTEGER NOT NULL DEFAULT 8,
      days_per_week INTEGER NOT NULL DEFAULT 4,
      current_week INTEGER NOT NULL DEFAULT 3,
      current_day INTEGER NOT NULL DEFAULT 1,
      started_at TEXT NOT NULL,
      completed_at TEXT
    );
  ''';

  static const String createUserSettingsTable = '''
    CREATE TABLE IF NOT EXISTS $userSettings (
      id TEXT PRIMARY KEY,
      gender TEXT NOT NULL DEFAULT 'Male',
      target_weight_kg REAL NOT NULL DEFAULT 65.0,
      training_intensity TEXT NOT NULL DEFAULT 'Moderate',
      workout_reminder INTEGER NOT NULL DEFAULT 1,
      reminder_time TEXT NOT NULL DEFAULT '08:00 PM',
      rest_day_reminder INTEGER NOT NULL DEFAULT 1,
      progress_checkin INTEGER NOT NULL DEFAULT 1,
      streak_reminder INTEGER NOT NULL DEFAULT 1,
      language TEXT NOT NULL DEFAULT 'English',
      theme TEXT NOT NULL DEFAULT 'Light',
      haptic_feedback INTEGER NOT NULL DEFAULT 1,
      sound_effects INTEGER NOT NULL DEFAULT 1,
      data_sync INTEGER NOT NULL DEFAULT 1,
      updated_at TEXT NOT NULL
    );
  ''';
}

