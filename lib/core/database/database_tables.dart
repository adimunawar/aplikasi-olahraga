/// Definisi Tabel SQLite sesuai PRD v2 Bagian 14 (Conceptual Data Model)
class DatabaseTables {
  DatabaseTables._();

  static const String users = 'users';
  static const String userProfiles = 'user_profiles';
  static const String workoutSessions = 'workout_sessions';
  static const String workoutSets = 'workout_sets';
  static const String bodyMeasurements = 'body_measurements';
  static const String userPrograms = 'user_programs';
  static const String trainingPrograms = 'training_programs';
  static const String programSessions = 'program_sessions';
  static const String programExercises = 'program_exercises';
  static const String userSettings = 'user_settings';
  static const String exercises = 'exercises';
  static const String exerciseProgressions = 'exercise_progressions';
  static const String progressionDecisions = 'progression_decisions';

  static const String createUsersTable = '''
    CREATE TABLE IF NOT EXISTS $users (
      id TEXT PRIMARY KEY,
      email TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
  ''';

  static const String createExercisesTable = '''
    CREATE TABLE IF NOT EXISTS $exercises (
      id TEXT PRIMARY KEY,
      name_id TEXT NOT NULL,
      name_en TEXT NOT NULL,
      category TEXT NOT NULL,
      stage TEXT NOT NULL DEFAULT 'main', -- 'warmup', 'main', 'cooldown'
      difficulty TEXT NOT NULL DEFAULT 'intermediate',
      tracking_type TEXT NOT NULL DEFAULT 'reps',
      movement_pattern TEXT NOT NULL DEFAULT 'other',
      equipments TEXT NOT NULL DEFAULT '["none"]',
      primary_muscles TEXT NOT NULL,
      stabilizer_muscles TEXT NOT NULL,
      steps_id TEXT NOT NULL,
      steps_en TEXT NOT NULL,
      common_mistakes_id TEXT,
      common_mistakes_en TEXT,
      breathing_tips_id TEXT,
      breathing_tips_en TEXT,
      start_pose_asset TEXT,
      end_pose_asset TEXT,
      animation_asset TEXT,
      video_url TEXT,
      is_custom INTEGER NOT NULL DEFAULT 0,
      is_favorite INTEGER NOT NULL DEFAULT 0,
      created_by_user_id TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
  ''';

  static const String createExerciseProgressionsTable = '''
    CREATE TABLE IF NOT EXISTS $exerciseProgressions (
      id TEXT PRIMARY KEY,
      from_exercise_id TEXT NOT NULL,
      to_exercise_id TEXT NOT NULL,
      progression_type TEXT NOT NULL DEFAULT 'difficulty_increase',
      min_success_sessions INTEGER NOT NULL DEFAULT 2,
      FOREIGN KEY (from_exercise_id) REFERENCES $exercises (id),
      FOREIGN KEY (to_exercise_id) REFERENCES $exercises (id)
    );
  ''';

  static const String createUserProfilesTable = '''
    CREATE TABLE IF NOT EXISTS $userProfiles (
      id TEXT PRIMARY KEY,
      display_name TEXT NOT NULL,
      gender TEXT NOT NULL DEFAULT 'male',
      age INTEGER NOT NULL,
      height_cm REAL NOT NULL,
      current_weight_kg REAL NOT NULL,
      target_weight_kg REAL NOT NULL DEFAULT 82.0,
      target_timeframe_weeks INTEGER NOT NULL DEFAULT 12,
      goal TEXT NOT NULL DEFAULT 'muscle_gain',
      experience_level TEXT NOT NULL DEFAULT 'beginner',
      preferred_duration_min INTEGER NOT NULL DEFAULT 45,
      preferred_days_per_week INTEGER NOT NULL DEFAULT 3,
      weekly_frequency INTEGER NOT NULL DEFAULT 3,
      available_days TEXT NOT NULL DEFAULT '["monday","wednesday","friday"]',
      training_limitations TEXT NOT NULL DEFAULT '[]',
      timezone TEXT,
      unit_preference TEXT NOT NULL DEFAULT 'metric',
      equipments TEXT NOT NULL,
      active_program_id TEXT NOT NULL DEFAULT 'upper_body_strength',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (id) REFERENCES $users (id) ON DELETE CASCADE
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
      rir INTEGER DEFAULT 2,
      is_warmup INTEGER NOT NULL DEFAULT 0,
      form_score REAL DEFAULT 1.0,
      data_source TEXT NOT NULL DEFAULT 'manual',
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

  static const String createTrainingProgramsTable = '''
    CREATE TABLE IF NOT EXISTS $trainingPrograms (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      name TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'active', -- 'active', 'completed', 'archived'
      start_date TEXT NOT NULL,
      end_date TEXT,
      weekly_frequency INTEGER NOT NULL DEFAULT 3,
      target_duration_minutes INTEGER NOT NULL DEFAULT 30,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES $users (id) ON DELETE CASCADE
    );
  ''';

  static const String createProgramSessionsTable = '''
    CREATE TABLE IF NOT EXISTS $programSessions (
      id TEXT PRIMARY KEY,
      program_id TEXT NOT NULL,
      day_number INTEGER NOT NULL, -- 1, 2, ... N
      name TEXT NOT NULL, -- 'Session A', 'Full Body 1', etc.
      target_duration_minutes INTEGER NOT NULL DEFAULT 30,
      focus_label TEXT NOT NULL DEFAULT 'Full Body',
      created_at TEXT NOT NULL,
      FOREIGN KEY (program_id) REFERENCES $trainingPrograms (id) ON DELETE CASCADE
    );
  ''';

  static const String createProgramExercisesTable = '''
    CREATE TABLE IF NOT EXISTS $programExercises (
      id TEXT PRIMARY KEY,
      program_session_id TEXT NOT NULL,
      exercise_id TEXT NOT NULL,
      sort_order INTEGER NOT NULL,
      stage TEXT NOT NULL DEFAULT 'main', -- 'warm_up', 'main', 'cool_down'
      target_sets INTEGER NOT NULL DEFAULT 3,
      min_reps INTEGER NOT NULL DEFAULT 8,
      max_reps INTEGER NOT NULL DEFAULT 12,
      target_rir INTEGER DEFAULT 2,
      rest_seconds INTEGER NOT NULL DEFAULT 60,
      FOREIGN KEY (program_session_id) REFERENCES $programSessions (id) ON DELETE CASCADE,
      FOREIGN KEY (exercise_id) REFERENCES $exercises (id) ON DELETE CASCADE
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
  static const String createProgressionDecisionsTable = '''
    CREATE TABLE IF NOT EXISTS $progressionDecisions (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      exercise_id TEXT NOT NULL,
      decision TEXT NOT NULL, -- 'progress', 'maintain', 'regress', 'recover', 'reassess'
      previous_prescription TEXT, -- JSON snapshot resep lama
      next_prescription TEXT,     -- JSON snapshot resep baru
      reason TEXT NOT NULL,       -- Penjelasan transparan dari Coach Adi
      created_at TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES $users (id) ON DELETE CASCADE,
      FOREIGN KEY (exercise_id) REFERENCES $exercises (id) ON DELETE CASCADE
    );
  ''';
}

