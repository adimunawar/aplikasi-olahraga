import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../controllers/profile_controller.dart';
import '../widgets/app_settings_widgets.dart';

/// Screen 6 Mockup: Reminders (Light & Dark Mode)
class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  late bool _workoutReminder;
  late String _reminderTime;
  late bool _restDayReminder;
  late bool _progressCheckin;
  late bool _streakReminder;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileControllerProvider);
    _workoutReminder = profile.workoutReminder;
    _reminderTime = profile.reminderTime;
    _restDayReminder = profile.restDayReminder;
    _progressCheckin = profile.progressCheckin;
    _streakReminder = profile.streakReminder;
  }

  Future<void> _updateSettings() async {
    await ref
        .read(profileControllerProvider.notifier)
        .updateReminders(
          workoutReminder: _workoutReminder,
          reminderTime: _reminderTime,
          restDayReminder: _restDayReminder,
          progressCheckin: _progressCheckin,
          streakReminder: _streakReminder,
        );
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: now);

    if (picked != null) {
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      final formatted =
          '${hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} $period';

      setState(() => _reminderTime = formatted);
      _updateSettings();
    }
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
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
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
          'Reminders',
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
                'Get notifications to stay consistent.',
                style: AppTypography.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              AppSettingsSwitchCard(
                icon: Icons.notifications_none_rounded,
                title: 'Workout Reminder',
                subtitle: 'Remind me when it\'s time to workout',
                value: _workoutReminder,
                onChanged: (val) {
                  setState(() => _workoutReminder = val);
                  _updateSettings();
                },
              ),
              const SizedBox(height: 12),
              Opacity(
                opacity: _workoutReminder ? 1.0 : 0.5,
                child: AppCard(
                  onTap: _workoutReminder ? _pickTime : null,
                  variant: AppCardVariant.flat,
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 20,
                        color: colorScheme.onSurface,
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Reminder Time',
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _reminderTime,
                        style: AppTypography.bodySmall.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AppSettingsSwitchCard(
                icon: Icons.calendar_today_outlined,
                title: 'Rest Day Reminder',
                subtitle: 'A gentle reminder on rest days',
                value: _restDayReminder,
                onChanged: (val) {
                  setState(() => _restDayReminder = val);
                  _updateSettings();
                },
              ),
              const SizedBox(height: 12),
              AppSettingsSwitchCard(
                icon: Icons.bar_chart_rounded,
                title: 'Progress Check-in',
                subtitle: 'Weekly summary and progress',
                value: _progressCheckin,
                onChanged: (val) {
                  setState(() => _progressCheckin = val);
                  _updateSettings();
                },
              ),
              const SizedBox(height: 12),
              AppSettingsSwitchCard(
                icon: Icons.local_fire_department_outlined,
                title: 'Streak Reminder',
                subtitle: 'Keep your workout streak going',
                value: _streakReminder,
                onChanged: (val) {
                  setState(() => _streakReminder = val);
                  _updateSettings();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
