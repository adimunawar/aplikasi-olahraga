import '../../../../core/database/models/dynamic_program_entity.dart';

/// A workout template assigned to its scheduled date within a program week.
class ProgramWeekSession {
  final ProgramSessionEntity session;
  final DateTime scheduledDate;

  const ProgramWeekSession({
    required this.session,
    required this.scheduledDate,
  });
}

/// Single source of truth for mapping program weeks, workout templates,
/// and the weekdays selected by a user.
class ProgramWeekSchedule {
  const ProgramWeekSchedule._();

  static const List<String> weekdayNames = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  /// Creates a balanced weekly pattern anchored to the program start day.
  ///
  /// The first workout is always scheduled on [startDate]. Remaining sessions
  /// are distributed through the seven-day cycle based on [frequency].
  static List<String> availableWeekdaysForFrequency({
    required DateTime startDate,
    required int frequency,
  }) {
    if (frequency < 2 || frequency > 6) {
      throw ArgumentError.value(
        frequency,
        'frequency',
        'Training frequency must be between 2 and 6 days per week.',
      );
    }

    // Offsets keep rest days reasonably distributed while always allowing
    // the user to start training on the day their plan is activated.
    final offsets = switch (frequency) {
      2 => const [0, 3],
      3 => const [0, 2, 4],
      4 => const [0, 2, 4, 6],
      5 => const [0, 1, 3, 5, 6],
      6 => const [0, 1, 2, 4, 5, 6],
      _ => const <int>[],
    };

    final startWeekdayIndex = dateOnly(startDate).weekday - 1;
    return offsets
        .map((offset) => weekdayNames[(startWeekdayIndex + offset) % 7])
        .toList(growable: false);
  }

  static int currentWeek({
    required DateTime programStartDate,
    required DateTime today,
    required int totalWeeks,
  }) {
    if (totalWeeks < 1) return 1;

    final start = dateOnly(programStartDate);
    final current = dateOnly(today);
    if (current.isBefore(start)) return 1;

    final elapsedDays = current.difference(start).inDays;
    return ((elapsedDays ~/ 7) + 1).clamp(1, totalWeeks).toInt();
  }

  static DateTime startDateForWeek({
    required DateTime programStartDate,
    required int weekNumber,
  }) {
    final start = dateOnly(programStartDate);
    return start.add(Duration(days: (weekNumber - 1) * 7));
  }

  static List<ProgramWeekSession> build({
    required DateTime programStartDate,
    required int weekNumber,
    required List<String> availableDays,
    required List<ProgramSessionEntity> sessions,
  }) {
    if (sessions.isEmpty || availableDays.isEmpty || weekNumber < 1) {
      return const [];
    }

    final normalizedDays = availableDays
        .map((day) => day.trim().toLowerCase())
        .where((day) => weekdayNames.contains(day))
        .toSet();

    final weekStart = startDateForWeek(
      programStartDate: programStartDate,
      weekNumber: weekNumber,
    );

    final result = <ProgramWeekSession>[];
    var sessionIndex = 0;

    for (
      var offset = 0;
      offset < 7 && sessionIndex < sessions.length;
      offset++
    ) {
      final date = weekStart.add(Duration(days: offset));
      final weekday = weekdayNames[date.weekday - 1];

      if (!normalizedDays.contains(weekday)) continue;

      result.add(
        ProgramWeekSession(
          session: sessions[sessionIndex],
          scheduledDate: date,
        ),
      );
      sessionIndex++;
    }

    return result;
  }

  static ProgramWeekSession? sessionForDate({
    required DateTime programStartDate,
    required DateTime date,
    required List<String> availableDays,
    required List<ProgramSessionEntity> sessions,
    required int totalWeeks,
  }) {
    final weekNumber = currentWeek(
      programStartDate: programStartDate,
      today: date,
      totalWeeks: totalWeeks,
    );
    final targetDate = dateOnly(date);

    for (final scheduled in build(
      programStartDate: programStartDate,
      weekNumber: weekNumber,
      availableDays: availableDays,
      sessions: sessions,
    )) {
      if (dateOnly(scheduled.scheduledDate) == targetDate) {
        return scheduled;
      }
    }

    return null;
  }
}
