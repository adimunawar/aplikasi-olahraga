import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workout_app/features/progress/presentation/controllers/progress_controller.dart';
import 'package:workout_app/features/progress/presentation/controllers/progress_state.dart';
import 'package:workout_app/features/progress/presentation/screens/progress_screen.dart';
import 'package:workout_app/features/progress/presentation/widgets/progress_widgets.dart';
import 'package:workout_app/i18n/strings.g.dart';

class FakeProgressController extends StateNotifier<ProgressState>
    implements ProgressController {
  FakeProgressController([super.state = const ProgressState()]);

  int loadProgressCallCount = 0;

  @override
  Future<void> loadProgress() async {
    loadProgressCallCount++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Widget buildWidget(ProgressState state) {
    return ProviderScope(
      overrides: [
        progressControllerProvider.overrideWith(
          (ref) => FakeProgressController(state),
        ),
      ],
      child: TranslationProvider(
        child: const MaterialApp(home: ProgressScreen()),
      ),
    );
  }

  testWidgets(
    'renders LoadingState when isLoading is true and recentWorkouts is empty',
    (tester) async {
      const state = ProgressState(isLoading: true);

      await tester.pumpWidget(buildWidget(state));
      await tester.pump();

      expect(find.byType(LoadingState), findsOneWidget);
    },
  );

  testWidgets(
    'renders ErrorState when errorMessage is present and recentWorkouts is empty',
    (tester) async {
      const state = ProgressState(
        isLoading: false,
        errorMessage: 'Network connection failed',
      );

      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.text('Network connection failed'), findsOneWidget);
    },
  );

  testWidgets('renders tabs and allows switching between tabs', (tester) async {
    const state = ProgressState(isLoading: false);

    await tester.pumpWidget(buildWidget(state));
    await tester.pumpAndSettle();

    expect(find.byType(ProgressOverviewTab), findsOneWidget);
    expect(find.byType(ProgressRangeSelector), findsOneWidget);

    // Switch to Body tab
    await tester.tap(find.text(t.core.progress.tabs.body));
    await tester.pumpAndSettle();
    expect(find.byType(ProgressBodyTab), findsOneWidget);

    // Switch to Workout tab
    await tester.tap(find.text(t.core.progress.tabs.workout));
    await tester.pumpAndSettle();
    expect(find.byType(ProgressWorkoutTab), findsOneWidget);

    // Switch to History tab
    await tester.tap(find.text(t.core.progress.tabs.history));
    await tester.pumpAndSettle();
    expect(find.byType(ProgressHistoryTab), findsOneWidget);
  });
}
