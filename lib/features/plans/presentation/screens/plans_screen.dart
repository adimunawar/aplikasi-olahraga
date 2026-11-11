import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/dynamic_program_entity.dart';
import '../../../../core/database/models/user_profile_entity.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/app_data_sync.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../exercises/data/datasources/exercise_local_datasource.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../../program/domain/models/program_day.dart';
import '../../../program/domain/services/dynamic_program_generator.dart';
import '../widgets/roadmap_header_card.dart';
import '../widgets/your_schedule_card.dart';
import '../widgets/workouts_plan_section.dart';
import '../widgets/exercise_library_banner.dart';

class SessionWithDetail {
  final ProgramSessionEntity session;
  final ProgramSessionDetail detail;

  const SessionWithDetail({required this.session, required this.detail});
}

/// Halaman Plan (Roadmap & Kurikulum Program)
/// 100% Sesuai Gambar Referensi Desain Baru & Terintegrasi Penuh ke Database
class PlansScreen extends StatefulWidget {
  final int initialTabIndex;

  const PlansScreen({super.key, this.initialTabIndex = 0});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  final _db = AppDatabase.instance;

  UserProfileEntity? _profile;
  TrainingProgramEntity? _program;
  List<SessionWithDetail> _sessions = [];
  int _completedThisWeekCount = 0;

  int _currentActiveWeek = 1;
  int _selectedWeek = 1;
  int _totalWeeks = 4;
  int _progressPercent = 25;
  bool _isLoading = true;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _loadRoadmapData();
    AppDataSync.instance.dataRevision.addListener(_onDataSync);
  }

  @override
  void dispose() {
    AppDataSync.instance.dataRevision.removeListener(_onDataSync);
    super.dispose();
  }

  void _onDataSync() {
    if (mounted) {
      _loadRoadmapData();
    }
  }

  Future<void> _loadRoadmapData() async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      final profile = await _db.getUserProfile();
      final userId = profile.id.isNotEmpty ? profile.id : 'default_user';

      var program = await _db.getActiveTrainingProgram(userId);
      program ??= await _db.getActiveTrainingProgram('default_user');

      final List<SessionWithDetail> sessionList = [];
      if (program != null) {
        final rawSessions = await _db.getProgramSessions(program.id);
        for (final s in rawSessions) {
          final detail = await _db.getProgramSessionDetail(s.id);
          if (detail != null) {
            sessionList.add(SessionWithDetail(session: s, detail: detail));
          }
        }
      }

      // Auto-generate / Auto-heal jika:
      // 1. Program belum ada di database
      // 2. ATAU sesi latihan kosong
      // 3. ATAU jumlah sesi tidak sesuai dengan frekuensi profil user (misal user ubah dari 3 ke 4 hari)
      final targetWeekly = profile.weeklyFrequency > 0
          ? profile.weeklyFrequency
          : 3;
      if (program == null ||
          sessionList.isEmpty ||
          sessionList.length != targetWeekly) {
        try {
          final exerciseDatasource = ExerciseLocalDatasource(db: _db);
          final catalog = await exerciseDatasource.loadExercises();
          final startingPushId = profile.experienceLevel == 'advanced'
              ? 'diamond_push_up'
              : profile.experienceLevel == 'intermediate'
              ? 'push_up'
              : 'knee_push_up';

          final generated = const DynamicProgramGenerator().generate(
            userProfile: profile,
            catalogExercises: catalog,
            startingPushExerciseId: startingPushId,
          );

          await _db.saveDynamicProgram(
            program: generated.program,
            sessions: generated.sessions,
          );
          program = generated.program;

          sessionList.clear();
          final newRawSessions = await _db.getProgramSessions(program.id);
          for (final s in newRawSessions) {
            final detail = await _db.getProgramSessionDetail(s.id);
            if (detail != null) {
              sessionList.add(SessionWithDetail(session: s, detail: detail));
            }
          }
        } catch (e) {
          debugPrint('[PlansScreen] Error generating dynamic program: $e');
        }
      }

      final thisWeekCount = await _db.getThisWeekCompletedCount();
      final totalWeeks = program?.durationWeeks ?? 4;
      final activeWeek = ((thisWeekCount ~/ targetWeekly) + 1).clamp(
        1,
        totalWeeks,
      );
      final percent = ((activeWeek / totalWeeks) * 100).round().clamp(10, 100);

      if (mounted) {
        setState(() {
          _profile = profile;
          _program = program;
          _sessions = sessionList;
          _completedThisWeekCount = thisWeekCount;
          _currentActiveWeek = activeWeek;
          _selectedWeek = activeWeek;
          _totalWeeks = totalWeeks;
          _progressPercent = percent;
          _isLoading = false;
        });
      }
    } finally {
      _isFetching = false;
    }
  }

  void _showSwitchProgramModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
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
              const SizedBox(height: 18),

              Text(
                'Opsi Program Latihan',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: const Color(0xFF141718),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ganti fokus kurikulum adaptif atau generate ulang jadwal program.',
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFF6B7280),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),

              _buildProgramOption(
                title: 'Full Body Adaptive (Beginner)',
                desc: 'Fokus adaptif seluruh tubuh pemula • 4 Minggu',
                goalKey: 'muscle_gain',
                icon: Icons.fitness_center_rounded,
              ),
              const SizedBox(height: 10),
              _buildProgramOption(
                title: 'Build Pure Strength',
                desc: 'Peningkatan kekuatan calisthenics murni • 4 Minggu',
                goalKey: 'strength',
                icon: Icons.flash_on_rounded,
              ),
              const SizedBox(height: 10),
              _buildProgramOption(
                title: 'Fat Loss & Conditioning',
                desc: 'Definisi otot padat & pembakaran kalori • 4 Minggu',
                goalKey: 'fat_loss',
                icon: Icons.local_fire_department_rounded,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgramOption({
    required String title,
    required String desc,
    required String goalKey,
    required IconData icon,
  }) {
    final isSelected = _profile?.goal.toLowerCase().contains(goalKey) == true;

    return Material(
      color: isSelected ? const Color(0xFFF4F9ED) : const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () async {
          Navigator.pop(context);
          if (_profile != null) {
            setState(() => _isLoading = true);
            final updatedProfile = _profile!.copyWith(goal: goalKey);
            await _db.saveUserProfile(updatedProfile);

            // Re-generate program dinamis
            final exerciseDatasource = ExerciseLocalDatasource(db: _db);
            final catalog = await exerciseDatasource.loadExercises();
            final startingPushId = updatedProfile.experienceLevel == 'advanced'
                ? 'diamond_push_up'
                : updatedProfile.experienceLevel == 'intermediate'
                ? 'push_up'
                : 'knee_push_up';

            final generated = const DynamicProgramGenerator().generate(
              userProfile: updatedProfile,
              catalogExercises: catalog,
              startingPushExerciseId: startingPushId,
            );

            await _db.saveDynamicProgram(
              program: generated.program,
              sessions: generated.sessions,
            );

            await _loadRoadmapData();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Program berhasil diubah ke $title!'),
                  backgroundColor: const Color(0xFF141718),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF84CC16)
                  : const Color(0xFFE5E7EB),
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF84CC16)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? const Color(0xFF141718)
                      : const Color(0xFF4B5563),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: const Color(0xFF141718),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFF6B7280),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF84CC16),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditScheduleModal() {
    if (_profile == null) return;
    final currentDays = List<String>.from(_profile!.availableDays);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
                  const SizedBox(height: 18),
                  Text(
                    'Edit Schedule',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: const Color(0xFF141718),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih hari latihan mingguan Anda (${currentDays.length} hari latihan terpilih)',
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: kWeekDays.map((day) {
                      final isSelected = currentDays.any(
                        (d) => d.toLowerCase() == day.key.toLowerCase(),
                      );
                      return FilterChip(
                        label: Text(day.label),
                        selected: isSelected,
                        selectedColor: const Color(0xFFD4F836),
                        checkmarkColor: const Color(0xFF141718),
                        labelStyle: TextStyle(
                          color: const Color(0xFF141718),
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              if (!currentDays.contains(day.key)) {
                                currentDays.add(day.key);
                              }
                            } else {
                              if (currentDays.length > 1) {
                                currentDays.removeWhere(
                                  (d) =>
                                      d.toLowerCase() == day.key.toLowerCase(),
                                );
                              }
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        setState(() => _isLoading = true);
                        final updatedProfile = _profile!.copyWith(
                          availableDays: currentDays,
                          weeklyFrequency: currentDays.length,
                          preferredDaysPerWeek: currentDays.length,
                        );
                        await _db.saveUserProfile(updatedProfile);
                        await _loadRoadmapData();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Jadwal diperbarui: ${currentDays.length} hari latihan / minggu!',
                              ),
                              backgroundColor: const Color(0xFF141718),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF84CC16),
                        foregroundColor: const Color(0xFF141718),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Simpan Jadwal',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _startWorkoutSession(SessionWithDetail s) async {
    final exercises = s.detail.exercises.map((e) => e.exercise).toList();
    final workoutItems = s.detail.exercises.map((e) {
      return WorkoutItem(
        exerciseId: e.exercise.id,
        sets: e.prescription.targetSets,
        reps: e.prescription.minReps,
        restSeconds: e.prescription.restSeconds,
        isMain: e.prescription.stage == 'main',
        stage: e.prescription.stage,
      );
    }).toList();

    final programDay = ProgramDay(
      day: s.session.dayNumber,
      week: _selectedWeek,
      type: WorkoutTypeCode.f,
      focus: LocalizedString(
        id: s.session.focusLabel,
        en: s.session.focusLabel,
      ),
      isRest: false,
      isRetestMilestone: false,
      items: workoutItems,
    );

    await context.push(
      AppRoutes.workoutSession,
      extra: WorkoutSessionArgs(day: programDay, exercises: exercises),
    );
    if (mounted) {
      _loadRoadmapData();
    }
  }

  Future<void> _previewSession(SessionWithDetail s) async {
    await context.push(
      AppRoutes.workoutDetail,
      extra: WorkoutDetailArgs(
        dayNumber: s.session.dayNumber,
        weekDayText: 'Week $_selectedWeek • Day ${s.session.dayNumber}',
        workoutTitle: s.session.focusLabel,
        targetMusclesText: _program?.name ?? 'Full Body Adaptive',
        durationText: '${s.session.targetDurationMinutes} min',
        levelText: _profile?.experienceLevel ?? 'Beginner',
      ),
    );
    if (mounted) {
      _loadRoadmapData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF84CC16)),
        ),
      );
    }

    final programTitle = _program?.name.isNotEmpty == true
        ? _program!.name
        : 'Full Body Adaptive (Beginner)';
    final weeklySessions = _sessions.isNotEmpty ? _sessions.length : 3;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // 1. Top Bar: Back Arrow ← | Plan Title | ••• Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Plan',
                    style: AppTypography.headlineLarge.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: const Color(0xFF141718),
                    ),
                  ),
                  InkWell(
                    onTap: _showSwitchProgramModal,
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.more_horiz_rounded,
                        color: Color(0xFF141718),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 2. Hero Card Kurikulum & Roadmap Program (Coach Adi, Full Body Adaptive, Meta)
              RoadmapHeaderCard(
                programTitle: programTitle,
                currentWeek: _currentActiveWeek,
                totalWeeks: _totalWeeks,
                progressPercent: _progressPercent,
                weeklySessions: weeklySessions,
                onSwitchProgram: _showSwitchProgramModal,
              ),

              const SizedBox(height: 18),

              // 3. Your Schedule Card (Jadwal Hari Latihan & Istirahat)
              YourScheduleCard(
                availableDays:
                    _profile?.availableDays ??
                    const ['monday', 'wednesday', 'friday', 'sunday'],
                weeklyWorkouts: _profile?.weeklyFrequency ?? 4,
                onEditSchedule: _showEditScheduleModal,
              ),

              const SizedBox(height: 18),

              // 4. Workouts Plan (Week Selector Dinamis + Workout Sessions List)
              WorkoutsPlanSection(
                selectedWeek: _selectedWeek,
                currentActiveWeek: _currentActiveWeek,
                completedThisWeekCount: _completedThisWeekCount,
                totalWeeks: _totalWeeks,
                onSelectWeek: (w) => setState(() => _selectedWeek = w),
                sessions: _sessions,
                onSessionTap: (item) => _previewSession(item),
                onStartSession: (item) => _startWorkoutSession(item),
              ),

              const SizedBox(height: 20),

              // 6. Quick Access: Perpustakaan 18 Gerakan Biomekanika
              ExerciseLibraryBanner(
                onOpenLibrary: () => context.push(AppRoutes.exercises),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
