import '../../../../core/database/models/dynamic_program_entity.dart';
import '../../../../core/database/models/workout_session_entity.dart';
import '../../../program/domain/models/program_lifecycle.dart';
import '../../../program/domain/services/program_week_schedule.dart';
import '../models/week_progress.dart';

/// Menghitung status tiap minggu dari riwayat workout, bukan dari asumsi
/// "semua minggu sebelum current week pasti selesai".
class WeekProgressCalculator {
  const WeekProgressCalculator._();

  static List<WeekProgress> calculate({
    required DateTime programStartDate,
    required int totalWeeks,
    required int currentWeek,
    required List<String> availableDays,
    required List<ProgramSessionEntity> sessions,
    required List<WorkoutSessionEntity> history,
    ProgramLifecycle lifecycle = ProgramLifecycle.active,
  }) {
    if (totalWeeks < 1) return const [];

    // Satu sesi dihitung sekali meskipun ada beberapa record completed
    // untuk program day + tanggal yang sama (mis. karena re-sync).
    final completedKeys = <String>{};
    for (final record in history) {
      if (record.status != WorkoutSessionStatus.completed) continue;
      completedKeys.add(
        _completionKey(record.programDayId, record.scheduledDate),
      );
    }

    final result = <WeekProgress>[];
    for (var weekNumber = 1; weekNumber <= totalWeeks; weekNumber++) {
      final scheduled = ProgramWeekSchedule.build(
        programStartDate: programStartDate,
        weekNumber: weekNumber,
        availableDays: availableDays,
        sessions: sessions,
      );

      var completed = 0;
      for (final item in scheduled) {
        final key = _completionKey(item.session.dayNumber, item.scheduledDate);
        if (completedKeys.contains(key)) completed++;
      }

      result.add(
        WeekProgress(
          weekNumber: weekNumber,
          completedSessions: completed,
          totalSessions: scheduled.length,
          status: _statusFor(
            weekNumber: weekNumber,
            currentWeek: currentWeek,
            lifecycle: lifecycle,
            completed: completed,
            total: scheduled.length,
          ),
        ),
      );
    }

    return List.unmodifiable(result);
  }

  static WeekStatus _statusFor({
    required int weekNumber,
    required int currentWeek,
    required ProgramLifecycle lifecycle,
    required int completed,
    required int total,
  }) {
    // Program yang belum mulai: semua minggu masih pratinjau.
    if (lifecycle == ProgramLifecycle.notStarted) return WeekStatus.upcoming;

    // Hanya program yang masih berjalan yang punya "minggu saat ini".
    // Program selesai/berakhir dinilai sepenuhnya dari riwayat, sehingga
    // minggu terakhir tidak terus-menerus tampil sebagai Current.
    if (lifecycle == ProgramLifecycle.active) {
      if (weekNumber == currentWeek) return WeekStatus.current;
      if (weekNumber > currentWeek) return WeekStatus.upcoming;
    }

    if (total == 0) return WeekStatus.empty;
    if (completed >= total) return WeekStatus.completed;
    if (completed > 0) return WeekStatus.partial;
    return WeekStatus.missed;
  }

  static String _completionKey(int programDayId, DateTime date) {
    final day = ProgramWeekSchedule.dateOnly(date);
    return '$programDayId|${day.year}-${day.month}-${day.day}';
  }
}
