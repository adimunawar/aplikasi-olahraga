import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workout_app/core/router/app_router.dart';
import 'package:workout_app/core/theme/app_theme.dart';
import 'package:workout_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:workout_app/features/profile/presentation/controllers/profile_state.dart';
import 'package:workout_app/features/profile/presentation/screens/body_information_screen.dart';

class _RecordingController extends StateNotifier<ProfileState>
    implements ProfileController {
  _RecordingController()
    : super(
        const ProfileState(
          isLoading: false,
          currentWeight: 60.0,
          currentHeight: 170.0,
          currentBmi: 20.8,
        ),
      );

  double? savedWeightKg;
  double? savedHeightCm;

  @override
  Future<void> updateBodyData({
    required double weightKg,
    required double heightCm,
  }) async {
    savedWeightKg = weightKg;
    savedHeightCm = heightCm;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('BodyInformationScreen recalculates BMI and saves', (
    tester,
  ) async {
    final controller = _RecordingController();
    final router = GoRouter(
      initialLocation: AppRoutes.profile,
      routes: [
        GoRoute(
          path: AppRoutes.profile,
          builder: (_, _) => const Scaffold(body: Text('Root')),
        ),
        GoRoute(
          path: AppRoutes.bodyInfo,
          builder: (_, _) => const BodyInformationScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileControllerProvider.overrideWith((ref) => controller),
        ],
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          routerConfig: router,
        ),
      ),
    );
    router.push(AppRoutes.bodyInfo);
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '70.0');
    await tester.enterText(fields.at(1), '175');
    await tester.pump();

    expect(find.text('22.9'), findsOneWidget);
    expect(find.text('Healthy'), findsNWidgets(2));

    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(controller.savedWeightKg, 70.0);
    expect(controller.savedHeightCm, 175.0);
    expect(find.text('Root'), findsOneWidget);
  });
}
