import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workout_app/features/onboarding/presentation/widgets/step_equipment.dart';
import 'package:workout_app/i18n/strings.g.dart';

void main() {
  Widget buildSubject({
    List<String> selectedEquipments = const ['bodyweight'],
    ValueChanged<String>? onToggleEquipment,
    Brightness brightness = Brightness.dark,
  }) {
    return TranslationProvider(
      child: MaterialApp(
        theme: ThemeData(brightness: brightness, useMaterial3: true),
        home: Scaffold(
          body: StepEquipment(
            selectedEquipments: selectedEquipments,
            onToggleEquipment: onToggleEquipment ?? (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets('renders equipment cards with asset images and handles tap', (
    tester,
  ) async {
    String? toggled;

    await tester.pumpWidget(
      buildSubject(onToggleEquipment: (id) => toggled = id),
    );

    final t = Translations.of(tester.element(find.byType(StepEquipment)));
    expect(find.text(t.onboarding.equipment.title), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(6));
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.tap(find.text('Dumbbell'));
    await tester.pump();
    expect(toggled, 'dumbbell');
  });

  testWidgets('renders cleanly in light mode', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        selectedEquipments: const ['bodyweight', 'kettlebell'],
        brightness: Brightness.light,
      ),
    );

    expect(find.byType(StepEquipment), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsNWidgets(2));
  });
}
