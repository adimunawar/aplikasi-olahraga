import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class HomeNotificationItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String timeText;
  final VoidCallback? onTap;

  const HomeNotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.timeText,
    this.onTap,
  });
}

/// Bottom Sheet Notifikasi Interaktif & Aksi Nyata (Phase C Point 2)
class HomeNotificationBottomSheet extends StatefulWidget {
  final String sessionFocus;
  final int durationMinutes;
  final String targetMuscles;
  final VoidCallback? onStartWorkout;
  final VoidCallback? onOpenRecoveryGuide;
  final VoidCallback? onAllRead;

  const HomeNotificationBottomSheet({
    super.key,
    required this.sessionFocus,
    required this.durationMinutes,
    required this.targetMuscles,
    this.onStartWorkout,
    this.onOpenRecoveryGuide,
    this.onAllRead,
  });

  static Future<void> show(
    BuildContext context, {
    required String sessionFocus,
    required int durationMinutes,
    required String targetMuscles,
    VoidCallback? onStartWorkout,
    VoidCallback? onOpenRecoveryGuide,
    VoidCallback? onAllRead,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HomeNotificationBottomSheet(
        sessionFocus: sessionFocus,
        durationMinutes: durationMinutes,
        targetMuscles: targetMuscles,
        onStartWorkout: onStartWorkout,
        onOpenRecoveryGuide: onOpenRecoveryGuide,
        onAllRead: onAllRead,
      ),
    );
  }

  @override
  State<HomeNotificationBottomSheet> createState() =>
      _HomeNotificationBottomSheetState();
}

class _HomeNotificationBottomSheetState
    extends State<HomeNotificationBottomSheet> {
  late List<HomeNotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  void _initNotifications() {
    _notifications = [
      HomeNotificationItem(
        id: 'workout_today',
        title: 'Sesi Latihan Hari Ini: ${widget.sessionFocus}',
        description:
            '${widget.durationMinutes} mnt • Target: ${widget.targetMuscles}. Yuk tuntaskan!',
        icon: Icons.fitness_center_rounded,
        iconColor: const Color(0xFF65A30D),
        iconBgColor: const Color(0xFFF3F9EA),
        timeText: 'Hari ini',
        onTap: () {
          Navigator.pop(context);
          widget.onStartWorkout?.call();
        },
      ),
      HomeNotificationItem(
        id: 'recovery_hydration',
        title: 'Tips Pemulihan & Hidrasi',
        description: 'Minum air cukup dan istirahat berkualitas membantu sintesis massa otot.',
        icon: Icons.water_drop_rounded,
        iconColor: const Color(0xFF0284C7),
        iconBgColor: const Color(0xFFE0F2FE),
        timeText: '1 jam lalu',
        onTap: () {
          Navigator.pop(context);
          widget.onOpenRecoveryGuide?.call();
        },
      ),
      HomeNotificationItem(
        id: 'reminder_settings',
        title: 'Atur Jadwal Pengingat Latihan',
        description: 'Sesuaikan jam pengingat agar rutinitas latihan harianmu selalu tepat waktu.',
        icon: Icons.alarm_rounded,
        iconColor: const Color(0xFFD97706),
        iconBgColor: const Color(0xFFFEF3C7),
        timeText: 'Kemarin',
        onTap: () {
          Navigator.pop(context);
          context.push(AppRoutes.reminders);
        },
      ),
    ];
  }

  void _clearAll() {
    setState(() {
      _notifications.clear();
    });
    widget.onAllRead?.call();
  }

  void _removeItem(String id) {
    setState(() {
      _notifications.removeWhere((item) => item.id == id);
    });
    if (_notifications.isEmpty) {
      widget.onAllRead?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row: Title & Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Notifikasi',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    if (_notifications.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4F836),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_notifications.length}',
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (_notifications.isNotEmpty)
                  TextButton(
                    onPressed: _clearAll,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(
                      'Tandai Semua Dibaca',
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFF65A30D),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Content List or Empty State
            if (_notifications.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3F9EA),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.done_all_rounded,
                          color: Color(0xFF65A30D),
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Semua notifikasi sudah dibaca',
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kamu sudah up-to-date dengan jadwal latihanmu!',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _notifications.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = _notifications[index];
                    return Dismissible(
                      key: ValueKey(item.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _removeItem(item.id),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 18),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                        ),
                      ),
                      child: InkWell(
                        onTap: item.onTap,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFF1F3F5),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: item.iconBgColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  item.icon,
                                  color: item.iconColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: AppTypography.titleSmall
                                                .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13.5,
                                                  color: AppColors.darkCharcoal,
                                                ),
                                          ),
                                        ),
                                        Text(
                                          item.timeText,
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                                fontSize: 10.5,
                                                color: AppColors.neutral400,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.description,
                                      style: AppTypography.bodySmall.copyWith(
                                        fontSize: 12,
                                        color: AppColors.neutral600,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            // Shortcut Button: Atur Pengingat
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.reminders);
                },
                icon: const Icon(
                  Icons.settings_outlined,
                  size: 18,
                  color: AppColors.darkCharcoal,
                ),
                label: Text(
                  'Atur Pengingat & Jam Notifikasi',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkCharcoal,
                    fontSize: 13,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
