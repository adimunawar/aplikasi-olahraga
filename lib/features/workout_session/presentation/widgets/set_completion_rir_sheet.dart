import 'package:material_ui/material_ui.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';

/// Callback ketika set selesai dicatat
typedef OnSetCompletedCallback = void Function({
  int? actualReps,
  int? durationSeconds,
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
  final bool isDuration;
  final int? targetDurationSeconds;
  final int? initialValue;
  final int restSeconds;
  final OnSetCompletedCallback onConfirm;

  const SetCompletionRirSheet({
    super.key,
    required this.setNumber,
    required this.totalSets,
    required this.exerciseName,
    required this.targetReps,
    this.isDuration = false,
    this.targetDurationSeconds,
    this.initialValue,
    this.restSeconds = 60,
    required this.onConfirm,
  });

  static Future<void> show({
    required BuildContext context,
    required int setNumber,
    required int totalSets,
    required String exerciseName,
    required int targetReps,
    bool isDuration = false,
    int? targetDurationSeconds,
    int? initialValue,
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
        isDuration: isDuration,
        targetDurationSeconds: targetDurationSeconds,
        initialValue: initialValue,
        restSeconds: restSeconds,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<SetCompletionRirSheet> createState() => _SetCompletionRirSheetState();
}

class _SetCompletionRirSheetState extends State<SetCompletionRirSheet> {
  late int _value;
  int _selectedRir = 2; // Default zona ideal (2 RIR)

  List<_RirOption> _buildRirOptions(Translations t) {
    return [
      _RirOption(
        rir: 0,
        title: t.workoutSession.rirFailureTitle,
        description: t.workoutSession.rirFailureDescription,
        color: const Color(0xFFEF4444),
        badgeText: t.workoutSession.rirBadgeMax,
      ),
      _RirOption(
        rir: 1,
        title: t.workoutSession.rirVeryHardTitle,
        description: t.workoutSession.rirVeryHardDescription,
        color: const Color(0xFFF59E0B),
        badgeText: t.workoutSession.rirBadgeHigh,
      ),
      _RirOption(
        rir: 2,
        title: t.workoutSession.rirIdealTitle,
        description: t.workoutSession.rirIdealDescription,
        color: const Color(0xFF65A30D),
        badgeText: t.workoutSession.rirBadgeOptimal,
      ),
      _RirOption(
        rir: 3,
        title: t.workoutSession.rirModerateTitle,
        description: t.workoutSession.rirModerateDescription,
        color: const Color(0xFF3B82F6),
        badgeText: t.workoutSession.rirBadgeModerate,
      ),
      _RirOption(
        rir: 4,
        title: t.workoutSession.rirEasyTitle,
        description: t.workoutSession.rirEasyDescription,
        color: const Color(0xFF8B5CF6),
        badgeText: t.workoutSession.rirBadgeEasy,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue ??
        (widget.isDuration
            ? (widget.targetDurationSeconds ?? widget.targetReps)
            : widget.targetReps);
  }

  void _submit() {
    Navigator.of(context).pop();
    widget.onConfirm(
      actualReps: widget.isDuration ? null : _value,
      durationSeconds: widget.isDuration ? _value : null,
      rir: _selectedRir,
      formScore: 1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final rirOptions = _buildRirOptions(t);

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
                    t.workoutSession.setCompleteTitle(
                      current: widget.setNumber,
                      total: widget.totalSets,
                    ),
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
                  widget.isDuration
                      ? t.workoutSession.targetDuration(
                          seconds: widget.targetDurationSeconds ?? widget.targetReps,
                        )
                      : t.workoutSession.targetReps(reps: widget.targetReps),
                  style: AppTypography.labelSmall.copyWith(
                    color: const Color(0xFF558B0A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Section 1: Actual Counter (Reps atau Durasi)
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
                      widget.isDuration
                          ? t.workoutSession.durationCompleted
                          : t.workoutSession.repsCompleted,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: const Color(0xFF1A1D1E),
                      ),
                    ),
                    Text(
                      widget.isDuration
                          ? t.workoutSession.durationQuestion
                          : t.workoutSession.repsQuestion,
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
                        if (widget.isDuration) {
                          if (_value > 5) {
                            setState(() => _value -= 5);
                          } else if (_value > 1) {
                            setState(() => _value = 1);
                          }
                        } else {
                          if (_value > 1) setState(() => _value--);
                        }
                      },
                    ),
                    const SizedBox(width: 14),
                    Text(
                      widget.isDuration ? t.workoutSession.durationValue(value: _value) : '$_value',
                      style: AppTypography.headlineMedium.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: const Color(0xFF1A1D1E),
                      ),
                    ),
                    const SizedBox(width: 14),
                    _buildStepButton(
                      icon: Icons.add,
                      onTap: () {
                        if (widget.isDuration) {
                          setState(() => _value += 5);
                        } else {
                          setState(() => _value++);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 2: RIR Selector
          Text(
            t.workoutSession.rirTitle,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: const Color(0xFF1A1D1E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            t.workoutSession.rirQuestion,
            style: AppTypography.bodySmall.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),

          // List of RIR options
          Column(
            children: rirOptions.map((opt) {
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
                  Text(
                    t.workoutSession.saveAndStartRest,
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
                      t.workoutSession.restSecondsValue(seconds: widget.restSeconds),
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

