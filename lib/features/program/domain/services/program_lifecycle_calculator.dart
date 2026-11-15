import '../models/program_lifecycle.dart';
import 'program_week_schedule.dart';

/// Menentukan status lifecycle program tanpa bergantung pada `currentWeek`
/// yang selalu di-clamp ke total minggu.
class ProgramLifecycleCalculator {
  const ProgramLifecycleCalculator._();

  static ProgramLifecycleInfo resolve({
    required DateTime programStartDate,
    required int totalWeeks,
    required DateTime today,
    String storedStatus = 'active',
    int completedSessions = 0,
    int totalSessions = 0,
  }) {
    final weeks = totalWeeks < 1 ? 1 : totalWeeks;
    final start = ProgramWeekSchedule.dateOnly(programStartDate);
    final current = ProgramWeekSchedule.dateOnly(today);

    // Hari terakhir inklusif: minggu ke-N berakhir pada start + N*7 - 1.
    final end = start.add(Duration(days: weeks * 7 - 1));

    final currentWeek = ProgramWeekSchedule.currentWeek(
      programStartDate: start,
      today: current,
      totalWeeks: weeks,
    );

    final normalizedStatus = storedStatus.trim().toLowerCase();
    final allSessionsCompleted =
        totalSessions > 0 && completedSessions >= totalSessions;

    final ProgramLifecycle state;
    if (normalizedStatus == 'completed') {
      state = ProgramLifecycle.completed;
    } else if (current.isBefore(start)) {
      state = ProgramLifecycle.notStarted;
    } else if (allSessionsCompleted) {
      state = ProgramLifecycle.completed;
    } else if (current.isAfter(end)) {
      state = ProgramLifecycle.expired;
    } else {
      state = ProgramLifecycle.active;
    }

    return ProgramLifecycleInfo(
      state: state,
      startDate: start,
      endDate: end,
      totalWeeks: weeks,
      currentWeek: currentWeek,
      completedSessions: completedSessions,
      totalSessions: totalSessions,
      daysRemaining: state == ProgramLifecycle.active
          ? end.difference(current).inDays
          : 0,
    );
  }
}
