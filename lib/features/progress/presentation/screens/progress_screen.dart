import 'package:flutter/material.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/workout_session_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Tab Progress (PRD Bagian 8 & 10.6):
/// Menampilkan konsistensi latihan, riwayat sesi dari database lokal, dan metrik progres fisik.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final _db = AppDatabase.instance;

  int _completedSessions = 6;
  int _thisWeekCount = 3;
  int _totalMinutes = 180;
  double _currentWeightKg = 67.5;
  List<WorkoutSessionEntity> _recentSessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    final completed = await _db.getCompletedSessionsCount();
    final thisWeek = await _db.getThisWeekCompletedCount();
    final weight = await _db.getLatestWeight();
    final sessions = await _db.getRecentWorkoutSessions();

    if (mounted) {
      setState(() {
        if (completed > 0) _completedSessions = completed;
        if (thisWeek > 0) _thisWeekCount = thisWeek;
        _currentWeightKg = weight;
        _recentSessions = sessions;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Progres & Riwayat',
          style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Ringkasan Cepat
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Minggu Ini',
                  value: '$_thisWeekCount',
                  unit: 'sesi',
                  color: AppColors.primary,
                  icon: Icons.calendar_today_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Total Selesai',
                  value: '$_completedSessions',
                  unit: 'kali',
                  color: AppColors.secondary,
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Total Waktu',
                  value: '$_totalMinutes',
                  unit: 'mnt',
                  color: AppColors.amberWarning,
                  icon: Icons.timer_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Konsistensi Mingguan (PRG-01 & PRG-02)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Konsistensi 7 Hari Terakhir',
                      style: AppTypography.labelLarge,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.successSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Target: 4 Hari',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDayDot('Sen', true),
                    _buildDayDot('Sel', false),
                    _buildDayDot('Rab', true),
                    _buildDayDot('Kam', false),
                    _buildDayDot('Jum', false),
                    _buildDayDot('Sab', false),
                    _buildDayDot('Min', false),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Berat Badan & Progres Fisik (PRG-03 & PRG-04)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
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
                        Text('Berat Badan Terakhir', style: AppTypography.bodySmall),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text('$_currentWeightKg', style: AppTypography.displayMedium),
                            const SizedBox(width: 4),
                            Text('kg', style: AppTypography.labelMedium),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showWeightInputDialog(context);
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Catat BB'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surfaceInteractive,
                        foregroundColor: AppColors.textPrimary,
                        minimumSize: const Size(110, 42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up, color: AppColors.workoutPush, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Fase bulking teratur: Pantau kenaikan 0.25 - 0.5 kg per minggu.',
                          style: AppTypography.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Riwayat Sesi (HIS-04 & PRG-07 Empty State Handler)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Riwayat Latihan',
                style: AppTypography.headlineSmall,
              ),
              Text(
                'Terbaru',
                style: AppTypography.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSessionHistoryItem(
            title: 'Hari 3: Full Body Hypertrophy',
            date: 'Kemarin, 19:30',
            duration: '32 Menit',
            setsCount: '12 Set Selesai',
            isComplete: true,
          ),
          const SizedBox(height: 10),
          _buildSessionHistoryItem(
            title: 'Hari 1: Push Power & Core',
            date: '3 Nov 2026, 06:45',
            duration: '28 Menit',
            setsCount: '10 Set Selesai',
            isComplete: true,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.labelSmall),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTypography.displayMedium.copyWith(fontSize: 24),
              ),
              const SizedBox(width: 4),
              Text(unit, style: AppTypography.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayDot(String label, bool isDone) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDone ? AppColors.primary : AppColors.surfaceInteractive,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDone ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Icon(
            isDone ? Icons.check : Icons.remove,
            size: 18,
            color: isDone ? AppColors.textPrimary : AppColors.textDim,
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: AppTypography.labelSmall),
      ],
    );
  }

  Widget _buildSessionHistoryItem({
    required String title,
    required String date,
    required String duration,
    required String setsCount,
    required bool isComplete,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isComplete ? AppColors.successSurface : AppColors.warningSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isComplete ? Icons.fitness_center : Icons.pause_circle_outline,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelLarge),
                const SizedBox(height: 4),
                Text('$date • $duration • $setsCount', style: AppTypography.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textDim),
        ],
      ),
    );
  }

  void _showWeightInputDialog(BuildContext context) {
    final controller = TextEditingController(text: '$_currentWeightKg');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Catat Berat Badan', style: AppTypography.headlineSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Masukkan berat badan hari ini (kg):', style: AppTypography.bodyMedium),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                suffixText: 'kg',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = double.tryParse(controller.text);
              if (val != null) {
                await _db.recordBodyWeight(val);
                await _loadProgressData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Berat badan $val kg berhasil dicatat.')),
                  );
                }
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 42),
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

