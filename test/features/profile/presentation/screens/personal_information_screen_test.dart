import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workout_app/core/router/app_router.dart';
import 'package:workout_app/core/theme/app_theme.dart';
import 'package:workout_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:workout_app/features/profile/presentation/controllers/profile_state.dart';
import 'package:workout_app/features/profile/presentation/screens/personal_information_screen.dart';

class _RecordingController extends StateNotifier<ProfileState>
    implements ProfileController {
  _RecordingController()
    : super(
        const ProfileState(
          isLoading: false,
          displayName: 'Adi',
          age: 25,
          gender: 'Male',
        ),
      );

  String? savedFullName;
  int? savedAge;
  String? savedGender;

  @override
  Future<void> updatePersonalInfo({
    required String fullName,
    required int age,
    required String gender,
  }) async {
    savedFullName = fullName;
    savedAge = age;
    savedGender = gender;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('PersonalInformationScreen updates name, gender and pops', (
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
          path: AppRoutes.personalInfo,
          builder: (_, _) => const PersonalInformationScreen(),
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
    router.push(AppRoutes.personalInfo);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Budi Santoso');
    await tester.tap(find.text('Female'));
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(controller.savedFullName, 'Budi Santoso');
    expect(controller.savedAge, 25);
    expect(controller.savedGender, 'Female');
    expect(find.text('Root'), findsOneWidget);
  });
}
