import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Callback ketika set selesai dicatat
typedef OnSetCompletedCallback = void Function({
  required int actualReps,
  required int rir,
  required double formScore,
});

/// Bottom Sheet Interaktif: Mencatat Hasil Set Aktual & RIR (Reps In Reserve)
/// Sesuai PRD Baru Fase 3 (Perekaman Performa Nyata & Bahan Evaluasi Coach)
class SetCompletionRirSheet extends StatefulWidget {
  final int setNumber;
  final int totalSets;
  final String exerciseName;
  final int targetReps;
  final int restSeconds;
  final OnSetCompletedCallback onConfirm;

  const SetCompletionRirSheet({
    super.key,
    required this.setNumber,
    required this.totalSets,
    required this.exerciseName,
    required this.targetReps,
    this.restSeconds = 60,
    required this.onConfirm,
  });

  static Future<void> show({
    required BuildContext context,
    required int setNumber,
    required int totalSets,
    required String exerciseName,
    required int targetReps,
    int restSeconds = 60,
    required OnSetCompletedCallback onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => SetCompletionRirSheet(
        setNumber: setNumber,
        totalSets: totalSets,
        exerciseName: exerciseName,
        targetReps: targetReps,
        restSeconds: restSeconds,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<SetCompletionRirSheet> createState() => _SetCompletionRirSheetState();
}

class _SetCompletionRirSheetState extends State<SetCompletionRirSheet> {
  late int _reps;
  int _selectedRir = 2; // Default zona ideal (2 RIR)

  final List<_RirOption> _rirOptions = const [
    _RirOption(
      rir: 0,
      title: '0 — Habis Total (Max Failure)',
      description: 'Tenaga habis total, tidak sanggup menambah 1 rep lagi dengan teknik rapi.',
      color: Color(0xFFEF4444),
      badgeText: 'Maksimal',
    ),
    _RirOption(
      rir: 1,
      title: '1 — Sangat Berat',
      description: 'Hanya sanggup 1 repetisi lagi sebelum gagal.',
      color: Color(0xFFF59E0B),
      badgeText: 'Tinggi',
    ),
    _RirOption(
      rir: 2,
      title: '2 — Zona Ideal (Target)',
      description: 'Cukup menantang, masih bisa 2 repetisi lagi jika dipaksa.',
      color: Color(0xFF65A30D),
      badgeText: 'Optimal ⭐',
    ),
    _RirOption(
      rir: 3,
      title: '3 — Cukup Ringan',
      description: 'Masih tersisa 3 repetisi di dalam tangki tenaga.',
      color: Color(0xFF3B82F6),
      badgeText: 'Sedang',
    ),
    _RirOption(
      rir: 4,
      title: '4+ — Terlalu Mudah',
      description: 'Sangat enteng, masih sanggup melakukan 4 repetisi atau lebih.',
      color: Color(0xFF8B5CF6),
      badgeText: 'Ringan',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _reps = widget.targetReps;
  }

  void _submit() {
    Navigator.of(context).pop();
    widget.onConfirm(
      actualReps: _reps,
      rir: _selectedRir,
      formScore: 1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set ${widget.setNumber} of ${widget.totalSets} Complete! 🎉',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A1D1E),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.exerciseName,
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF71767B),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F9EA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFB8E66B)),
                ),
                child: Text(
                  'Target: ${widget.targetReps} reps',
                  style: AppTypography.labelSmall.copyWith(
                    color: const Color(0xFF558B0A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Section 1: Actual Reps Counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Repetisi Selesai',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: const Color(0xFF1A1D1E),
                      ),
                    ),
                    Text(
                      'Berapa kali kamu berhasil?',
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildStepButton(
                      icon: Icons.remove,
                      onTap: () {
                        if (_reps > 1) setState(() => _reps--);
                      },
                    ),
                    const SizedBox(width: 14),
                    Text(
                      '$_reps',
                      style: AppTypography.headlineMedium.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        color: const Color(0xFF1A1D1E),
                      ),
                    ),
                    const SizedBox(width: 14),
                    _buildStepButton(
                      icon: Icons.add,
                      onTap: () => setState(() => _reps++),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 2: RIR Selector
          Text(
            'Sisa Tenaga Kamu (RIR - Reps in Reserve)',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: const Color(0xFF1A1D1E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Berapa repetisi lagi yang sanggup kamu lakukan sebelum benar-benar gagal?',
            style: AppTypography.bodySmall.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),

          // List of RIR options
          Column(
            children: _rirOptions.map((opt) {
              final isSelected = _selectedRir == opt.rir;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => setState(() => _selectedRir = opt.rir),
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF3F9EA) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFB8E66B) : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // ignore: deprecated_member_use
                        Radio<int>(
                          value: opt.rir,
                          // ignore: deprecated_member_use
                          groupValue: _selectedRir,
                          activeColor: const Color(0xFF65A30D),
                          // ignore: deprecated_member_use
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedRir = val);
                          },
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    opt.title,
                                    style: AppTypography.titleSmall.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: const Color(0xFF1A1D1E),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: opt.color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      opt.badgeText,
                                      style: AppTypography.labelSmall.copyWith(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: opt.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                opt.description,
                                style: AppTypography.bodySmall.copyWith(
                                  fontSize: 11,
                                  color: const Color(0xFF64748B),
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
            }).toList(),
          ),
          const SizedBox(height: 18),

          // Confirm Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Simpan & Mulai Istirahat',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${widget.restSeconds}s',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF1A1D1E)),
      ),
    );
  }
}

class _RirOption {
  final int rir;
  final String title;
  final String description;
  final Color color;
  final String badgeText;

  const _RirOption({
    required this.rir,
    required this.title,
    required this.description,
    required this.color,
    required this.badgeText,
  });
}

