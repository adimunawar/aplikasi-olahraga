import '../../../../core/database/models/dynamic_program_entity.dart';
import '../../../../core/database/models/user_profile_entity.dart';
import '../../../../core/database/models/workout_session_entity.dart';
import '../../../exercises/domain/models/exercise.dart';

/// Data yang dibutuhkan WorkoutsScreen dalam satu snapshot.
///
/// Dipisahkan dari state widget supaya layar bisa dites dengan data palsu
/// tanpa menyentuh SQLite.
class WorkoutsSnapshot {
  final UserProfileEntity? profile;
  final TrainingProgramEntity? program;
  final List<ProgramSessionEntity> sessions;
  final List<WorkoutSessionEntity> history;
  final List<Exercise> exercises;

  const WorkoutsSnapshot({
    this.profile,
    this.program,
    this.sessions = const [],
    this.history = const [],
    this.exercises = const [],
  });
}
