import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workout_app/features/progress/presentation/widgets/shared/progress_range_selector.dart';
import 'package:workout_app/i18n/strings.g.dart';

void main() {
  testWidgets(
    'ProgressRangeSelector renders current weeks and handles selection',
    (tester) async {
      int selectedWeeks = 8;

      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return ProgressRangeSelector(
                      selectedWeeks: selectedWeeks,
                      onWeeksChanged: (val) {
                        setState(() {
                          selectedWeeks = val;
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial render displays 8 weeks
      expect(find.byType(ProgressRangeSelector), findsOneWidget);
      expect(find.textContaining('8'), findsOneWidget);

      // Tap to open popup menu
      await tester.tap(find.byType(ProgressRangeSelector));
      await tester.pumpAndSettle();

      // Select 12 weeks from popup
      await tester.tap(find.textContaining('12').last);
      await tester.pumpAndSettle();

      expect(selectedWeeks, 12);
    },
  );
}
