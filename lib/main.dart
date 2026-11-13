import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/firebase_config.dart';
import 'core/config/supabase_config.dart';
import 'core/localization/app_locale.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'i18n/strings.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initialize();
  await SupabaseConfig.initialize();
  await SupabaseConfig.initializeCloudSyncConsent();
  final prefs = await SharedPreferences.getInstance();
  final hasCompletedOnboarding =
      prefs.getBool('has_completed_onboarding') ?? false;
  final initialLocale = loadStoredLocale(prefs);
  await applyInitialLocale(initialLocale);

  runApp(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          hasCompletedOnboardingProvider.overrideWith((ref) => hasCompletedOnboarding),
          appLocaleProvider.overrideWith(
            () => AppLocaleController(initial: initialLocale),
          ),
        ],
        child: const WorkoutApp(),
      ),
    ),
  );
}

class WorkoutApp extends ConsumerWidget {
  const WorkoutApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(appLocaleProvider);

    return MaterialApp.router(
      title: Translations.of(context).core.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme,
      themeMode: ThemeMode.light, // Default Light Theme sesuai PRD v2 Section 12.1
      locale: locale.flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: router,
    );
  }
}
