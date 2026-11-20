import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/progress/application/progress_history_grouping.dart';

void main() {
  const grouping = ProgressHistoryGrouping();
  final now = DateTime(2026, 11, 20, 12);

  group('ProgressHistoryGrouping.groupFor', () {
    test('groups today and dates within six days as This Week', () {
      expect(grouping.groupFor(DateTime(2026, 11, 20), now: now), 'This Week');
      expect(grouping.groupFor(DateTime(2026, 11, 14), now: now), 'This Week');
    });

    test('groups dates from seven to thirteen days ago as Last Week', () {
      expect(grouping.groupFor(DateTime(2026, 11, 13), now: now), 'Last Week');
      expect(grouping.groupFor(DateTime(2026, 11, 7), now: now), 'Last Week');
    });

    test('groups older dates and future dates as Earlier', () {
      expect(grouping.groupFor(DateTime(2026, 11, 6), now: now), 'Earlier');
      expect(grouping.groupFor(DateTime(2026, 11, 21), now: now), 'Earlier');
    });
  });

  group('ProgressHistoryGrouping.parseWorkoutDate', () {
    test('parses relative English and Indonesian labels', () {
      expect(grouping.parseWorkoutDate('Today', now: now), now);
      expect(grouping.parseWorkoutDate('Yesterday', now: now), DateTime(2026, 11, 19, 12));
      expect(grouping.parseWorkoutDate('2 hari lalu', now: now), DateTime(2026, 11, 18, 12));
    });

    test('parses dd/mm/yyyy date text', () {
      expect(grouping.parseWorkoutDate('09/11/2026', now: now), DateTime(2026, 11, 9));
    });

    test('uses a stable fallback for unsupported date labels', () {
      expect(grouping.parseWorkoutDate('Nov 9', now: now), DateTime(2000));
    });
  });
}
