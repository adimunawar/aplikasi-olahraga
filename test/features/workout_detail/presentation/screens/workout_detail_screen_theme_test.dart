import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/core/theme/app_theme.dart';
import 'package:workout_app/core/widgets/app_button.dart';
import 'package:workout_app/features/exercises/domain/models/exercise.dart';
import 'package:workout_app/features/workout_detail/presentation/controllers/workout_detail_data_loader.dart';
import 'package:workout_app/features/workout_detail/presentation/screens/workout_detail_screen.dart';
import 'package:workout_app/features/workout_detail/presentation/widgets/workout_detail_widgets.dart';
import 'package:workout_app/i18n/strings.g.dart';

void main() {
  setUp(() {
    LocaleSettings.setLocale(AppLocale.id);
  });

  Exercise createTestExercise({required String id, required String name}) {
    return Exercise(
      id: id,
      name: LocalizedString(id: name, en: name),
      category: ExerciseCategory.push,
      difficulty: ExerciseDifficulty.beginner,
      trackingType: TrackingType.reps,
      movementPattern: 'horizontal_push',
      equipments: const ['bodyweight'],
      primaryMuscles: const [LocalizedString(id: 'Dada', en: 'Chest')],
      stabilizerMuscles: const [],
      steps: const LocalizedList(id: ['Langkah 1'], en: ['Step 1']),
      commonMistakes: const LocalizedList(id: [], en: []),
      breathing: const LocalizedString(id: '', en: ''),
      variations: const ExerciseVariationGroup(),
      media: const ExerciseMedia(startPose: '', endPose: ''),
    );
  }

  WorkoutDetailExerciseData createTestExerciseData({
    required String id,
    required String name,
    String stage = 'main',
  }) {
    return WorkoutDetailExerciseData(
      title: name,
      categoryTag: 'Chest',
      thumbnailAsset: '',
      sets: 3,
      reps: '10',
      rest: '60 sec',
      exercise: createTestExercise(id: id, name: name),
      stage: stage,
    );
  }

  Widget createThemedApp({
    required ThemeMode themeMode,
    bool readOnly = false,
  }) {
    final loader = WorkoutDetailDataLoader(
      load: ({required programId, required dayNumber}) async => [
        createTestExerciseData(id: 'push_up', name: 'Push Up', stage: 'main'),
        createTestExerciseData(
          id: 'arm_circles',
          name: 'Arm Circles',
          stage: 'warmup',
        ),
      ],
    );

    return TranslationProvider(
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: WorkoutDetailScreen(
          dayNumber: 1,
          weekNumber: 1,
          programId: 'prog-1',
          weekDayText: 'Minggu 1 • Hari 1',
          workoutTitle: 'Upper Body Push',
          targetMusclesText: 'Chest & Triceps',
          durationText: '45 mnt',
          levelText: 'Pemula',
          description: 'Latihan tubuh bagian atas di rumah.',
          readOnly: readOnly,
          dataLoader: loader,
        ),
      ),
    );
  }

  group('WorkoutDetailScreen - Theme Fidelity (Light & Dark Mode)', () {
    testWidgets('renders cleanly in Light Mode without unmanaged colors', (
      tester,
    ) async {
      await tester.pumpWidget(createThemedApp(themeMode: ThemeMode.light));
      await tester.pumpAndSettle();

      expect(find.text('Upper Body Push'), findsOneWidget);
      expect(find.byType(StartWorkoutBottomBar), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
      expect(find.byType(WorkoutExerciseListItem), findsNWidgets(2));
    });

    testWidgets('renders cleanly in Dark Mode with dark surface styling', (
      tester,
    ) async {
      await tester.pumpWidget(createThemedApp(themeMode: ThemeMode.dark));
      await tester.pumpAndSettle();

      expect(find.text('Upper Body Push'), findsOneWidget);
      expect(find.byType(StartWorkoutBottomBar), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
      expect(find.byType(WorkoutExerciseListItem), findsNWidgets(2));
    });

    testWidgets('read-only notice adapts cleanly in Dark Mode', (tester) async {
      await tester.pumpWidget(
        createThemedApp(themeMode: ThemeMode.dark, readOnly: true),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mode pratinjau'), findsOneWidget);
      expect(find.byType(StartWorkoutBottomBar), findsNothing);
    });
  });
}
