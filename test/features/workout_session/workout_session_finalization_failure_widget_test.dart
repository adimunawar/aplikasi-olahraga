import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_app/core/database/app_database.dart';
import 'package:workout_app/core/database/models/user_profile_entity.dart';
import 'package:workout_app/core/database/models/user_settings_entity.dart';
import 'package:workout_app/core/database/models/workout_session_entity.dart';
import 'package:workout_app/core/database/models/workout_set_entity.dart';
import 'package:workout_app/core/router/app_router.dart';
import 'package:workout_app/core/widgets/app_button.dart';
import 'package:workout_app/features/exercises/domain/models/exercise.dart';
import 'package:workout_app/features/plans/presentation/controllers/plans_controller.dart';
import 'package:workout_app/features/profile/data/datasources/user_supabase_datasource.dart';
import 'package:workout_app/features/profile/domain/repositories/user_profile_repository.dart';
import 'package:workout_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:workout_app/features/program/data/repositories/programs_repository_impl.dart';
import 'package:workout_app/features/program/domain/models/program_day.dart';
import 'package:workout_app/features/progress/application/bmi_calculator_service.dart';
import 'package:workout_app/features/progress/application/weight_analytics_service.dart';
import 'package:workout_app/features/progress/data/datasources/progress_supabase_datasource.dart';
import 'package:workout_app/features/progress/data/repositories/progress_repository_impl.dart';
import 'package:workout_app/features/progress/presentation/controllers/progress_controller.dart';
import 'package:workout_app/features/workout_session/domain/models/workout_session_result.dart';
import 'package:workout_app/features/workout_session/domain/repositories/workout_session_repository.dart';
import 'package:workout_app/features/workout_session/presentation/controllers/workout_session_controller.dart';
import 'package:workout_app/features/workout_session/presentation/controllers/workout_session_state.dart';
import 'package:workout_app/features/workout_session/presentation/screens/workout_session_screen.dart';
import 'package:workout_app/i18n/strings.g.dart';

class _FakeWorkoutSessionRepository implements WorkoutSessionRepository {
  bool failFinishSession = false;
  bool failPrepareSession = false;
  WorkoutSessionEntity? active;
  int finishAttemptCount = 0;
  Completer<List<WorkoutSetEntity>>? pendingSetRestore;
  Completer<void>? onSetRestoreStarted;
  final List<WorkoutSetEntity> savedSets = [];

  @override
  Future<WorkoutSessionEntity?> getActiveInProgressSession() async {
    if (failPrepareSession) {
      throw StateError('simulated session preparation failure');
    }
    return active;
  }

  @override
  Future<WorkoutSessionEntity> startWorkoutSession({
    required String programId,
    required int dayNumber,
    required String programTitle,
    required DateTime scheduledDate,
  }) async {
    final session = WorkoutSessionEntity(
      id: 'session_test_1',
      programId: programId,
      programDayId: dayNumber,
      programTitle: programTitle,
      scheduledDate: scheduledDate,
      startedAt: DateTime.now(),
      status: WorkoutSessionStatus.inProgress,
    );
    active = session;
    return session;
  }

  @override
  Future<WorkoutSessionResult> completeWorkoutSession({
    required String programId,
    required int dayNumber,
    required String programTitle,
    required int durationSeconds,
    required int completedSets,
    required int totalExercises,
    required DateTime startedAt,
    List<WorkoutSetEntity> setLogs = const [],
    bool isEndingEarly = false,
    Map<String, int>? targetSetsPerExercise,
    String? sessionId,
  }) async {
    finishAttemptCount++;
    if (failFinishSession) {
      throw StateError('simulated session persistence failure');
    }
    active = null;
    return WorkoutSessionResult(
      sessionId: sessionId ?? 'session_completed',
      programId: programId,
      dayNumber: dayNumber,
      programTitle: programTitle,
      durationSeconds: durationSeconds,
      caloriesBurned: 100,
      completedSets: completedSets,
      totalExercises: totalExercises,
      startedAt: startedAt,
      endedAt: DateTime.now(),
      progressionDecisions: const [],
    );
  }

  @override
  Future<void> saveSetLog(WorkoutSetEntity set) async {
    savedSets.add(set);
  }

  @override
  Future<void> abandonSession(String sessionId) async {
    active = null;
  }

  @override
  Future<void> updateSessionProgress(
    String sessionId, {
    required int elapsedSeconds,
  }) async {}

  @override
  Future<List<WorkoutSetEntity>> getSetsForSession(String sessionId) {
    onSetRestoreStarted?.complete();
    return pendingSetRestore?.future ?? Future.value([]);
  }
}

class _FakeUserProfileRepository implements UserProfileRepository {
  @override
  Future<UserProfileEntity> getUserProfile() async {
    return UserProfileEntity(
      id: 'user_1',
      displayName: 'Adi',
      age: 28,
      heightCm: 175,
      currentWeightKg: 70,
      targetTimeframeWeeks: 4,
      availableDays: const ['mon', 'wed', 'fri'],
      equipments: const [],
      createdAt: DateTime(2026, 11, 1),
      updatedAt: DateTime(2026, 11, 1),
    );
  }

  @override
  Future<UserSettingsEntity> getUserSettings() async =>
      throw UnimplementedError();

  @override
  Future<void> saveUserProfile(UserProfileEntity profile) async {}

  @override
  Future<void> saveUserSettings(UserSettingsEntity settings) async {}

  @override
  Future<void> updateBodyData({
    required double weightKg,
    required double heightCm,
  }) async {}

  @override
  Future<void> updateDisplayName(String name) async {}
}

class _StubPlansController extends PlansController {
  _StubPlansController()
    : super(
        programsRepo: ProgramsRepositoryImpl(database: AppDatabase.instance),
        userDatasource: const UserSupabaseDatasource(),
        database: AppDatabase.instance,
      );

  @override
  Future<void> loadPrograms() async {}
}

class _StubProgressController extends ProgressController {
  _StubProgressController()
    : super(
        repository: ProgressRepositoryImpl(
          remoteDatasource: const ProgressSupabaseDatasource(),
          localDatabase: AppDatabase.instance,
        ),
        bmiCalculator: const BmiCalculatorService(),
        weightAnalytics: const WeightAnalyticsService(),
        userDatasource: const UserSupabaseDatasource(),
        programsRepo: ProgramsRepositoryImpl(database: AppDatabase.instance),
      );

  @override
  Future<void> loadProgress() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    LocaleSettings.setLocaleSync(AppLocale.en);

    // Mock platform channel for WakelockPlus to avoid MissingPluginException
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/wakelock'),
          (call) async => true,
        );
  });

  final exercise = Exercise(
    id: 'push_up',
    name: const LocalizedString(id: 'Push Up', en: 'Push Up'),
    category: ExerciseCategory.push,
    difficulty: ExerciseDifficulty.beginner,
    trackingType: TrackingType.reps,
    primaryMuscles: const [LocalizedString(id: 'Dada', en: 'Chest')],
    stabilizerMuscles: const [],
    steps: const LocalizedList(id: [], en: []),
    commonMistakes: const LocalizedList(id: [], en: []),
    breathing: const LocalizedString(id: '', en: ''),
    variations: const ExerciseVariationGroup(),
    media: const ExerciseMedia(startPose: '', endPose: ''),
  );

  final day = ProgramDay(
    day: 1,
    week: 1,
    type: WorkoutTypeCode.p,
    focus: const LocalizedString(id: 'Dada', en: 'Chest Focus'),
    isRest: false,
    isRetestMilestone: false,
    items: const [
      WorkoutItem(exerciseId: 'push_up', sets: 3, reps: 10, restSeconds: 45),
    ],
  );


  group('WorkoutSessionController finalization readiness', () {
    test('rejects finalization while an in-progress session is still restoring', () async {
      final repository = _FakeWorkoutSessionRepository()
        ..pendingSetRestore = Completer<List<WorkoutSetEntity>>()
        ..onSetRestoreStarted = Completer<void>();
      final container = ProviderContainer(
        overrides: [
          workoutSessionRepositoryProvider.overrideWithValue(repository),
        ],
      );
      final subscription = container.listen(
        workoutSessionControllerProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);
      addTearDown(container.dispose);

      final controller = container.read(workoutSessionControllerProvider.notifier);
      final preparation = controller.prepareSession(
        programId: 'program_1',
        dayNumber: 1,
        programTitle: 'Chest Focus',
        scheduledDate: DateTime(2026, 11, 18),
        exerciseIds: const ['push_up'],
      );

      await repository.onSetRestoreStarted!.future;
      expect(controller.sessionId, 'session_test_1');
      expect(container.read(workoutSessionControllerProvider).isPreparing, isTrue);

      final result = await controller.finishWorkoutSession(
        programId: 'program_1',
        dayNumber: 1,
        programTitle: 'Chest Focus',
        totalExercises: 1,
      );

      expect(result, isNull);
      expect(repository.finishAttemptCount, 0);

      repository.pendingSetRestore!.complete([]);
      await preparation;
      expect(container.read(workoutSessionControllerProvider).isSessionReady, isTrue);
    });

    test('rejects finalization after session preparation fails', () async {
      final repository = _FakeWorkoutSessionRepository()
        ..failPrepareSession = true;
      final container = ProviderContainer(
        overrides: [
          workoutSessionRepositoryProvider.overrideWithValue(repository),
        ],
      );
      final subscription = container.listen(
        workoutSessionControllerProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);
      addTearDown(container.dispose);

      final controller = container.read(workoutSessionControllerProvider.notifier);
      await controller.prepareSession(
        programId: 'program_1',
        dayNumber: 1,
        programTitle: 'Chest Focus',
        scheduledDate: DateTime(2026, 11, 18),
        exerciseIds: const ['push_up'],
      );

      expect(container.read(workoutSessionControllerProvider).isSessionReady, isFalse);
      final result = await controller.finishWorkoutSession(
        programId: 'program_1',
        dayNumber: 1,
        programTitle: 'Chest Focus',
        totalExercises: 1,
      );

      expect(result, isNull);
      expect(repository.finishAttemptCount, 0);
    });

    test('rejects finalization when no active session ID was prepared', () async {
      final repository = _FakeWorkoutSessionRepository()
        ..active = WorkoutSessionEntity(
          id: 'another_session',
          programId: 'another_program',
          programDayId: 2,
          programTitle: 'Another workout',
          scheduledDate: DateTime(2026, 11, 18),
          startedAt: DateTime(2026, 11, 18, 8),
          status: WorkoutSessionStatus.inProgress,
        );
      final container = ProviderContainer(
        overrides: [
          workoutSessionRepositoryProvider.overrideWithValue(repository),
        ],
      );
      final subscription = container.listen(
        workoutSessionControllerProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);
      addTearDown(container.dispose);

      final controller = container.read(workoutSessionControllerProvider.notifier);
      await controller.prepareSession(
        programId: 'program_1',
        dayNumber: 1,
        programTitle: 'Chest Focus',
        scheduledDate: DateTime(2026, 11, 18),
        exerciseIds: const ['push_up'],
      );

      expect(container.read(workoutSessionControllerProvider).isSessionReady, isTrue);
      expect(controller.sessionId, isNull);
      final result = await controller.finishWorkoutSession(
        programId: 'program_1',
        dayNumber: 1,
        programTitle: 'Chest Focus',
        totalExercises: 1,
      );

      expect(result, isNull);
      expect(repository.finishAttemptCount, 0);
    });
  });

  group('WorkoutSessionScreen finalization failure & retry widget test', () {

    testWidgets(
      'keeps the options menu disabled when session preparation fails',
      (tester) async {
        final repository = _FakeWorkoutSessionRepository()
          ..failPrepareSession = true;
        final userProfileRepo = _FakeUserProfileRepository();

        final router = GoRouter(
          initialLocation: '/session',
          routes: [
            GoRoute(
              path: '/session',
              builder: (context, state) => WorkoutSessionScreen(
                day: day,
                exercises: [exercise],
                programId: 'program_1',
              ),
            ),
            GoRoute(
              path: AppRoutes.workoutSummary,
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Summary Screen Loaded')),
              ),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              workoutSessionRepositoryProvider.overrideWithValue(repository),
              userProfileRepositoryProvider.overrideWithValue(userProfileRepo),
              plansControllerProvider.overrideWith(
                (ref) => _StubPlansController(),
              ),
              progressControllerProvider.overrideWith(
                (ref) => _StubProgressController(),
              ),
            ],
            child: TranslationProvider(
              child: MaterialApp.router(routerConfig: router),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final moreIcon = find.byIcon(Icons.more_horiz_rounded);
        expect(moreIcon, findsOneWidget);
        final moreButton = tester.widget<IconButton>(
          find.ancestor(
            of: moreIcon,
            matching: find.byType(IconButton),
          ),
        );
        expect(moreButton.onPressed, isNull);

        await tester.tap(moreIcon);
        await tester.pumpAndSettle();

        expect(find.text(t.workoutSession.finishSessionNow), findsNothing);
        expect(find.text('Summary Screen Loaded'), findsNothing);
        expect(repository.finishAttemptCount, 0);
      },
    );

    testWidgets(
      'stays on session screen with retry action on failure, then navigates to summary on successful retry',
      (tester) async {
        final repository = _FakeWorkoutSessionRepository();
        final userProfileRepo = _FakeUserProfileRepository();

        WorkoutSummaryArgs? capturedSummaryArgs;

        final router = GoRouter(
          initialLocation: '/session',
          routes: [
            GoRoute(
              path: '/session',
              builder: (context, state) => WorkoutSessionScreen(
                day: day,
                exercises: [exercise],
                programId: 'program_1',
              ),
            ),
            GoRoute(
              path: AppRoutes.workoutSummary,
              builder: (context, state) {
                capturedSummaryArgs = state.extra as WorkoutSummaryArgs?;
                return const Scaffold(
                  body: Center(child: Text('Summary Screen Loaded')),
                );
              },
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              workoutSessionRepositoryProvider.overrideWithValue(repository),
              userProfileRepositoryProvider.overrideWithValue(userProfileRepo),
              plansControllerProvider.overrideWith(
                (ref) => _StubPlansController(),
              ),
              progressControllerProvider.overrideWith(
                (ref) => _StubProgressController(),
              ),
            ],
            child: TranslationProvider(
              child: MaterialApp.router(routerConfig: router),
            ),
          ),
        );

        // Allow postFrameCallback and prepareSession to finish
        await tester.pumpAndSettle();

        expect(find.byType(WorkoutSessionScreen), findsOneWidget);
        expect(find.text('Summary Screen Loaded'), findsNothing);

        // Simulate finalization failure
        repository.failFinishSession = true;

        // Open options sheet via more icon
        final moreButton = find.byIcon(Icons.more_horiz_rounded);
        expect(moreButton, findsOneWidget);
        await tester.tap(moreButton);
        await tester.pumpAndSettle();

        // Tap Finish Session Now in bottom sheet
        final finishNowTile = find.text(
          t.workoutSession.finishSessionNow,
        );
        expect(finishNowTile, findsOneWidget);
        await tester.tap(finishNowTile);
        await tester.pumpAndSettle();

        // Verification 1: Navigation to summary did NOT occur
        expect(find.text('Summary Screen Loaded'), findsNothing);
        expect(find.byType(WorkoutSessionScreen), findsOneWidget);
        expect(repository.finishAttemptCount, 1);

        // Verification 2: Error banner and localized failure message are visible
        expect(
          find.text(t.workoutSession.finishSessionFailed),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.error_outline_rounded), findsWidgets);

        // Verification 3: Localized Retry button is visible
        final retryButton = find.widgetWithText(
          AppButton,
          t.workoutSession.retry,
        );
        expect(retryButton, findsOneWidget);

        // Tap Retry while still failing
        await tester.tap(retryButton);
        await tester.pumpAndSettle();

        expect(repository.finishAttemptCount, 2);
        expect(find.text('Summary Screen Loaded'), findsNothing);
        expect(
          find.text(t.workoutSession.finishSessionFailed),
          findsOneWidget,
        );

        // Now simulate database / network recovery
        repository.failFinishSession = false;

        // Tap Retry button again
        await tester.tap(retryButton);
        await tester.pumpAndSettle();

        // Verification 4: Succeeded and navigated to Summary Screen
        expect(repository.finishAttemptCount, 3);
        expect(find.text('Summary Screen Loaded'), findsOneWidget);
        expect(find.byType(WorkoutSessionScreen), findsNothing);

        // Verification 5: Arguments passed to summary route are accurate
        expect(capturedSummaryArgs, isNotNull);
        expect(capturedSummaryArgs!.userName, 'Adi');
        expect(capturedSummaryArgs!.workoutTitle, 'Chest Focus');
      },
    );
  });
}
