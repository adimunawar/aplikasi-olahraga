import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/core/database/models/dynamic_program_entity.dart';
import 'package:workout_app/core/database/models/workout_session_entity.dart';
import 'package:workout_app/features/workouts/domain/models/week_progress.dart';
import 'package:workout_app/features/workouts/domain/services/week_progress_calculator.dart';
import 'package:workout_app/features/program/domain/models/program_lifecycle.dart';

void main() {
  final programStart = DateTime(2026, 11, 2); // Monday
  final sessions = List.generate(
    3,
    (index) => ProgramSessionEntity(
      id: 'session_${index + 1}',
      programId: 'program_1',
      dayNumber: index + 1,
      name: 'Workout ${index + 1}',
      focusLabel: 'Focus ${index + 1}',
      targetDurationMinutes: 30,
      createdAt: programStart,
    ),
  );
  const availableDays = ['monday', 'wednesday', 'friday'];

  WorkoutSessionEntity record({
    required int day,
    required DateTime date,
    WorkoutSessionStatus status = WorkoutSessionStatus.completed,
  }) {
    return WorkoutSessionEntity(
      id: 'record-$day-${date.toIso8601String()}-${status.name}',
      programId: 'program_1',
      programDayId: day,
      programTitle: 'Program',
      scheduledDate: date,
      startedAt: date,
      status: status,
    );
  }

  List<WeekProgress> calculate({
    List<WorkoutSessionEntity> history = const [],
    int currentWeek = 4,
    int totalWeeks = 5,
    List<String> days = availableDays,
    List<ProgramSessionEntity>? sessionList,
    ProgramLifecycle lifecycle = ProgramLifecycle.active,
  }) {
    return WeekProgressCalculator.calculate(
      programStartDate: programStart,
      totalWeeks: totalWeeks,
      currentWeek: currentWeek,
      availableDays: days,
      sessions: sessionList ?? sessions,
      history: history,
      lifecycle: lifecycle,
    );
  }

  group('WeekProgressCalculator', () {
    test('derives week status from workout history', () {
      final result = calculate(
        history: [
          // Week 1: all three sessions completed.
          record(day: 1, date: DateTime(2026, 11, 2)),
          record(day: 2, date: DateTime(2026, 11, 4)),
          record(day: 3, date: DateTime(2026, 11, 6)),
          // Week 2: only one of three completed.
          record(day: 1, date: DateTime(2026, 11, 9)),
          // Week 3: nothing completed.
        ],
      );

      expect(result, hasLength(5));
      expect(result[0].status, WeekStatus.completed);
      expect(result[0].completedSessions, 3);
      expect(result[1].status, WeekStatus.partial);
      expect(result[1].completedSessions, 1);
      expect(result[1].completionRate, closeTo(1 / 3, 0.0001));
      expect(result[2].status, WeekStatus.missed);
      expect(result[2].completedSessions, 0);
      expect(result[3].status, WeekStatus.current);
      expect(result[4].status, WeekStatus.upcoming);
    });

    test('does not mark a week completed when sessions were skipped', () {
      final result = calculate(
        history: [
          record(day: 1, date: DateTime(2026, 11, 2)),
          // Day 2 and 3 of week 1 are intentionally missing.
        ],
      );

      expect(result[0].status, WeekStatus.partial);
      expect(result[0].completedSessions, 1);
      expect(result[0].completedSessions, lessThan(result[0].totalSessions));
    });

    test('counts duplicate completed records only once', () {
      final result = calculate(
        history: [
          record(day: 1, date: DateTime(2026, 11, 2)),
          record(day: 1, date: DateTime(2026, 11, 2)),
          record(day: 2, date: DateTime(2026, 11, 4)),
        ],
      );

      expect(result[0].completedSessions, 2);
      expect(result[0].status, WeekStatus.partial);
    });

    test('ignores records that are not completed', () {
      final result = calculate(
        history: [
          record(
            day: 1,
            date: DateTime(2026, 11, 2),
            status: WorkoutSessionStatus.inProgress,
          ),
          record(
            day: 2,
            date: DateTime(2026, 11, 4),
            status: WorkoutSessionStatus.abandoned,
          ),
          record(
            day: 3,
            date: DateTime(2026, 11, 6),
            status: WorkoutSessionStatus.incomplete,
          ),
        ],
      );

      expect(result[0].completedSessions, 0);
      expect(result[0].status, WeekStatus.missed);
    });

    test('marks past weeks without scheduled sessions as empty', () {
      final result = calculate(
        totalWeeks: 3,
        currentWeek: 2,
        sessionList: const [],
      );

      expect(result[0].status, WeekStatus.empty);
      expect(result[0].totalSessions, 0);
      expect(result[1].status, WeekStatus.current);
      expect(result[2].status, WeekStatus.upcoming);
    });

    test('clamps progress and handles total weeks below one', () {
      expect(calculate(totalWeeks: 0), isEmpty);

      final progress = WeekProgress(
        weekNumber: 1,
        completedSessions: 5,
        totalSessions: 3,
        status: WeekStatus.completed,
      );
      expect(progress.completionRate, 1.0);
    });

    test('expired programs never keep a current week', () {
      final result = calculate(
        lifecycle: ProgramLifecycle.expired,
        history: [
          record(day: 1, date: DateTime(2026, 11, 2)),
          record(day: 2, date: DateTime(2026, 11, 4)),
          record(day: 3, date: DateTime(2026, 11, 6)),
        ],
      );

      // Week 4 is `currentWeek`, but the program already ended.
      expect(
        result.where((week) => week.status == WeekStatus.current),
        isEmpty,
      );
      expect(result[0].status, WeekStatus.completed);
      expect(result[1].status, WeekStatus.missed);
      expect(result[3].status, WeekStatus.missed);
      expect(result[4].status, WeekStatus.missed);
    });

    test('completed programs are judged only by history', () {
      final result = calculate(lifecycle: ProgramLifecycle.completed);

      expect(
        result.where((week) => week.status == WeekStatus.current),
        isEmpty,
      );
      expect(
        result.where((week) => week.status == WeekStatus.upcoming),
        isEmpty,
      );
      expect(result.every((week) => week.status == WeekStatus.missed), isTrue);
    });

    test('not started programs show every week as upcoming', () {
      final result = calculate(lifecycle: ProgramLifecycle.notStarted);

      expect(result, hasLength(5));
      expect(
        result.every((week) => week.status == WeekStatus.upcoming),
        isTrue,
      );
    });
  });
}
