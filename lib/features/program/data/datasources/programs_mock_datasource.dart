import '../../../exercises/domain/models/exercise.dart';
import '../../domain/models/program_day.dart';
import '../../domain/models/workout_program.dart';

/// Data Source Program Olahraga (Multi-Program Catalog):
/// Menyediakan kurasi program latihan fleksibel (8 Minggu, 4 Minggu, Split 4-Hari, Split 3-Hari).
class ProgramsMockDatasource {
  const ProgramsMockDatasource();

  List<WorkoutProgram> getAllPrograms() {
    return [
      _buildUpperBodyStrengthProgram(),
      _buildFullBodyBulkingProgram(),
      _buildLowerBodyStrengthProgram(),
      _buildCoreStabilityProgram(),
    ];
  }

  WorkoutProgram? getProgramById(String id) {
    try {
      return getAllPrograms().firstWhere((p) => p.id == id);
    } catch (_) {
      return getAllPrograms().first;
    }
  }

  // =========================================================================
  // 1. UPPER BODY STRENGTH (Program Aktif di Mockup: 8 Minggu • 4 Hari/Minggu)
  // =========================================================================
  WorkoutProgram _buildUpperBodyStrengthProgram() {
    return WorkoutProgram(
      id: 'upper_body_strength',
      title: const LocalizedString(
        id: 'Upper Body Strength',
        en: 'Upper Body Strength',
      ),
      description: const LocalizedString(
        id: 'Bangun otot dada, punggung, bahu, dan lengan lebih kuat di rumah.',
        en: 'Build a stronger chest, back, arms, and shoulders at home.',
      ),
      category: ProgramCategory.bulking,
      difficulty: ProgramDifficulty.intermediate,
      totalWeeks: 8,
      daysPerWeek: 4,
      bannerAsset: 'assets/images/Home Workout Push-Up Guide.png',
      coachPoseAsset: 'assets/images/coach_crossed_arms.png',
      weeks: List.generate(8, (weekIdx) {
        final w = weekIdx + 1;
        return ProgramWeek(
          weekNumber: w,
          title: 'Week $w - Upper Hypertrophy',
          days: [
            // Senin: Day 1 - Push
            ProgramDay(
              day: (w - 1) * 4 + 1,
              week: w,
              type: WorkoutTypeCode.p,
              focus: const LocalizedString(
                id: 'Dada • Bahu • Triceps',
                en: 'Chest • Shoulders • Triceps',
              ),
              isRest: false,
              isRetestMilestone: false,
              items: const [
                WorkoutItem(exerciseId: 'standard_push_up', sets: 3, reps: 12),
                WorkoutItem(exerciseId: 'incline_push_up', sets: 3, reps: 10),
                WorkoutItem(exerciseId: 'diamond_push_up', sets: 3, reps: 8),
              ],
            ),
            // Selasa: Day 2 - Pull
            ProgramDay(
              day: (w - 1) * 4 + 2,
              week: w,
              type: WorkoutTypeCode.p,
              focus: const LocalizedString(
                id: 'Punggung • Biceps',
                en: 'Back • Biceps',
              ),
              isRest: false,
              isRetestMilestone: false,
              items: const [
                WorkoutItem(exerciseId: 'doorframe_row', sets: 3, reps: 12),
                WorkoutItem(exerciseId: 'superman_pull', sets: 3, reps: 15),
              ],
            ),
            // Rabu: Day 3 - Rest / Recovery
            ProgramDay(
              day: (w - 1) * 4 + 3,
              week: w,
              type: WorkoutTypeCode.r,
              focus: const LocalizedString(
                id: 'Istirahat atau aktivitas ringan seperti stretching.',
                en: 'Rest, or light activity like stretching.',
              ),
              isRest: true,
              isRetestMilestone: false,
              items: const [],
            ),
            // Kamis: Day 4 - Upper Mix
            ProgramDay(
              day: (w - 1) * 4 + 4,
              week: w,
              type: WorkoutTypeCode.f,
              focus: const LocalizedString(
                id: 'Dada • Punggung • Bahu • Lengan',
                en: 'Chest • Back • Shoulders • Arms',
              ),
              isRest: false,
              isRetestMilestone: false,
              items: const [
                WorkoutItem(exerciseId: 'standard_push_up', sets: 3, reps: 10),
                WorkoutItem(exerciseId: 'pike_push_up', sets: 3, reps: 8),
                WorkoutItem(exerciseId: 'superman_pull', sets: 3, reps: 12),
              ],
            ),
            // Jumat - Minggu: Rest Days
            ProgramDay(
              day: 0,
              week: w,
              type: WorkoutTypeCode.r,
              focus: const LocalizedString(id: 'Rest', en: 'Rest'),
              isRest: true,
              isRetestMilestone: false,
              items: const [],
            ),
            ProgramDay(
              day: 0,
              week: w,
              type: WorkoutTypeCode.r,
              focus: const LocalizedString(id: 'Rest', en: 'Rest'),
              isRest: true,
              isRetestMilestone: false,
              items: const [],
            ),
            ProgramDay(
              day: 0,
              week: w,
              type: WorkoutTypeCode.r,
              focus: const LocalizedString(id: 'Rest', en: 'Rest'),
              isRest: true,
              isRetestMilestone: false,
              items: const [],
            ),
          ],
        );
      }),
    );
  }

  // =========================================================================
  // 2. FULL BODY BULKING (8 Minggu • 4 Hari/Minggu)
  // =========================================================================
  WorkoutProgram _buildFullBodyBulkingProgram() {
    return const WorkoutProgram(
      id: 'full_body_bulking',
      title: LocalizedString(
        id: 'Full Body Bulking',
        en: 'Full Body Bulking',
      ),
      description: LocalizedString(
        id: 'Program pembentukan seluruh tubuh berfokus pada volume progresif.',
        en: 'Structured full-body hypertrophy training with progressive overload.',
      ),
      category: ProgramCategory.bulking,
      difficulty: ProgramDifficulty.beginner,
      totalWeeks: 8,
      daysPerWeek: 4,
      bannerAsset: 'assets/images/Home Workout Push-Up Guide.png',
      weeks: [],
    );
  }

  // =========================================================================
  // 3. LOWER BODY STRENGTH (8 Minggu • 3 Hari/Minggu)
  // =========================================================================
  WorkoutProgram _buildLowerBodyStrengthProgram() {
    return const WorkoutProgram(
      id: 'lower_body_strength',
      title: LocalizedString(
        id: 'Lower Body Strength',
        en: 'Lower Body Strength',
      ),
      description: LocalizedString(
        id: 'Membangun kekuatan dan massa otot kaki, glutes, dan betis.',
        en: 'Develop quads, hamstrings, glutes, and calves at home.',
      ),
      category: ProgramCategory.strength,
      difficulty: ProgramDifficulty.intermediate,
      totalWeeks: 8,
      daysPerWeek: 3,
      bannerAsset: 'assets/images/coach_flex.png',
      weeks: [],
    );
  }

  // =========================================================================
  // 4. CORE & STABILITY (4 Minggu • 3 Hari/Minggu)
  // =========================================================================
  WorkoutProgram _buildCoreStabilityProgram() {
    return const WorkoutProgram(
      id: 'core_stability',
      title: LocalizedString(
        id: 'Core & Stability',
        en: 'Core & Stability',
      ),
      description: LocalizedString(
        id: 'Memperkuat dinding perut, pinggang, dan stabilitas tulang belakang.',
        en: 'Build a solid abdominal wall and spinal stability.',
      ),
      category: ProgramCategory.core,
      difficulty: ProgramDifficulty.beginner,
      totalWeeks: 4,
      daysPerWeek: 3,
      bannerAsset: 'assets/images/coach_hero.png',
      weeks: [],
    );
  }
}

