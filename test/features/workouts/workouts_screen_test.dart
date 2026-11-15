import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/core/database/models/dynamic_program_entity.dart';
import 'package:workout_app/features/exercises/domain/models/exercise.dart';
import 'package:workout_app/features/workouts/domain/models/workouts_snapshot.dart';
import 'package:workout_app/features/workouts/presentation/screens/workouts_screen.dart';
import 'package:workout_app/i18n/strings.g.dart';

void main() {
  Exercise makeExercise({
    required String id,
    required String name,
    required String muscleEn,
    required String muscleId,
    ExerciseCategory category = ExerciseCategory.push,
    ExerciseDifficulty difficulty = ExerciseDifficulty.intermediate,
  }) {
    return Exercise(
      id: id,
      name: LocalizedString(id: name, en: name),
      category: category,
      difficulty: difficulty,
      trackingType: TrackingType.reps,
      primaryMuscles: [LocalizedString(id: muscleId, en: muscleEn)],
      stabilizerMuscles: const [],
      steps: const LocalizedList(id: [], en: []),
      commonMistakes: const LocalizedList(id: [], en: []),
      breathing: const LocalizedString(id: '', en: ''),
      variations: const ExerciseVariationGroup(),
      media: const ExerciseMedia(startPose: '', endPose: ''),
    );
  }

  final exercises = [
    makeExercise(
      id: 'bench_press',
      name: 'Bench Press',
      muscleEn: 'Chest',
      muscleId: 'Dada',
    ),
    makeExercise(
      id: 'bicep_curl',
      name: 'Bicep Curl',
      muscleEn: 'Biceps',
      muscleId: 'Bisep',
    ),
    makeExercise(
      id: 'squat',
      name: 'Squat',
      muscleEn: 'Quadriceps',
      muscleId: 'Paha',
      category: ExerciseCategory.legs,
      difficulty: ExerciseDifficulty.beginner,
    ),
  ];

  Future<void> pumpScreen(
    WidgetTester tester,
    WorkoutsDataLoader loader,
  ) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: WorkoutsScreen(dataLoader: loader),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openAllWorkouts(WidgetTester tester) async {
    await tester.tap(find.text('Semua Latihan'));
    await tester.pumpAndSettle();
  }

  group('WorkoutsScreen', () {
    testWidgets('shows an error state and retries instead of empty program', (
      tester,
    ) async {
      var attempts = 0;

      await pumpScreen(tester, () async {
        attempts++;
        if (attempts == 1) {
          throw StateError('database unavailable');
        }
        return const WorkoutsSnapshot();
      });

      expect(find.text('Gagal memuat data'), findsOneWidget);
      expect(find.text('Belum ada program aktif'), findsNothing);

      await tester.tap(find.text('Coba Lagi'));
      await tester.pumpAndSettle();

      expect(attempts, 2);
      expect(find.text('Gagal memuat data'), findsNothing);
      expect(find.text('Belum ada program aktif'), findsOneWidget);
    });

    testWidgets('scopes search and filter controls to All Workouts', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        () async => const WorkoutsSnapshot(),
      );

      // My Program has no search/filter header actions.
      expect(find.byIcon(Icons.search_rounded), findsNothing);
      expect(find.byIcon(Icons.tune_rounded), findsNothing);

      await openAllWorkouts(tester);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);

      // Switching back to My Program hides and clears the search.
      await tester.tap(find.text('Program Saya'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      expect(find.byIcon(Icons.search_rounded), findsNothing);
    });

    testWidgets('maps muscle filters, localizes metadata and clears filters', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        () async => WorkoutsSnapshot(exercises: exercises),
      );
      await openAllWorkouts(tester);

      // Localized metadata instead of hardcoded duration.
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Dada • Menengah'), findsOneWidget);
      expect(find.textContaining('10 min'), findsNothing);
      expect(find.textContaining('10 mnt'), findsNothing);

      // "Dada" must match Chest, not push category.
      await tester.tap(find.text('Dada'));
      await tester.pumpAndSettle();
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Bicep Curl'), findsNothing);
      expect(find.text('Squat'), findsNothing);

      // "Lengan" matches Biceps.
      await tester.tap(find.text('Lengan'));
      await tester.pumpAndSettle();
      expect(find.text('Bicep Curl'), findsOneWidget);
      expect(find.text('Bench Press'), findsNothing);
      expect(find.text('Bisep • Menengah'), findsOneWidget);

      // Search with no result shows the empty state.
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'tidak-ada-latihan');
      await tester.pumpAndSettle();

      expect(find.text('Tidak ada latihan ditemukan'), findsOneWidget);

      await tester.ensureVisible(find.text('Hapus pencarian & filter'));
      await tester.tap(find.text('Hapus pencarian & filter'));
      await tester.pumpAndSettle();

      // Filters reset to all and all exercises are visible again.
      expect(find.text('Tidak ada latihan ditemukan'), findsNothing);
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Bicep Curl'), findsOneWidget);
      expect(find.text('Squat'), findsOneWidget);
    });

    testWidgets('shows a preview notice for upcoming weeks', (tester) async {
      final now = DateTime.now();
      final program = TrainingProgramEntity(
        id: 'program_1',
        userId: 'user_1',
        name: 'Program Latihan',
        startDate: now,
        createdAt: now,
        updatedAt: now,
      );

      await pumpScreen(
        tester,
        () async => WorkoutsSnapshot(program: program),
      );

      expect(find.text('Program Aktif'), findsOneWidget);
      expect(find.text('Saat Ini'), findsOneWidget);
      expect(find.text('Mode pratinjau'), findsNothing);

      await tester.ensureVisible(find.text('W3'));
      await tester.tap(find.text('W3'));
      await tester.pumpAndSettle();

      expect(find.text('Mode pratinjau'), findsOneWidget);
      expect(
        find.textContaining('latihan baru bisa dimulai'),
        findsOneWidget,
      );
    });
  });
}
