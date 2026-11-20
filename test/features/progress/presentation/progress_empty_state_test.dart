import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/progress/presentation/widgets/progress_dashboard_widgets.dart';

void main() {
  testWidgets('ProgressEmptyState displays its icon, title, and guidance', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProgressEmptyState(
            icon: Icons.fitness_center_rounded,
            title: 'No workout data yet',
            message: 'Complete your first workout to see your training progress here.',
          ),
        ),
      ),
    );

    expect(find.text('No workout data yet'), findsOneWidget);
    expect(
      find.text('Complete your first workout to see your training progress here.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.fitness_center_rounded), findsOneWidget);
  });
}
