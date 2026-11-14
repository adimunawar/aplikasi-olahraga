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

/// Builds calendar dates for a program week from the user's available weekdays.
///
/// Program weeks are anchored to [programStartDate] in seven-day intervals,
/// matching the week calculation used by HomeController.
class ProgramWeekSchedule {
  const ProgramWeekSchedule._();

  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

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
        .where((day) => day.isNotEmpty)
        .toSet();

    final weekStart = startDateForWeek(
      programStartDate: programStartDate,
      weekNumber: weekNumber,
    );

    final result = <ProgramWeekSession>[];
    var sessionIndex = 0;

    for (var offset = 0; offset < 7 && sessionIndex < sessions.length; offset++) {
      final date = weekStart.add(Duration(days: offset));
      final weekday = _weekdayNames[date.weekday - 1];

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

  static const List<String> _weekdayNames = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];
}
