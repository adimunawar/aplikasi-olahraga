import 'package:flutter/material.dart';
import '../../../../core/database/models/dynamic_program_entity.dart';
import '../../../../core/database/models/user_profile_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../screens/plans_screen.dart';

class DayScheduleItem {
  final String dayAbbr;
  final String dayName;
  final bool isRest;
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final SessionWithDetail? session;

  const DayScheduleItem({
    required this.dayAbbr,
    required this.dayName,
    required this.isRest,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.session,
  });
}

class PlansWorkoutSplitTab extends StatelessWidget {
  final UserProfileEntity? profile;
  final TrainingProgramEntity? program;
  final List<SessionWithDetail> sessions;
  final Function(SessionWithDetail) onSessionTap;
  final VoidCallback? onEditSchedule;

  const PlansWorkoutSplitTab({
    super.key,
    required this.profile,
    required this.program,
    required this.sessions,
    required this.onSessionTap,
    this.onEditSchedule,
  });

  List<DayScheduleItem> _buildSchedule() {
    final availableDays = profile?.availableDays.map((d) => d.toLowerCase()).toList() ??
        ['monday', 'wednesday', 'thursday', 'saturday'];

    final weekDays = [
      {'abbr': 'Mon', 'key': 'monday', 'name': 'Monday'},
      {'abbr': 'Tue', 'key': 'tuesday', 'name': 'Tuesday'},
      {'abbr': 'Wed', 'key': 'wednesday', 'name': 'Wednesday'},
      {'abbr': 'Thu', 'key': 'thursday', 'name': 'Thursday'},
      {'abbr': 'Fri', 'key': 'friday', 'name': 'Friday'},
      {'abbr': 'Sat', 'key': 'saturday', 'name': 'Saturday'},
      {'abbr': 'Sun', 'key': 'sunday', 'name': 'Sunday'},
    ];

    int sessionIndex = 0;
    final List<DayScheduleItem> items = [];

    for (final wd in weekDays) {
      final key = wd['key']!;
      final abbr = wd['abbr']!;
      final name = wd['name']!;
      final isWorkoutDay = availableDays.contains(key);

      if (isWorkoutDay && sessions.isNotEmpty) {
        final session = sessions[sessionIndex % sessions.length];
        sessionIndex++;

        final focus = session.session.focusLabel.isNotEmpty
            ? session.session.focusLabel
            : 'Full Body Workout';

        IconData icon = Icons.fitness_center_rounded;
        Color iconColor = const Color(0xFF141718);
        Color iconBg = const Color(0xFFD4F836);

        final lowerFocus = focus.toLowerCase();
        if (lowerFocus.contains('push') || lowerFocus.contains('chest')) {
          icon = Icons.fitness_center_rounded;
        } else if (lowerFocus.contains('pull') || lowerFocus.contains('back')) {
          icon = Icons.fitness_center_rounded;
        } else if (lowerFocus.contains('lower') || lowerFocus.contains('leg')) {
          icon = Icons.directions_run_rounded;
        } else if (lowerFocus.contains('full')) {
          icon = Icons.sports_gymnastics_rounded;
        }

        items.add(DayScheduleItem(
          dayAbbr: abbr,
          dayName: name,
          isRest: false,
          title: focus,
          icon: icon,
          iconColor: iconColor,
          iconBgColor: iconBg,
          session: session,
        ));
      } else {
        // Rest / Recovery Day
        final isSunday = key == 'sunday';
        items.add(DayScheduleItem(
          dayAbbr: abbr,
          dayName: name,
          isRest: true,
          title: isSunday ? 'Rest' : 'Rest / Recovery',
          icon: Icons.coffee_rounded,
          iconColor: const Color(0xFF6B7280),
          iconBgColor: const Color(0xFFF3F4F6),
          session: null,
        ));
      }
    }

    return items;
  }

  void _showRestDayDialog(BuildContext context, String dayName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.coffee_rounded, color: Color(0xFF4B5563)),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$dayName • Rest & Recovery',
                        style: AppTypography.headlineSmall.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Crucial time for muscle protein synthesis',
                        style: AppTypography.bodySmall.copyWith(
                          color: const Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildRecoveryTip(
                Icons.water_drop_outlined,
                'Hydration & Nutrition',
                'Drink at least 2.5 - 3 liters of water and hit your daily protein goal.',
              ),
              const SizedBox(height: 12),
              _buildRecoveryTip(
                Icons.bedtime_outlined,
                'Quality Sleep',
                'Aim for 7 to 8 hours of uninterrupted sleep for maximum growth hormone release.',
              ),
              const SizedBox(height: 12),
              _buildRecoveryTip(
                Icons.directions_walk_rounded,
                'Active Recovery',
                'Light walking or gentle mobility work helps flush metabolic waste without fatigue.',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkCharcoal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Got it!', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecoveryTip(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF84CC16)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFF6B7280),
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheduleItems = _buildSchedule();
    final workoutDaysCount = profile?.weeklyFrequency ?? 4;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly Schedule Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.cardBorder, width: 1.2),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Schedule',
                          style: AppTypography.headlineSmall.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Your $workoutDaysCount-days workout plan with recovery days.',
                          style: AppTypography.bodySmall.copyWith(
                            color: const Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (onEditSchedule != null)
                      InkWell(
                        onTap: onEditSchedule,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            'Edit',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),

                // Days list Mon - Sun
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: scheduleItems.length,
                  separatorBuilder: (context, index) => const Divider(
                    color: Color(0xFFF3F4F6),
                    height: 18,
                    thickness: 1,
                  ),
                  itemBuilder: (context, index) {
                    final item = scheduleItems[index];

                    return InkWell(
                      onTap: () {
                        if (item.session != null) {
                          onSessionTap(item.session!);
                        } else {
                          _showRestDayDialog(context, item.dayName);
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            // Day Abbreviation Pill
                            Container(
                              width: 44,
                              height: 32,
                              decoration: BoxDecoration(
                                color: item.isRest
                                    ? const Color(0xFFF3F4F6)
                                    : const Color(0xFFF4F9ED),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                item.dayAbbr,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  color: item.isRest
                                      ? const Color(0xFF9CA3AF)
                                      : const Color(0xFF141718),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Focus Icon
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: item.iconBgColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                item.icon,
                                size: 18,
                                color: item.iconColor,
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Focus Title
                            Expanded(
                              child: Text(
                                item.title,
                                style: AppTypography.labelLarge.copyWith(
                                  fontWeight: item.isRest ? FontWeight.w600 : FontWeight.w800,
                                  fontSize: 13.5,
                                  color: item.isRest
                                      ? const Color(0xFF6B7280)
                                      : AppColors.darkCharcoal,
                                ),
                              ),
                            ),

                            // Trailing Chevron
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                              color: Color(0xFF9CA3AF),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

