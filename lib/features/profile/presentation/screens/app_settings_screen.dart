import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../core/localization/app_locale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../controllers/profile_controller.dart';

/// Screen 7 Mockup: App Settings
/// - Language selector (English / Bahasa Indonesia)
/// - Theme selector (Light / Dark)
/// - Units selector (Metric kg/cm / Imperial lbs/in)
/// - Haptic Feedback switch
/// - Sound Effects switch
/// - Data Sync switch
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
    // Tampilkan bahasa yang benar-benar aktif (bukan default kolom DB).
    _language = profileLanguageFromAppLocale(ref.read(appLocaleProvider));
    _theme = profile.theme;
    _units = profile.unitPreference;
    _hapticFeedback = profile.hapticFeedback;
    _soundEffects = profile.soundEffects;
    // The consented Supabase account is the source of truth. A saved UI
    // preference alone must never enable remote reads or writes.
    _dataSync = SupabaseConfig.canSyncToCloud;
  }

  Future<void> _handleDataSyncChanged(bool enabled) async {
    if (!enabled) {
      await SupabaseConfig.disableCloudSync();
      if (!mounted) return;
      setState(() => _dataSync = false);
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
    await ref.read(profileControllerProvider.notifier).updateAppSettings(
          language: _language,
          theme: _theme,
          units: _units,
          hapticFeedback: _hapticFeedback,
          soundEffects: _soundEffects,
          dataSync: _dataSync,
        );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select Language',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
              const Divider(height: 1),
              ...['English', 'Bahasa Indonesia'].map((lang) {
                final isSelected = lang == _language;
                return ListTile(
                  title: Text(
                    lang,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.darkCharcoal
                          : AppColors.neutral500,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.greenBrand)
                      : null,
                  tileColor: isSelected
                      ? AppColors.limeCardSurface
                      : Colors.transparent,
                  onTap: () {
                    setState(() => _language = lang);
                    _updateSettings();
                    ref
                        .read(appLocaleProvider.notifier)
                        .setLocale(appLocaleFromProfileLanguage(lang));
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select Theme',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
              const Divider(height: 1),
              ...['Light', 'Dark', 'System Default'].map((t) {
                final isSelected = t == _theme;
                return ListTile(
                  title: Text(
                    t,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.darkCharcoal
                          : AppColors.neutral500,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.greenBrand)
                      : null,
                  tileColor: isSelected
                      ? AppColors.limeCardSurface
                      : Colors.transparent,
                  onTap: () {
                    setState(() => _theme = t);
                    _updateSettings();
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showUnitsPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select Units',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
              const Divider(height: 1),
              ...['Metric (kg, cm)', 'Imperial (lbs, in)'].map((u) {
                final isSelected = u == _units;
                return ListTile(
                  title: Text(
                    u,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.darkCharcoal
                          : AppColors.neutral500,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.greenBrand)
                      : null,
                  tileColor: isSelected
                      ? AppColors.limeCardSurface
                      : Colors.transparent,
                  onTap: () {
                    setState(() => _units = u);
                    _updateSettings();
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF141718),
            size: 24,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'App Settings',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: const Color(0xFF141718),
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
                  color: AppColors.neutral500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),

              // 1. Language Row
              _buildNavigationRow(
                icon: Icons.language_rounded,
                title: 'Language',
                valueText: _language,
                onTap: _showLanguagePicker,
              ),
              const SizedBox(height: 12),

              // 2. Theme Row
              _buildNavigationRow(
                icon: Icons.dark_mode_outlined,
                title: 'Theme',
                valueText: _theme,
                onTap: _showThemePicker,
              ),
              const SizedBox(height: 12),

              // 3. Units Row
              _buildNavigationRow(
                icon: Icons.straighten_rounded,
                title: 'Units',
                valueText: _units,
                onTap: _showUnitsPicker,
              ),
              const SizedBox(height: 12),

              // 4. Haptic Feedback Switch
              _buildSwitchCard(
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

              // 5. Sound Effects Switch
              _buildSwitchCard(
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

              // 6. Data Sync Switch
              _buildSwitchCard(
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

  Widget _buildNavigationRow({
    required IconData icon,
    required String title,
    required String valueText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF141718)),
            const SizedBox(width: 14),
            Text(
              title,
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: const Color(0xFF141718),
              ),
            ),
            const Spacer(),
            Text(
              valueText,
              style: AppTypography.bodySmall.copyWith(
                color: const Color(0xFF141718),
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.neutral500,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF141718)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: const Color(0xFF141718),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: Colors.white,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE2E8F0),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

