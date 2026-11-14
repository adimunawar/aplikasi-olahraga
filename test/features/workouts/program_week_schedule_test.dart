import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/core/database/models/dynamic_program_entity.dart';
import 'package:workout_app/features/workouts/domain/models/program_week_schedule.dart';

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

  group('ProgramWeekSchedule.currentWeek', () {
    test('keeps dates in the first seven-day program block in Week 1', () {
      expect(
        ProgramWeekSchedule.currentWeek(
          programStartDate: programStart,
          today: DateTime(2026, 11, 8),
          totalWeeks: 12,
        ),
        1,
      );
    });

    test('moves to Week 2 on the eighth program day', () {
      expect(
        ProgramWeekSchedule.currentWeek(
          programStartDate: programStart,
          today: DateTime(2026, 11, 9),
          totalWeeks: 12,
        ),
        2,
      );
    });

    test('clamps dates before and after the program duration', () {
      expect(
        ProgramWeekSchedule.currentWeek(
          programStartDate: programStart,
          today: DateTime(2026, 10, 31),
          totalWeeks: 12,
        ),
        1,
      );
      expect(
        ProgramWeekSchedule.currentWeek(
          programStartDate: programStart,
          today: DateTime(2027, 2, 1),
          totalWeeks: 12,
        ),
        12,
      );
    });
  });

  group('ProgramWeekSchedule.build', () {
    test('assigns workout templates to configured weekdays in Week 1', () {
      final week = ProgramWeekSchedule.build(
        programStartDate: programStart,
        weekNumber: 1,
        availableDays: const ['monday', 'wednesday', 'friday'],
        sessions: sessions,
      );

      expect(week, hasLength(3));
      expect(week.map((item) => item.session.dayNumber), [1, 2, 3]);
      expect(
        week.map((item) => item.scheduledDate),
        [DateTime(2026, 11, 2), DateTime(2026, 11, 4), DateTime(2026, 11, 6)],
      );
    });

    test('uses the same workout templates on the next week but new dates', () {
      final week = ProgramWeekSchedule.build(
        programStartDate: programStart,
        weekNumber: 2,
        availableDays: const ['monday', 'wednesday', 'friday'],
        sessions: sessions,
      );

      expect(week, hasLength(3));
      expect(week.map((item) => item.session.dayNumber), [1, 2, 3]);
      expect(
        week.map((item) => item.scheduledDate),
        [DateTime(2026, 11, 9), DateTime(2026, 11, 11), DateTime(2026, 11, 13)],
      );
    });

    test('handles a program that starts mid-week', () {
      final week = ProgramWeekSchedule.build(
        programStartDate: DateTime(2026, 11, 4), // Wednesday
        weekNumber: 1,
        availableDays: const ['monday', 'wednesday', 'friday'],
        sessions: sessions,
      );

      expect(week, hasLength(2));
      expect(
        week.map((item) => item.scheduledDate),
        [DateTime(2026, 11, 4), DateTime(2026, 11, 6)],
      );
    });

    test('returns no scheduled sessions when there are no templates or days', () {
      expect(
        ProgramWeekSchedule.build(
          programStartDate: programStart,
          weekNumber: 1,
          availableDays: const ['monday'],
          sessions: const [],
        ),
        isEmpty,
      );
      expect(
        ProgramWeekSchedule.build(
          programStartDate: programStart,
          weekNumber: 1,
          availableDays: const [],
          sessions: sessions,
        ),
        isEmpty,
      );
    });
  });
}
