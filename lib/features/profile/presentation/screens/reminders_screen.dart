import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../controllers/profile_controller.dart';

/// Screen 6 Mockup: Reminders
/// - Workout Reminder Switch
/// - Reminder Time Picker (e.g. 08:00 PM)
/// - Rest Day Reminder Switch
/// - Progress Check-in Switch
/// - Streak Reminder Switch
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
    await ref.read(profileControllerProvider.notifier).updateReminders(
          workoutReminder: _workoutReminder,
          reminderTime: _reminderTime,
          restDayReminder: _restDayReminder,
          progressCheckin: _progressCheckin,
          streakReminder: _streakReminder,
        );
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.greenBrand,
              onPrimary: Colors.white,
              onSurface: AppColors.darkCharcoal,
            ),
          ),
          child: child!,
        );
      },
    );

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
          'Reminders',
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
                'Get notifications to stay consistent.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),

              // 1. Workout Reminder Switch
              _buildSwitchCard(
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

              // 2. Reminder Time Row
              InkWell(
                onTap: _workoutReminder ? _pickTime : null,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFFE9ECEF), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 20, color: Color(0xFF141718)),
                      const SizedBox(width: 14),
                      Text(
                        'Reminder Time',
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: const Color(0xFF141718),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _reminderTime,
                        style: AppTypography.bodySmall.copyWith(
                          color: _workoutReminder
                              ? const Color(0xFF141718)
                              : AppColors.neutral400,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: _workoutReminder
                            ? AppColors.neutral500
                            : AppColors.neutral300,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 3. Rest Day Reminder Switch
              _buildSwitchCard(
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

              // 4. Progress Check-in Switch
              _buildSwitchCard(
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

              // 5. Streak Reminder Switch
              _buildSwitchCard(
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
            activeThumbColor: Colors.white,
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

