import 'package:flutter/foundation.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/dynamic_program_entity.dart';
import '../../../exercises/data/datasources/exercise_local_datasource.dart';
import '../../../exercises/data/repositories/exercise_repository_impl.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../../workout_session/domain/models/exercise_prescription.dart';
import '../widgets/workout_exercise_list_section.dart';

/// Data loader abstraction for WorkoutDetailScreen.
/// Decouples data queries from the widget tree and enables fast, deterministic tests.
class WorkoutDetailDataLoader {
  final Future<List<WorkoutDetailExerciseData>> Function({
    required String? programId,
    required int dayNumber,
  }) load;

  const WorkoutDetailDataLoader({required this.load});

  static WorkoutDetailDataLoader live() {
    return WorkoutDetailDataLoader(
      load: ({
        required String? programId,
        required int dayNumber,
      }) async {
        final exerciseRepo = ExerciseRepositoryImpl(ExerciseLocalDatasource());
        await exerciseRepo.getExercises();

        final List<WorkoutDetailExerciseData> list = [];
        final db = AppDatabase.instance;
        final profile = await db.getUserProfile();
        final userId = profile.id.isNotEmpty ? profile.id : 'default_user';

        List<ProgramSessionEntity> sessions = [];
        String? targetProgramId = programId;

        if (targetProgramId != null && targetProgramId.isNotEmpty) {
          sessions = await db.getProgramSessions(targetProgramId);
        }

        if (sessions.isEmpty) {
          var activeProgram = await db.getActiveTrainingProgram(userId);
          activeProgram ??= await db.getActiveTrainingProgram('default_user');
          if (activeProgram != null) {
            targetProgramId = activeProgram.id;
            sessions = await db.getProgramSessions(activeProgram.id);
          }
        }

        if (sessions.isNotEmpty) {
          final sessionIndex = sessions.indexWhere(
            (session) => session.dayNumber == dayNumber,
          );

          if (sessionIndex >= 0) {
            final session = sessions[sessionIndex];
            final detail = await db.getProgramSessionDetail(session.id);

            if (detail != null && detail.exercises.isNotEmpty) {
              for (final item in detail.exercises) {
                final ex = item.exercise;
                final prescription = item.prescription;
                final isDuration = ex.trackingType == TrackingType.duration;
                final repsStr = isDuration
                    ? '${prescription.minReps} – ${prescription.maxReps} sec'
                    : '${prescription.minReps} – ${prescription.maxReps} Reps';
                final restStr = '${prescription.restSeconds} sec';

                final resolvedImg = ex.resolvedImageUrl;
                final fallbackAsset = ex.media.startPose.isNotEmpty
                    ? ex.media.startPose
                    : 'assets/images/Detail Gerakan.png';
                final finalThumbnail = resolvedImg.isNotEmpty ? resolvedImg : fallbackAsset;

                if (ex.id.contains('knee') || ex.id.contains('push')) {
                  debugPrint('[WorkoutDetailDataLoader] 🔍 Detail item "${ex.id}":');
                  debugPrint('   raw ex.thumbnailUrl     : "${ex.thumbnailUrl}"');
                  debugPrint('   raw media.thumbnailUrl  : "${ex.media.thumbnailUrl}"');
                  debugPrint('   resolvedThumbnailUrl    : "${ex.resolvedThumbnailUrl}"');
                  debugPrint('   resolvedImageUrl        : "${ex.resolvedImageUrl}"');
                  debugPrint('   startPose               : "${ex.media.startPose}"');
                  debugPrint('   final thumbnailAsset    : "$finalThumbnail"');
                }

                list.add(
                  WorkoutDetailExerciseData(
                    title: ex.name.en.isNotEmpty ? ex.name.en : ex.name.id,
                    categoryTag: ex.primaryMuscles.isNotEmpty
                        ? ex.primaryMuscles.first.en
                        : 'Bodyweight',
                    thumbnailAsset: finalThumbnail,
                    sets: prescription.targetSets,
                    reps: repsStr,
                    rest: restStr,
                    exercise: ex,
                    stage: prescription.stage,
                    prescription: WorkoutExercisePrescription.fromProgramExercise(
                      prescription,
                      trackingType: ex.trackingType,
                    ),
                  ),
                );
              }
            }
          }
        }
        return list;
      },
    );
  }
}
