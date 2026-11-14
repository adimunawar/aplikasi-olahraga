import 'package:flutter/material.dart';
import 'package:workout_app/core/theme/app_colors.dart';

import '../../../exercises/domain/models/exercise.dart';
import '../screens/plans_screen.dart';

enum PlanSessionStatus { completed, activeToday, upcoming }

/// Bagian "Workouts Plan"
/// Menampilkan horizontal week selector dinamis dari database
/// dan daftar sesi latihan dengan status penyelesaian (Selesai, Hari Ini, Mendatang)
/// serta thumbnail visual biomekanika.
class WorkoutsPlanSection extends StatelessWidget {
  final int selectedWeek;
  final int currentActiveWeek;
  final int completedThisWeekCount;
  final int totalWeeks;
  final ValueChanged<int> onSelectWeek;
  final List<SessionWithDetail> sessions;
  final void Function(SessionWithDetail session) onSessionTap;
  final void Function(SessionWithDetail session)? onStartSession;

  const WorkoutsPlanSection({
    super.key,
    required this.selectedWeek,
    this.currentActiveWeek = 1,
    this.completedThisWeekCount = 0,
    required this.totalWeeks,
    required this.onSelectWeek,
    required this.sessions,
    required this.onSessionTap,
    this.onStartSession,
  });

  static const Set<String> _availableThumbnails = {
    'push_up',
    'diamond_push_up',
    'incline_push_up',
    'decline_push_up',
    'pike_push_up',
    'glute_bridge',
    'lunges',
    'split_squat',
    'squad',
  };

  /// Kalkulasi status sesi berdasarkan minggu dan progres penyelesaian
  PlanSessionStatus _getSessionStatus(int index) {
    if (selectedWeek < currentActiveWeek) {
      return PlanSessionStatus.completed;
    } else if (selectedWeek == currentActiveWeek) {
      final activeIndex = sessions.isNotEmpty
          ? completedThisWeekCount % sessions.length
          : 0;
      if (index < activeIndex) {
        return PlanSessionStatus.completed;
      } else if (index == activeIndex) {
        return PlanSessionStatus.activeToday;
      } else {
        return PlanSessionStatus.upcoming;
      }
    } else {
      return PlanSessionStatus.upcoming;
    }
  }

  /// Resolve thumbnail secara dinamis berdasarkan data gerakan di database
  String _getThumbnailForSession(SessionWithDetail item) {
    if (item.detail.exercises.isNotEmpty) {
      final mainExercise = item.detail.exercises.firstWhere(
        (e) => e.prescription.stage == 'main',
        orElse: () => item.detail.exercises.first,
      );

      final id = mainExercise.exercise.id.toLowerCase();
      final normalizedId = (id == 'squat') ? 'squad' : id;

      if (_availableThumbnails.contains(normalizedId)) {
        return 'assets/images/exercises/$normalizedId.webp';
      }

      for (final ex in item.detail.exercises) {
        final otherId = ex.exercise.id.toLowerCase();
        final norm = (otherId == 'squat') ? 'squad' : otherId;
        if (_availableThumbnails.contains(norm)) {
          return 'assets/images/exercises/$norm.webp';
        }
      }

      switch (mainExercise.exercise.category) {
        case ExerciseCategory.legs:
          return 'assets/images/exercises/squad.webp';
        case ExerciseCategory.push:
          return 'assets/images/exercises/push_up.webp';
        case ExerciseCategory.pull:
          return 'assets/images/exercises/incline_push_up.webp';
        case ExerciseCategory.core:
          return 'assets/images/exercises/glute_bridge.webp';
        default:
          return 'assets/images/exercises/push_up.webp';
      }
    }

    return 'assets/images/exercises/push_up.webp';
  }

  String _formatSessionTitle(int index, SessionWithDetail item) {
    final rawName = item.session.name.trim();
    if (rawName.toLowerCase().startsWith('day ')) {
      return rawName;
    }
    return 'Day ${index + 1} – $rawName';
  }

  String _formatTargetMuscles(SessionWithDetail item) {
    if (item.session.focusLabel.isNotEmpty) {
      return item.session.focusLabel;
    }
    final muscles = <String>{};
    for (final ex in item.detail.exercises) {
      for (final m in ex.exercise.primaryMuscles) {
        final label = m.en.isNotEmpty ? m.en : m.id;
        if (label.isNotEmpty) {
          muscles.add(label);
        }
      }
    }
    if (muscles.isNotEmpty) {
      return muscles.take(3).join(' • ');
    }
    return 'Full Body Conditioning';
  }

  @override
  Widget build(BuildContext context) {
    final weekCount = totalWeeks > 0 ? totalWeeks : 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Header: Stacked Layers Icon + "Workouts Plan"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.layers_rounded, color: Color(0xFF141718), size: 20),
                SizedBox(width: 8),
                Text(
                  'Workouts Plan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF141718),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            // Indikator minggu aktif
            if (selectedWeek == currentActiveWeek)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF8D2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Minggu Ini',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3F6212),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // 2. Horizontal Scrollable Week Selector Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(weekCount, (index) {
              final weekNum = index + 1;
              final isSelected = weekNum == selectedWeek;
              final isPastWeek = weekNum < currentActiveWeek;

              return Padding(
                padding: EdgeInsets.only(right: index == weekCount - 1 ? 0 : 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onSelectWeek(weekNum),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : isPastWeek
                            ? const Color(0xFFF1F5F9)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? null
                            : Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1,
                              ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isPastWeek && !isSelected) ...[
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 13,
                              color: Color(0xFF16A34A),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            'Week $weekNum',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected
                                  ? const Color(0xFF141718)
                                  : isPastWeek
                                  ? const Color(0xFF334155)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 14),

        // 3. Workouts List Card Container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: sessions.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Tidak ada jadwal latihan pada minggu ini',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: sessions.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF1F5F9),
                    indent: 14,
                    endIndent: 14,
                  ),
                  itemBuilder: (context, index) {
                    final item = sessions[index];
                    final title = _formatSessionTitle(index, item);
                    final muscles = _formatTargetMuscles(item);
                    final thumbPath = _getThumbnailForSession(item);
                    final status = _getSessionStatus(index);
                    final isCompleted = status == PlanSessionStatus.completed;
                    final isActiveToday =
                        status == PlanSessionStatus.activeToday;
                    final durationMin = item.session.targetDurationMinutes > 0
                        ? item.session.targetDurationMinutes
                        : 30;

                    return Container(
                      decoration: BoxDecoration(
                        color: isActiveToday
                            ? const Color(0xFFFAFEED)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (isActiveToday && onStartSession != null) {
                              onStartSession!(item);
                            } else {
                              onSessionTap(item);
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                // Thumbnail dengan badge status penyelesaian
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        width: 76,
                                        height: 52,
                                        color: const Color(0xFFF1F5F9),
                                        child: Image.asset(
                                          thumbPath,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, _, _) {
                                            return const Center(
                                              child: Icon(
                                                Icons.fitness_center_rounded,
                                                color: Color(0xFF94A3B8),
                                                size: 22,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    // Badge Selesai pada Thumbnail
                                    if (isCompleted)
                                      Positioned(
                                        bottom: -3,
                                        right: -3,
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF22C55E),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            size: 11,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    // Badge Aktif Hari Ini pada Thumbnail
                                    if (isActiveToday)
                                      Positioned(
                                        bottom: -3,
                                        right: -3,
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.play_arrow_rounded,
                                            size: 13,
                                            color: Color(0xFF141718),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                const SizedBox(width: 14),

                                // Title, Target Muscles, dan Keterangan Status
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              title,
                                              style: TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w800,
                                                color: isCompleted
                                                    ? const Color(0xFF334155)
                                                    : const Color(0xFF141718),
                                                letterSpacing: -0.2,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        muscles,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isCompleted
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFF6B7280),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Sisi Kanan: Badge Status (Selesai / Selanjutnya) + Durasi + Chevron
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isCompleted)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDCFCE7),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check_circle_rounded,
                                              size: 11,
                                              color: Color(0xFF15803D),
                                            ),
                                            SizedBox(width: 3),
                                            Text(
                                              'Selesai',
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF15803D),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else if (isActiveToday)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFD4F836),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.play_arrow_rounded,
                                              size: 12,
                                              color: Color(0xFF141718),
                                            ),
                                            SizedBox(width: 2),
                                            Text(
                                              'Mulai',
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF141718),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 13,
                                          color: isCompleted
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFF6B7280),
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          '$durationMin min',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: isCompleted
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF6B7280),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          size: 18,
                                          color: isCompleted
                                              ? const Color(0xFFCBD5E1)
                                              : const Color(0xFF9CA3AF),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
