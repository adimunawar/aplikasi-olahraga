import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/screens/home_scaffold.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;

  runApp(
    ProviderScope(
      child: WorkoutApp(hasCompletedOnboarding: hasCompletedOnboarding),
    ),
  );
}

class WorkoutApp extends StatelessWidget {
  final bool hasCompletedOnboarding;

  const WorkoutApp({
    super.key,
    this.hasCompletedOnboarding = false,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Bulking Coach',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme,
      themeMode: ThemeMode.light, // Default Light Theme sesuai PRD v2 Section 12.1
      home: hasCompletedOnboarding ? const HomeScaffold() : const OnboardingScreen(),
    );
  }
}
