import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workout_app/core/config/supabase_config.dart';
import 'package:workout_app/core/localization/app_locale.dart';
import 'package:workout_app/core/theme/app_typography.dart';
import 'package:workout_app/i18n/strings.g.dart';

import '../controllers/profile_controller.dart';
import '../controllers/profile_state.dart';
import '../widgets/app_settings_cloud_sync_dialog.dart';
import '../widgets/app_settings_widgets.dart';

class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  Future<void> _updateSettings(
    BuildContext context,
    WidgetRef ref, {
    required String language,
    required String theme,
    required String units,
    required bool hapticFeedback,
    required bool soundEffects,
    required bool dataSync,
  }) async {
    try {
      await ref
          .read(profileControllerProvider.notifier)
          .updateAppSettings(
            language: language,
            theme: theme,
            units: units,
            hapticFeedback: hapticFeedback,
            soundEffects: soundEffects,
            dataSync: dataSync,
          );
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, t.profile.appSettings.saveError);
      }
    }
  }

  Future<void> _handleDataSyncChanged(
    BuildContext context,
    WidgetRef ref,
    ProfileState profile,
    String language,
    bool enabled,
  ) async {
    if (!enabled) {
      try {
        await SupabaseConfig.disableCloudSync();
      } catch (_) {
        if (context.mounted) {
          _showMessage(context, t.profile.appSettings.cloudSyncDisableError);
        }
      }
      if (!context.mounted) return;
      await _updateSettings(
        context,
        ref,
        language: language,
        theme: profile.theme,
        units: profile.unitPreference,
        hapticFeedback: profile.hapticFeedback,
        soundEffects: profile.soundEffects,
        dataSync: false,
      );
      return;
    }

    final user = SupabaseConfig.currentUser;
    if (user == null || user.isAnonymous) {
      _showMessage(context, t.profile.appSettings.cloudSyncSignInRequired);
      return;
    }

    final accepted = await showCloudSyncConsentDialog(context);
    if (!accepted || !context.mounted) return;

    try {
      await SupabaseConfig.enableCloudSync();
      if (!context.mounted) return;
      await _updateSettings(
        context,
        ref,
        language: language,
        theme: profile.theme,
        units: profile.unitPreference,
        hapticFeedback: profile.hapticFeedback,
        soundEffects: profile.soundEffects,
        dataSync: true,
      );
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, t.profile.appSettings.cloudSyncEnableError);
      }
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final profile = ref.watch(profileControllerProvider);
    final language = profileLanguageFromAppLocale(ref.watch(appLocaleProvider));
    final dataSync = SupabaseConfig.canSyncToCloud;
    final settingsT = t.profile.appSettings;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          settingsT.title,
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                settingsT.subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              AppSettingsNavigationCard(
                icon: Icons.language_rounded,
                title: settingsT.language,
                valueText: language,
                onTap: () => showAppSettingsPickerSheet(
                  context: context,
                  title: settingsT.selectLanguage,
                  options: const ['English', 'Bahasa Indonesia'],
                  selectedValue: language,
                  onSelected: (lang) async {
                    await ref
                        .read(appLocaleProvider.notifier)
                        .setLocale(appLocaleFromProfileLanguage(lang));
                    if (!context.mounted) return;
                    await _updateSettings(
                      context,
                      ref,
                      language: lang,
                      theme: profile.theme,
                      units: profile.unitPreference,
                      hapticFeedback: profile.hapticFeedback,
                      soundEffects: profile.soundEffects,
                      dataSync: dataSync,
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              AppSettingsNavigationCard(
                icon: Icons.dark_mode_outlined,
                title: settingsT.theme,
                valueText: profile.theme,
                onTap: () => showAppSettingsPickerSheet(
                  context: context,
                  title: settingsT.selectTheme,
                  options: const ['Light', 'Dark', 'System Default'],
                  selectedValue: profile.theme,
                  onSelected: (selected) => _updateSettings(
                    context,
                    ref,
                    language: language,
                    theme: selected,
                    units: profile.unitPreference,
                    hapticFeedback: profile.hapticFeedback,
                    soundEffects: profile.soundEffects,
                    dataSync: dataSync,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AppSettingsNavigationCard(
                icon: Icons.straighten_rounded,
                title: settingsT.units,
                valueText: profile.unitPreference,
                onTap: () => showAppSettingsPickerSheet(
                  context: context,
                  title: settingsT.selectUnits,
                  options: const ['Metric (kg, cm)', 'Imperial (lbs, in)'],
                  selectedValue: profile.unitPreference,
                  onSelected: (selected) => _updateSettings(
                    context,
                    ref,
                    language: language,
                    theme: profile.theme,
                    units: selected,
                    hapticFeedback: profile.hapticFeedback,
                    soundEffects: profile.soundEffects,
                    dataSync: dataSync,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AppSettingsSwitchCard(
                icon: Icons.vibration_rounded,
                title: settingsT.hapticFeedback,
                subtitle: settingsT.hapticFeedbackSubtitle,
                value: profile.hapticFeedback,
                onChanged: (val) => _updateSettings(
                  context,
                  ref,
                  language: language,
                  theme: profile.theme,
                  units: profile.unitPreference,
                  hapticFeedback: val,
                  soundEffects: profile.soundEffects,
                  dataSync: dataSync,
                ),
              ),
              const SizedBox(height: 12),
              AppSettingsSwitchCard(
                icon: Icons.music_note_outlined,
                title: settingsT.soundEffects,
                subtitle: settingsT.soundEffectsSubtitle,
                value: profile.soundEffects,
                onChanged: (val) => _updateSettings(
                  context,
                  ref,
                  language: language,
                  theme: profile.theme,
                  units: profile.unitPreference,
                  hapticFeedback: profile.hapticFeedback,
                  soundEffects: val,
                  dataSync: dataSync,
                ),
              ),
              const SizedBox(height: 12),
              AppSettingsSwitchCard(
                icon: Icons.cloud_outlined,
                title: settingsT.dataSync,
                subtitle: settingsT.dataSyncSubtitle,
                value: dataSync,
                onChanged: (val) => _handleDataSyncChanged(
                  context,
                  ref,
                  profile,
                  language,
                  val,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
