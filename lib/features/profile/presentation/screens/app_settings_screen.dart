import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../core/localization/app_locale.dart';
import '../../../../core/theme/app_typography.dart';
import '../controllers/profile_controller.dart';
import '../widgets/app_settings_widgets.dart';

/// Screen 7 Mockup: App Settings (Modular Composition & Full Theme Support)
class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  ConsumerState<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen> {
  late String _language;
  late String _theme;
  late String _units;
  late bool _hapticFeedback;
  late bool _soundEffects;
  late bool _dataSync;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileControllerProvider);
    _language = profileLanguageFromAppLocale(ref.read(appLocaleProvider));
    _theme = profile.theme;
    _units = profile.unitPreference;
    _hapticFeedback = profile.hapticFeedback;
    _soundEffects = profile.soundEffects;
    _dataSync = SupabaseConfig.canSyncToCloud;
  }

  Future<void> _handleDataSyncChanged(bool enabled) async {
    if (!enabled) {
      setState(() => _dataSync = false);
      try {
        await SupabaseConfig.disableCloudSync();
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Cloud Sync was disabled for this session, but its preference could not be saved: $error',
              ),
            ),
          );
        }
      }
      await _updateSettings();
      return;
    }

    final user = SupabaseConfig.currentUser;
    if (user == null || user.isAnonymous) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign in with an account before enabling Cloud Sync.'),
        ),
      );
      return;
    }

    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Enable Cloud Sync?'),
        content: const Text(
          'Your profile, settings, workout history, and progress data will be '
          'synced to your Supabase account. Local SQLite data will remain on '
          'this device. You can turn Cloud Sync off at any time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Agree and enable'),
          ),
        ],
      ),
    );

    if (accepted != true || !mounted) return;

    try {
      await SupabaseConfig.enableCloudSync();
      if (!mounted) return;
      setState(() => _dataSync = true);
      await _updateSettings();
    } catch (error) {
      if (!mounted) return;
      setState(() => _dataSync = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not enable Cloud Sync: $error')),
      );
    }
  }

  Future<void> _updateSettings() async {
    await ref
        .read(profileControllerProvider.notifier)
        .updateAppSettings(
          language: _language,
          theme: _theme,
          units: _units,
          hapticFeedback: _hapticFeedback,
          soundEffects: _soundEffects,
          dataSync: _dataSync,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
          'App Settings',
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
                'Customize your app experience.',
                style: AppTypography.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              AppSettingsNavigationCard(
                icon: Icons.language_rounded,
                title: 'Language',
                valueText: _language,
                onTap: () => showAppSettingsPickerSheet(
                  context: context,
                  title: 'Select Language',
                  options: const ['English', 'Bahasa Indonesia'],
                  selectedValue: _language,
                  onSelected: (lang) {
                    setState(() => _language = lang);
                    _updateSettings();
                    ref
                        .read(appLocaleProvider.notifier)
                        .setLocale(appLocaleFromProfileLanguage(lang));
                  },
                ),
              ),
              const SizedBox(height: 12),
              AppSettingsNavigationCard(
                icon: Icons.dark_mode_outlined,
                title: 'Theme',
                valueText: _theme,
                onTap: () => showAppSettingsPickerSheet(
                  context: context,
                  title: 'Select Theme',
                  options: const ['Light', 'Dark', 'System Default'],
                  selectedValue: _theme,
                  onSelected: (selected) {
                    setState(() => _theme = selected);
                    _updateSettings();
                  },
                ),
              ),
              const SizedBox(height: 12),
              AppSettingsNavigationCard(
                icon: Icons.straighten_rounded,
                title: 'Units',
                valueText: _units,
                onTap: () => showAppSettingsPickerSheet(
                  context: context,
                  title: 'Select Units',
                  options: const ['Metric (kg, cm)', 'Imperial (lbs, in)'],
                  selectedValue: _units,
                  onSelected: (selected) {
                    setState(() => _units = selected);
                    _updateSettings();
                  },
                ),
              ),
              const SizedBox(height: 12),
              AppSettingsSwitchCard(
                icon: Icons.vibration_rounded,
                title: 'Haptic Feedback',
                subtitle: 'Vibrate on actions (start, rest, finish)',
                value: _hapticFeedback,
                onChanged: (val) {
                  setState(() => _hapticFeedback = val);
                  _updateSettings();
                },
              ),
              const SizedBox(height: 12),
              AppSettingsSwitchCard(
                icon: Icons.music_note_outlined,
                title: 'Sound Effects',
                subtitle: 'Workout timer and transitions',
                value: _soundEffects,
                onChanged: (val) {
                  setState(() => _soundEffects = val);
                  _updateSettings();
                },
              ),
              const SizedBox(height: 12),
              AppSettingsSwitchCard(
                icon: Icons.cloud_outlined,
                title: 'Data Sync',
                subtitle: 'Back up your data to your account',
                value: _dataSync,
                onChanged: _handleDataSyncChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
