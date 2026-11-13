import '../../../../core/database/models/dynamic_program_entity.dart';
import '../../../../core/database/models/user_profile_entity.dart';
import '../../../exercises/domain/models/exercise.dart';

/// Hasil program latihan yang di-generate secara personal & adaptif
class GeneratedProgramResult {
  final TrainingProgramEntity program;
  final List<ProgramSessionDetail> sessions;

  const GeneratedProgramResult({
    required this.program,
    required this.sessions,
  });
}

/// DynamicProgramGenerator:
/// Domain Service murni (Pure Dart) tanpa ketergantungan UI atau Database.
/// Menghasilkan program latihan terstruktur (Full Body A/B/C atau N-Days)
/// berdasarkan profil, ketersediaan hari, durasi, alat, dan baseline push-up user.
class DynamicProgramGenerator {
  const DynamicProgramGenerator();

  /// Men-generate program latihan dinamis lengkap
  GeneratedProgramResult generate({
    required UserProfileEntity userProfile,
    required List<Exercise> catalogExercises,
    String? startingPushExerciseId,
  }) {
    if (catalogExercises.isEmpty) {
      throw StateError('Cannot generate a workout plan because the exercise catalog is empty.');
    }

    final now = DateTime.now();
    final programId = 'prog_${userProfile.id}_${now.millisecondsSinceEpoch}';

    // 1. Tentukan latihan dorong awal (Primary Horizontal Push) sesuai hasil Onboarding
    final primaryPushId = startingPushExerciseId ?? _resolveStartingPush(userProfile);

    // 2. Tentukan nama program berdasarkan Goal pengguna
    String programName;
    if (userProfile.goal.contains('fat_loss') || userProfile.goal.contains('cut')) {
      programName = 'Fat Loss & Conditioning';
    } else if (userProfile.goal.contains('maintain')) {
      programName = 'Maintain & Stay Fit';
    } else {
      programName = 'Bulking Program';
    }

    final program = TrainingProgramEntity(
      id: programId,
      userId: userProfile.id,
      name: programName,
      status: 'active',
      startDate: now,
      weeklyFrequency: userProfile.weeklyFrequency,
      targetDurationMinutes: userProfile.preferredDurationMin,
      createdAt: now,
      updatedAt: now,
    );

    // 3. Tentukan jumlah sesi berdasarkan weeklyFrequency secara presisi (2, 3, 4, 5, 6 hari)
    final List<ProgramSessionDetail> sessions = [];
    final freq = userProfile.weeklyFrequency;

    if (freq <= 2) {
      // Program 2 Hari / Minggu
      sessions.add(_buildSession(
        programId: programId,
        dayNumber: 1,
        sessionName: 'Full Body A',
        focusLabel: 'Push, Squat & Core',
        targetDurationMin: userProfile.preferredDurationMin,
        exerciseBlueprints: _get2DaySession1Blueprint(primaryPushId, userProfile),
        catalogExercises: catalogExercises,
        now: now,
      ));

      sessions.add(_buildSession(
        programId: programId,
        dayNumber: 2,
        sessionName: 'Full Body B',
        focusLabel: 'Pull, Hinge & Lunge',
        targetDurationMin: userProfile.preferredDurationMin,
        exerciseBlueprints: _get2DaySession2Blueprint(userProfile),
        catalogExercises: catalogExercises,
        now: now,
      ));
    } else if (freq == 3) {
      // Program 3 Hari / Minggu (Full Body A / B / C)
      sessions.add(_buildSession(
        programId: programId,
        dayNumber: 1,
        sessionName: 'Full Body A',
        focusLabel: 'Chest, Quads & Core Stability',
        targetDurationMin: userProfile.preferredDurationMin,
        exerciseBlueprints: _get3DaySessionABlueprint(primaryPushId, userProfile),
        catalogExercises: catalogExercises,
        now: now,
      ));

      sessions.add(_buildSession(
        programId: programId,
        dayNumber: 2,
        sessionName: 'Full Body B',
        focusLabel: 'Back, Hamstrings & Dynamics',
        targetDurationMin: userProfile.preferredDurationMin,
        exerciseBlueprints: _get3DaySessionBBlueprint(userProfile),
        catalogExercises: catalogExercises,
        now: now,
      ));

      sessions.add(_buildSession(
        programId: programId,
        dayNumber: 3,
        sessionName: 'Full Body C',
        focusLabel: 'Legs Balance & Arms Foundation',
        targetDurationMin: userProfile.preferredDurationMin,
        exerciseBlueprints: _get3DaySessionCBlueprint(primaryPushId, userProfile),
        catalogExercises: catalogExercises,
        now: now,
      ));
    } else if (freq == 4) {
      // Program 4 Hari / Minggu (Upper / Lower / Upper / Full)
      sessions.add(_buildSession(
        programId: programId,
        dayNumber: 1,
        sessionName: 'Upper Body (Push)',
        focusLabel: 'Chest, Shoulders & Triceps',
        targetDurationMin: userProfile.preferredDurationMin,
        exerciseBlueprints: _get3DaySessionABlueprint(primaryPushId, userProfile),
        catalogExercises: catalogExercises,
        now: now,
      ));

      sessions.add(_buildSession(
        programId: programId,
        dayNumber: 2,
        sessionName: 'Lower Body',
        focusLabel: 'Quads, Glutes & Calves',
        targetDurationMin: userProfile.preferredDurationMin,
        exerciseBlueprints: _get3DaySessionBBlueprint(userProfile),
        catalogExercises: catalogExercises,
        now: now,
      ));

      sessions.add(_buildSession(
        programId: programId,
        dayNumber: 3,
        sessionName: 'Upper Body (Pull)',
        focusLabel: 'Back, Biceps & Posture',
        targetDurationMin: userProfile.preferredDurationMin,
        exerciseBlueprints: _get3DaySessionCBlueprint(primaryPushId, userProfile),
        catalogExercises: catalogExercises,
        now: now,
      ));

      sessions.add(_buildSession(
        programId: programId,
        dayNumber: 4,
        sessionName: 'Full Body Conditioning',
        focusLabel: 'Full Body & Core Dynamics',
        targetDurationMin: userProfile.preferredDurationMin,
        exerciseBlueprints: _get2DaySession1Blueprint(primaryPushId, userProfile),
        catalogExercises: catalogExercises,
        now: now,
      ));
    } else if (freq == 5) {
      // Program 5 Hari / Minggu
      sessions.add(_buildSession(
        programId: programId,
        dayNumber: 1,
        sessionName: 'Upper Body (Push)',
        focusLabel: 'Chest, Shoulders & Triceps',
        targetDurationMin: userProfile.preferredDurationMin,
        exerciseBlueprints: _get3DaySessionABlueprint(primaryPushId, userProfile),
        catalogExercises: catalogExercises,
        now: now,
      ));

      sessions.add(_buildSession(
        programId: programId,
        dayNumber: 2,
        sessionName: 'Lower Body A',
        focusLabel: 'Quads, Calves & Core',
        targetDurationMin: userProfile.preferredDurationMin,
        exerciseBlueprints: _get3DaySessionBBlueprint(userProfile),
        catalogExercises: catalogExercises,
        now: now,
      ));

      sessions.add(_buildSession(
        programId: programId,
        dayNumber: 3,
        sessionName: 'Upper Body (Pull)',
        focusLabel: 'Back, Biceps & Posture',
        targetDurationMin: userProfile.preferredDurationMin,
        exerciseBlueprints: _get3DaySessionCBlueprint(primaryPushId, userProfile),
        catalogExercises: catalogExercises,
        now: now,
      ));

      sessions.add(_buildSession(
        programId: programId,
        dayNumber: 4,
        sessionName: 'Lower Body B',
        focusLabel: 'Glutes, Hamstrings & Stability',
        targetDurationMin: userProfile.preferredDurationMin,
        exerciseBlueprints: _get2DaySession2Blueprint(userProfile),
        catalogExercises: catalogExercises,
        now: now,
      ));

      sessions.add(_buildSession(
        programId: programId,
        dayNumber: 5,
        sessionName: 'Full Body & Core',
        focusLabel: 'Core, Endurance & Agility',
        targetDurationMin: userProfile.preferredDurationMin,
        exerciseBlueprints: _get2DaySession1Blueprint(primaryPushId, userProfile),
        catalogExercises: catalogExercises,
        now: now,
      ));
    } else {
      // Program 6 Hari / Minggu (PPL x 2)
      sessions.add(_buildSession(
        programId: programId,
        dayNumber: 1,
        sessionName: 'Push A',
        focusLabel: 'Chest & Triceps Focus',
        targetDurationMin: userProfile.preferredDurationMin,
        exerciseBlueprints: _get3DaySessionABlueprint(primaryPushId, userProfile),
        catalogExercises: catalogExercises,
        now: now,
      ));

      sessions.add(_buildSession(
        programId: programId,
        dayNumber: 2,
        sessionName: 'Pull A',
        focusLabel: 'Upper Back & Biceps',
        targetDurationMin: userProfile.preferredDurationMin,
        exerciseBlueprints: _get3DaySessionCBlueprint(primaryPushId, userProfile),
        catalogExercises: catalogExercises,
        now: now,
      ));

      sessions.add(_buildSession(
        programId: programId,
        dayNumber: 3,
        sessionName: 'Legs A',
        focusLabel: 'Quads & Calves Heavy',
        targetDurationMin: userProfile.preferredDurationMin,
        exerciseBlueprints: _get3DaySessionBBlueprint(userProfile),
        catalogExercises: catalogExercises,
        now: now,
      ));

      sessions.add(_buildSession(
        programId: programId,
        dayNumber: 4,
        sessionName: 'Push B',
        focusLabel: 'Shoulders & Chest Volume',
        targetDurationMin: userProfile.preferredDurationMin,
        exerciseBlueprints: _get3DaySessionABlueprint(primaryPushId, userProfile),
        catalogExercises: catalogExercises,
        now: now,
      ));

      sessions.add(_buildSession(
        programId: programId,
        dayNumber: 5,
        sessionName: 'Pull B',
        focusLabel: 'Lats & Core Dynamics',
        targetDurationMin: userProfile.preferredDurationMin,
        exerciseBlueprints: _get3DaySessionCBlueprint(primaryPushId, userProfile),
        catalogExercises: catalogExercises,
        now: now,
      ));

      sessions.add(_buildSession(
        programId: programId,
        dayNumber: 6,
        sessionName: 'Legs B',
        focusLabel: 'Hamstrings, Glutes & Mobility',
        targetDurationMin: userProfile.preferredDurationMin,
        exerciseBlueprints: _get2DaySession2Blueprint(userProfile),
        catalogExercises: catalogExercises,
        now: now,
      ));
    }

    return GeneratedProgramResult(
      program: program,
      sessions: sessions,
    );
  }

  // ===========================================================================
  // PRIVATE HELPER BLUEPRINTS
  // ===========================================================================

  String _resolveStartingPush(UserProfileEntity user) {
    if (user.trainingLimitations.contains('wrist_pain') ||
        user.trainingLimitations.contains('wrist')) {
      return 'incline_push_up';
    }

    switch (user.experienceLevel) {
      case 'beginner':
        return 'knee_push_up';
      case 'advanced':
        return 'diamond_push_up';
      case 'intermediate':
      default:
        return 'push_up';
    }
  }

  List<_ExerciseBlueprint> _get3DaySessionABlueprint(String pushId, UserProfileEntity user) {
    final list = [
      _ExerciseBlueprint(exerciseId: pushId, stage: 'main', targetSets: 3, minReps: 8, maxReps: 12),
      _ExerciseBlueprint(exerciseId: 'squat', stage: 'main', targetSets: 3, minReps: 10, maxReps: 15),
      _ExerciseBlueprint(exerciseId: 'plank', stage: 'main', targetSets: 3, minReps: 30, maxReps: 45),
    ];

    // Jika durasi >= 30 menit, tambahkan latihan pendukung
    if (user.preferredDurationMin >= 30) {
      list.add(_ExerciseBlueprint(
        exerciseId: 'glute_bridge',
        stage: 'main',
        targetSets: 3,
        minReps: 12,
        maxReps: 15,
      ));
    }
    return list;
  }

  List<_ExerciseBlueprint> _get3DaySessionBBlueprint(UserProfileEntity user) {
    final list = [
      _ExerciseBlueprint(exerciseId: 'doorframe_row', stage: 'main', targetSets: 3, minReps: 8, maxReps: 12),
      _ExerciseBlueprint(exerciseId: 'glute_bridge', stage: 'main', targetSets: 3, minReps: 10, maxReps: 15),
      _ExerciseBlueprint(exerciseId: 'mountain_climber', stage: 'main', targetSets: 3, minReps: 15, maxReps: 20),
    ];

    if (user.preferredDurationMin >= 30) {
      list.add(_ExerciseBlueprint(
        exerciseId: 'calf_raise',
        stage: 'main',
        targetSets: 3,
        minReps: 15,
        maxReps: 20,
      ));
    }
    return list;
  }

  List<_ExerciseBlueprint> _get3DaySessionCBlueprint(String pushId, UserProfileEntity user) {
    // Untuk hari C, berikan variasi kaki unilateral (Split Squat) + push sekunder
    final list = [
      _ExerciseBlueprint(exerciseId: 'split_squat', stage: 'main', targetSets: 3, minReps: 8, maxReps: 10),
      _ExerciseBlueprint(exerciseId: pushId == 'push_up' ? 'incline_push_up' : pushId, stage: 'main', targetSets: 3, minReps: 8, maxReps: 12),
      _ExerciseBlueprint(exerciseId: 'calf_raise', stage: 'main', targetSets: 3, minReps: 15, maxReps: 20),
    ];

    if (user.preferredDurationMin >= 30) {
      list.add(_ExerciseBlueprint(
        exerciseId: 'plank',
        stage: 'main',
        targetSets: 3,
        minReps: 30,
        maxReps: 45,
      ));
    }
    return list;
  }

  List<_ExerciseBlueprint> _get2DaySession1Blueprint(String pushId, UserProfileEntity user) {
    final list = [
      _ExerciseBlueprint(exerciseId: pushId, stage: 'main', targetSets: 3, minReps: 8, maxReps: 12),
      _ExerciseBlueprint(exerciseId: 'squat', stage: 'main', targetSets: 3, minReps: 10, maxReps: 15),
      _ExerciseBlueprint(exerciseId: 'plank', stage: 'main', targetSets: 3, minReps: 30, maxReps: 45),
    ];
    if (user.preferredDurationMin >= 30) {
      list.add(_ExerciseBlueprint(exerciseId: 'calf_raise', stage: 'main', targetSets: 3, minReps: 15, maxReps: 20));
    }
    return list;
  }

  List<_ExerciseBlueprint> _get2DaySession2Blueprint(UserProfileEntity user) {
    final list = [
      _ExerciseBlueprint(exerciseId: 'doorframe_row', stage: 'main', targetSets: 3, minReps: 8, maxReps: 12),
      _ExerciseBlueprint(exerciseId: 'glute_bridge', stage: 'main', targetSets: 3, minReps: 10, maxReps: 15),
      _ExerciseBlueprint(exerciseId: 'split_squat', stage: 'main', targetSets: 3, minReps: 8, maxReps: 10),
    ];
    if (user.preferredDurationMin >= 30) {
      list.add(_ExerciseBlueprint(exerciseId: 'mountain_climber', stage: 'main', targetSets: 3, minReps: 15, maxReps: 20));
    }
    return list;
  }

  ProgramSessionDetail _buildSession({
    required String programId,
    required int dayNumber,
    required String sessionName,
    required String focusLabel,
    required int targetDurationMin,
    required List<_ExerciseBlueprint> exerciseBlueprints,
    required List<Exercise> catalogExercises,
    required DateTime now,
  }) {
    final sessionId = 'sess_${programId}_day$dayNumber';

    final sessionEntity = ProgramSessionEntity(
      id: sessionId,
      programId: programId,
      dayNumber: dayNumber,
      name: sessionName,
      focusLabel: focusLabel,
      targetDurationMinutes: targetDurationMin,
      createdAt: now,
    );

    final List<ProgramExerciseDetailItem> exerciseItems = [];
    int sort = 1;

    for (final bp in exerciseBlueprints) {
      // Cari model exercise dari catalog
      final ex = catalogExercises.firstWhere(
        (e) => e.id == bp.exerciseId,
        orElse: () => throw StateError(
          'Required exercise "${bp.exerciseId}" is missing from the exercise catalog.',
        ),
      );

      final prescription = ProgramExerciseEntity(
        id: 'pe_${sessionId}_$sort',
        programSessionId: sessionId,
        exerciseId: ex.id,
        sortOrder: sort,
        stage: bp.stage,
        targetSets: bp.targetSets,
        minReps: bp.minReps,
        maxReps: bp.maxReps,
        targetRir: 2,
        restSeconds: 60,
      );

      exerciseItems.add(ProgramExerciseDetailItem(
        prescription: prescription,
        exercise: ex,
      ));
      sort++;
    }

    return ProgramSessionDetail(
      session: sessionEntity,
      exercises: exerciseItems,
    );
  }
}

class _ExerciseBlueprint {
  final String exerciseId;
  final String stage;
  final int targetSets;
  final int minReps;
  final int maxReps;

  const _ExerciseBlueprint({
    required this.exerciseId,
    required this.stage,
    required this.targetSets,
    required this.minReps,
    required this.maxReps,
  });
}

