import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_app/core/router/app_router.dart';
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

  Exercise createTestExercise({
    required String id,
    required String name,
    ExerciseCategory category = ExerciseCategory.push,
  }) {
    return Exercise(
      id: id,
      name: LocalizedString(id: name, en: name),
      category: category,
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

  Widget createTestApp({
    required AppLocale locale,
    required WorkoutDetailDataLoader loader,
    bool readOnly = false,
    String? activeSessionId,
    ThemeMode themeMode = ThemeMode.light,
    void Function(WorkoutSessionArgs args)? onSessionStarted,
  }) {
    LocaleSettings.setLocale(locale);

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => WorkoutDetailScreen(
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
            activeSessionId: activeSessionId,
            dataLoader: loader,
          ),
        ),
        GoRoute(
          path: AppRoutes.workoutSession,
          builder: (context, state) {
            final args = state.extra as WorkoutSessionArgs;
            onSessionStarted?.call(args);
            return const Scaffold(body: Text('Active Session Screen'));
          },
        ),
      ],
    );

    return TranslationProvider(
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        routerConfig: router,
      ),
    );
  }

  group('WorkoutDetailScreen - Rendering & Localization', () {
    testWidgets('renders workout details and localized ID elements', (
      tester,
    ) async {
      final sampleExercises = [
        createTestExerciseData(id: 'push_up', name: 'Push Up'),
      ];

      final loader = WorkoutDetailDataLoader(
        load: ({required programId, required dayNumber}) async =>
            sampleExercises,
      );

      await tester.pumpWidget(
        createTestApp(locale: AppLocale.id, loader: loader),
      );
      await tester.pumpAndSettle();

      expect(find.text('Upper Body Push'), findsOneWidget);
      expect(find.text('Push Up'), findsOneWidget);
      expect(find.text('1 latihan'), findsOneWidget);
      expect(find.text('3 set × 10 repetisi'), findsOneWidget);
      expect(find.text('Mulai Latihan'), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
      expect(find.byTooltip('Kembali'), findsOneWidget);
      expect(find.byTooltip('Salin detail latihan'), findsOneWidget);
      expect(find.byTooltip('Bookmark latihan'), findsOneWidget);
    });

    testWidgets('renders localized EN elements when locale is EN', (
      tester,
    ) async {
      final sampleExercises = [
        createTestExerciseData(id: 'push_up', name: 'Push Up'),
      ];

      final loader = WorkoutDetailDataLoader(
        load: ({required programId, required dayNumber}) async =>
            sampleExercises,
      );

      await tester.pumpWidget(
        createTestApp(locale: AppLocale.en, loader: loader),
      );
      await tester.pumpAndSettle();

      expect(find.text('Upper Body Push'), findsOneWidget);
      expect(find.text('1 exercise'), findsOneWidget);
      expect(find.text('3 sets × 10 reps'), findsOneWidget);
      expect(find.text('Start Workout'), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(find.byTooltip('Copy workout details'), findsOneWidget);
      expect(find.byTooltip('Bookmark workout'), findsOneWidget);
    });

    testWidgets('shows Resume Workout CTA when activeSessionId is present', (
      tester,
    ) async {
      final sampleExercises = [
        createTestExerciseData(id: 'push_up', name: 'Push Up'),
      ];

      final loader = WorkoutDetailDataLoader(
        load: ({required programId, required dayNumber}) async =>
            sampleExercises,
      );

      await tester.pumpWidget(
        createTestApp(
          locale: AppLocale.id,
          loader: loader,
          activeSessionId: 'session-active-123',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Lanjutkan Latihan'), findsOneWidget);
    });

    testWidgets(
      'hides start button and shows read-only banner in readOnly mode',
      (tester) async {
        final sampleExercises = [
          createTestExerciseData(id: 'push_up', name: 'Push Up'),
        ];

        final loader = WorkoutDetailDataLoader(
          load: ({required programId, required dayNumber}) async =>
              sampleExercises,
        );

        await tester.pumpWidget(
          createTestApp(locale: AppLocale.id, loader: loader, readOnly: true),
        );
        await tester.pumpAndSettle();

        expect(find.byType(StartWorkoutBottomBar), findsNothing);
        expect(find.text('Mode pratinjau'), findsOneWidget);
      },
    );

    testWidgets('shows empty state when no exercises are returned', (
      tester,
    ) async {
      final loader = WorkoutDetailDataLoader(
        load: ({required programId, required dayNumber}) async => [],
      );

      await tester.pumpWidget(
        createTestApp(locale: AppLocale.id, loader: loader),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutDetailEmptyState), findsOneWidget);
      expect(find.text('Belum ada gerakan latihan'), findsOneWidget);
      expect(find.byType(StartWorkoutBottomBar), findsNothing);
    });

    testWidgets('shows error view with AppButton retry when load fails', (
      tester,
    ) async {
      var loadAttempts = 0;
      final loader = WorkoutDetailDataLoader(
        load: ({required programId, required dayNumber}) async {
          loadAttempts++;
          if (loadAttempts == 1) throw Exception('Network error');
          return [createTestExerciseData(id: 'push_up', name: 'Push Up')];
        },
      );

      await tester.pumpWidget(
        createTestApp(locale: AppLocale.id, loader: loader),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutDetailErrorView), findsOneWidget);
      expect(find.text('Gagal memuat detail latihan'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      await tester.tap(find.text('Coba Lagi'));
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutDetailErrorView), findsNothing);
      expect(find.text('Push Up'), findsOneWidget);
    });

    testWidgets('tapping start workout navigates to workout session', (
      tester,
    ) async {
      WorkoutSessionArgs? navigatedArgs;
      final sampleExercises = [
        createTestExerciseData(id: 'push_up', name: 'Push Up'),
      ];

      final loader = WorkoutDetailDataLoader(
        load: ({required programId, required dayNumber}) async =>
            sampleExercises,
      );

      await tester.pumpWidget(
        createTestApp(
          locale: AppLocale.id,
          loader: loader,
          onSessionStarted: (args) => navigatedArgs = args,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mulai Latihan'));
      await tester.pumpAndSettle();

      expect(navigatedArgs, isNotNull);
      expect(navigatedArgs!.day.day, equals(1));
      expect(navigatedArgs!.exercises.first.id, equals('push_up'));
    });

    testWidgets(
      'uses localized fallback strings when args are empty (ID & EN)',
      (tester) async {
        final sampleExercises = [
          createTestExerciseData(id: 'push_up', name: 'Push Up'),
        ];
        final loader = WorkoutDetailDataLoader(
          load: ({required programId, required dayNumber}) async =>
              sampleExercises,
        );

        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => WorkoutDetailScreen(dataLoader: loader),
            ),
          ],
        );

        LocaleSettings.setLocale(AppLocale.id);
        await tester.pumpWidget(
          TranslationProvider(
            child: MaterialApp.router(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              routerConfig: router,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(t.workouts.title), findsOneWidget);
        expect(
          find.text(t.workouts.workoutDetail.defaultDescription),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'renders localized stage headers for multi-stage workout (warmup, main, cooldown)',
      (tester) async {
        final multiStageExercises = [
          createTestExerciseData(
            id: 'arm_circles',
            name: 'Arm Circles',
            stage: 'warmup',
          ),
          createTestExerciseData(id: 'push_up', name: 'Push Up', stage: 'main'),
          createTestExerciseData(
            id: 'chest_stretch',
            name: 'Chest Stretch',
            stage: 'cooldown',
          ),
        ];
        final loader = WorkoutDetailDataLoader(
          load: ({required programId, required dayNumber}) async =>
              multiStageExercises,
        );

        // Test in ID
        await tester.pumpWidget(
          createTestApp(locale: AppLocale.id, loader: loader),
        );
        await tester.pumpAndSettle();

        expect(find.text('Pemanasan (1)'), findsOneWidget);
        expect(find.text('Persiapan'), findsOneWidget);
        expect(find.text('Latihan Inti (1)'), findsOneWidget);
        expect(find.text('Latihan Utama'), findsOneWidget);
        expect(find.text('Pendinginan (1)'), findsOneWidget);
        expect(find.text('Pemulihan'), findsOneWidget);

        // Test in EN
        await tester.pumpWidget(
          createTestApp(locale: AppLocale.en, loader: loader),
        );
        await tester.pumpAndSettle();

        expect(find.text('Warm up (1)'), findsOneWidget);
        expect(find.text('Warm-up'), findsOneWidget);
        expect(find.text('Training (1)'), findsOneWidget);
        expect(find.text('Main Workout'), findsOneWidget);
        expect(find.text('Cool down (1)'), findsOneWidget);
        expect(find.text('Recovery'), findsOneWidget);
      },
    );
  });
}
