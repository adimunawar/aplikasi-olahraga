import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workout_app/features/progress/presentation/widgets/shared/progress_duration_formatter.dart';
import 'package:workout_app/i18n/strings.g.dart';

void main() {
  testWidgets(
    'formatProgressDuration formats minutes, hours, and hours-minutes',
    (tester) async {
      late BuildContext savedContext;

      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                savedContext = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 0 or negative minutes -> 0 minutes
      expect(formatProgressDuration(savedContext, 0), contains('0'));
      expect(formatProgressDuration(savedContext, -5), contains('0'));

      // Less than an hour -> minutes only
      final minutesResult = formatProgressDuration(savedContext, 45);
      expect(minutesResult, contains('45'));

      // Exact hours -> hours only
      final hoursResult = formatProgressDuration(savedContext, 120);
      expect(hoursResult, contains('2'));

      // Combined hours and minutes
      final combinedResult = formatProgressDuration(savedContext, 95);
      expect(combinedResult, contains('1'));
      expect(combinedResult, contains('35'));
    },
  );
}
