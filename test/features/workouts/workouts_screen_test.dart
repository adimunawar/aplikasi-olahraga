import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_app/core/database/models/dynamic_program_entity.dart';
import 'package:workout_app/core/database/models/user_profile_entity.dart';
import 'package:workout_app/core/database/models/workout_session_entity.dart';
import 'package:workout_app/core/router/app_router.dart';
import 'package:workout_app/features/exercises/domain/models/exercise.dart';
import 'package:workout_app/features/program/domain/services/program_week_schedule.dart';
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

  TrainingProgramEntity makeProgram({
    String id = 'program_1',
    String name = 'Program Latihan',
    required DateTime startDate,
    String status = 'active',
  }) {
    return TrainingProgramEntity(
      id: id,
      userId: 'user_1',
      name: name,
      status: status,
      startDate: startDate,
      createdAt: startDate,
      updatedAt: startDate,
    );
  }

  UserProfileEntity makeProfile({
    required List<String> availableDays,
    int weeks = 4,
  }) {
    final now = DateTime.now();
    return UserProfileEntity(
      id: 'user_1',
      displayName: 'Adi',
      age: 28,
      heightCm: 175,
      currentWeightKg: 70,
      targetTimeframeWeeks: weeks,
      availableDays: availableDays,
      equipments: const [],
      createdAt: now,
      updatedAt: now,
    );
  }

  ProgramSessionEntity makeSession(int dayNumber) {
    return ProgramSessionEntity(
      id: 'session_$dayNumber',
      programId: 'program_1',
      dayNumber: dayNumber,
      name: 'Workout $dayNumber',
      focusLabel: 'Focus $dayNumber',
      targetDurationMinutes: 30,
      createdAt: DateTime(2026, 11, 2),
    );
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

    testWidgets('shows expired program status instead of a running week', (
      tester,
    ) async {
      final now = DateTime.now();
      final program = makeProgram(
        startDate: now.subtract(const Duration(days: 200)),
      );

      await pumpScreen(
        tester,
        () async => WorkoutsSnapshot(program: program),
      );

      expect(find.text('Program berakhir'), findsOneWidget);
      // Program yang sudah berakhir tidak boleh punya minggu "Saat Ini".
      expect(find.text('Saat Ini'), findsNothing);
    });

    testWidgets('shows completed program status', (tester) async {
      final now = DateTime.now();
      final program = makeProgram(startDate: now, status: 'completed');

      await pumpScreen(
        tester,
        () async => WorkoutsSnapshot(program: program),
      );

      expect(find.text('Program selesai'), findsOneWidget);
      expect(find.text('Saat Ini'), findsNothing);
    });

    testWidgets('surfaces an in-progress session with its date', (
      tester,
    ) async {
      final today = ProgramWeekSchedule.dateOnly(DateTime.now());
      final weekday = ProgramWeekSchedule.weekdayNames[today.weekday - 1];
      final program = makeProgram(startDate: today);
      final activeSession = WorkoutSessionEntity(
        id: 'session_active',
        programId: 'program_1',
        programDayId: 1,
        programTitle: 'Focus 1',
        scheduledDate: today,
        startedAt: DateTime.now(),
        status: WorkoutSessionStatus.inProgress,
      );

      await pumpScreen(
        tester,
        () async => WorkoutsSnapshot(
          profile: makeProfile(availableDays: [weekday]),
          program: program,
          sessions: [makeSession(1)],
          activeSession: activeSession,
        ),
      );

      expect(find.textContaining('Sedang berlangsung'), findsOneWidget);
      expect(find.textContaining('Siap dimulai'), findsNothing);
      // Tanggal aktual ditampilkan, bukan hanya "Hari 1".
      expect(find.textContaining('Hari 1 •'), findsOneWidget);
    });

    testWidgets('ignores an in-progress session from another program', (
      tester,
    ) async {
      final today = ProgramWeekSchedule.dateOnly(DateTime.now());
      final weekday = ProgramWeekSchedule.weekdayNames[today.weekday - 1];
      final program = makeProgram(startDate: today);
      // Sesi program LAMA dengan Day 1 dan tanggal yang sama dengan
      // program saat ini: tidak boleh ditampilkan sebagai berlangsung.
      final activeSession = WorkoutSessionEntity(
        id: 'session_old_program',
        programId: 'program_old',
        programDayId: 1,
        programTitle: 'Old Focus 1',
        scheduledDate: today,
        startedAt: DateTime.now(),
        status: WorkoutSessionStatus.inProgress,
      );

      await pumpScreen(
        tester,
        () async => WorkoutsSnapshot(
          profile: makeProfile(availableDays: [weekday]),
          program: program,
          sessions: [makeSession(1)],
          activeSession: activeSession,
        ),
      );

      expect(find.textContaining('Sedang berlangsung'), findsNothing);
      expect(find.textContaining('Siap dimulai'), findsOneWidget);
    });

    testWidgets('ignores stale refresh results (latest request wins)', (
      tester,
    ) async {
      final first = Completer<WorkoutsSnapshot>();
      final second = Completer<WorkoutsSnapshot>();
      var calls = 0;

      Future<WorkoutsSnapshot> loader() {
        calls++;
        return calls == 1 ? first.future : second.future;
      }

      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(home: WorkoutsScreen(dataLoader: loader)),
        ),
      );
      await tester.pump();
      expect(calls, 1);

      tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );
      await tester.pump();
      expect(calls, 2);

      final now = DateTime.now();
      second.complete(
        WorkoutsSnapshot(
          program: makeProgram(id: 'newest', name: 'Newest Program', startDate: now),
        ),
      );
      await tester.pump();
      await tester.pump();

      // Request lama selesai belakangan: hasilnya harus diabaikan.
      first.complete(
        WorkoutsSnapshot(
          program: makeProgram(id: 'stale', name: 'Stale Program', startDate: now),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Newest Program'), findsOneWidget);
      expect(find.text('Stale Program'), findsNothing);
    });

    testWidgets('opens scheduled sessions read-only before their day', (
      tester,
    ) async {
      final today = ProgramWeekSchedule.dateOnly(DateTime.now());
      final tomorrow = today.add(const Duration(days: 1));
      final days = [
        ProgramWeekSchedule.weekdayNames[today.weekday - 1],
        ProgramWeekSchedule.weekdayNames[tomorrow.weekday - 1],
      ];

      Future<WorkoutsSnapshot> loader() async => WorkoutsSnapshot(
        profile: makeProfile(availableDays: days),
        program: makeProgram(startDate: today),
        sessions: [makeSession(1), makeSession(2)],
      );

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => WorkoutsScreen(dataLoader: loader),
          ),
          GoRoute(
            path: AppRoutes.workoutDetail,
            builder: (context, state) {
              final args = state.extra as WorkoutDetailArgs?;
              return Scaffold(
                body: Text(
                  'detail:readOnly=${args?.readOnly}:'
                  'scheduled=${args?.scheduledDate != null}',
                ),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Hari ini: detail dibuka dengan tombol mulai aktif.
      await tester.tap(find.textContaining('Siap dimulai'));
      await tester.pumpAndSettle();
      expect(
        find.text('detail:readOnly=false:scheduled=true'),
        findsOneWidget,
      );

      router.pop();
      await tester.pumpAndSettle();

      // Hari berikutnya: detail tetap bisa dilihat, tapi read-only.
      await tester.tap(find.textContaining('Terjadwal').first);
      await tester.pumpAndSettle();
      expect(
        find.text('detail:readOnly=true:scheduled=true'),
        findsOneWidget,
      );
    });
  });
}
