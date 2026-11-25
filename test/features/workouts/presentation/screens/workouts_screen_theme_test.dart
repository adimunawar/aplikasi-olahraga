import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/core/database/models/dynamic_program_entity.dart';
import 'package:workout_app/core/theme/app_theme.dart';
import 'package:workout_app/features/exercises/domain/models/exercise.dart';
import 'package:workout_app/features/workouts/domain/models/workouts_snapshot.dart';
import 'package:workout_app/features/workouts/presentation/screens/workouts_screen.dart';
import 'package:workout_app/i18n/strings.g.dart';

void main() {
  setUp(() {
    LocaleSettings.setLocaleSync(AppLocale.id);
  });

  final sampleExercises = [
    const Exercise(
      id: 'push_up',
      name: LocalizedString(id: 'Push Up', en: 'Push Up'),
      category: ExerciseCategory.push,
      difficulty: ExerciseDifficulty.beginner,
      trackingType: TrackingType.reps,
      primaryMuscles: [LocalizedString(id: 'Dada', en: 'Chest')],
      stabilizerMuscles: [],
      steps: LocalizedList(id: [], en: []),
      commonMistakes: LocalizedList(id: [], en: []),
      breathing: LocalizedString(id: '', en: ''),
      variations: ExerciseVariationGroup(),
      media: ExerciseMedia(startPose: '', endPose: ''),
    ),
  ];

  final sampleProgram = TrainingProgramEntity(
    id: 'test_program',
    userId: 'user_1',
    name: 'Home Workout Bulking',
    startDate: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  Widget createThemedApp({
    required ThemeMode themeMode,
    required WorkoutsDataLoader loader,
  }) {
    return TranslationProvider(
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: WorkoutsScreen(dataLoader: loader),
      ),
    );
  }

  group('WorkoutsScreen Theme Fidelity', () {
    testWidgets('renders properly in Light Mode without errors', (
      tester,
    ) async {
      await tester.pumpWidget(
        createThemedApp(
          themeMode: ThemeMode.light,
          loader: () async => WorkoutsSnapshot(
            program: sampleProgram,
            exercises: sampleExercises,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Latihan'), findsOneWidget);
      expect(find.text('Program Saya'), findsOneWidget);
      expect(find.text('Semua Latihan'), findsOneWidget);
      expect(find.text('Home Workout Bulking'), findsOneWidget);
    });

    testWidgets('renders properly in Dark Mode without errors', (tester) async {
      await tester.pumpWidget(
        createThemedApp(
          themeMode: ThemeMode.dark,
          loader: () async => WorkoutsSnapshot(
            program: sampleProgram,
            exercises: sampleExercises,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Latihan'), findsOneWidget);
      expect(find.text('Program Saya'), findsOneWidget);
      expect(find.text('Semua Latihan'), findsOneWidget);
      expect(find.text('Home Workout Bulking'), findsOneWidget);

      // Verify switching to All Workouts tab in Dark Mode
      await tester.tap(find.text('Semua Latihan'));
      await tester.pumpAndSettle();

      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Push Up'), findsOneWidget);
    });
  });
}
