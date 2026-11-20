import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/firebase_config.dart';
import 'core/config/supabase_config.dart';
import 'core/database/app_database.dart';
import 'core/localization/app_locale.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'i18n/strings.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  await SupabaseConfig.initializeCloudSyncConsent();
  final hasCompletedOnboarding =
      await AppDatabase.instance.hasCompletedOnboarding();
  final prefs = await SharedPreferences.getInstance();
  final initialLocale = loadStoredLocale(prefs);
  await applyInitialLocale(initialLocale);

  runApp(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          hasCompletedOnboardingProvider.overrideWith(
            (ref) => hasCompletedOnboarding,
          ),
          appLocaleProvider.overrideWith(
            () => AppLocaleController(initial: initialLocale),
          ),
        ],
        child: const WorkoutApp(),
      ),
    ),
  );

  // Firebase is optional telemetry; do not delay the local-first UI startup.
  unawaited(FirebaseConfig.initialize());
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
      themeMode:
          ThemeMode.light, // Default Light Theme sesuai PRD v2 Section 12.1
      locale: locale.flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: router,
    );
  }
}
