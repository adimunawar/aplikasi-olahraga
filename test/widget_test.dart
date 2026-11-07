import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WorkoutApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WorkoutApp), findsOneWidget);
  });
}
