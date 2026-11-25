import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/database/models/dynamic_program_entity.dart';
import 'package:workout_app/core/theme/app_colors.dart';
import 'package:workout_app/core/theme/app_typography.dart';
import 'package:workout_app/features/program/domain/models/program_lifecycle.dart';
import 'package:workout_app/i18n/strings.g.dart';

/// Kartu ringkasan program aktif di bagian atas tab "Program Saya".
class ActiveProgramCard extends StatelessWidget {
  final TrainingProgramEntity program;
  final int totalWeeks;
  final ProgramLifecycleInfo lifecycle;
  final double progressPercent;
  final int percentInt;
  final VoidCallback onTap;

  const ActiveProgramCard({
    super.key,
    required this.program,
    required this.totalWeeks,
    required this.lifecycle,
    required this.progressPercent,
    required this.percentInt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = isDark ? theme.colorScheme.surface : Colors.white;
    final borderColor = isDark
        ? theme.colorScheme.outline
        : const Color(0xFFE5E7EB);
    final titleColor = theme.colorScheme.onSurface;
    final subtextColor = theme.colorScheme.onSurfaceVariant;
    final thumbBgColor = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : const Color(0xFFF3F4F6);
    final progressBgColor = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : const Color(0xFFE5E7EB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.workouts.activeProgram.title,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 16.5,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? const Color(0x22000000)
                      : const Color(0x06000000),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: thumbBgColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          'assets/images/coach_hero.png',
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.fitness_center_rounded,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            program.name,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 15.5,
                              color: titleColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            t.workouts.activeProgram.weeksHomeWorkout(
                              weeks: totalWeeks,
                            ),
                            style: AppTypography.bodySmall.copyWith(
                              color: subtextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: subtextColor,
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _programLifecycleLabel(context, t, lifecycle),
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 12,
                          color: _programLifecycleColor(
                            isDark,
                            lifecycle.state,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '$percentInt%',
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 12,
                        color: subtextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progressPercent,
                    minHeight: 6,
                    backgroundColor: progressBgColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _programLifecycleLabel(
    BuildContext context,
    Translations t,
    ProgramLifecycleInfo lifecycle,
  ) {
    switch (lifecycle.state) {
      case ProgramLifecycle.notStarted:
        final date = MaterialLocalizations.of(context)
            .formatMediumDate(lifecycle.startDate);
        return t.workouts.activeProgram.status.notStarted(date: date);
      case ProgramLifecycle.completed:
        return t.workouts.activeProgram.status.completed;
      case ProgramLifecycle.expired:
        return t.workouts.activeProgram.status.expired;
      case ProgramLifecycle.active:
        return t.workouts.activeProgram.weekOf(
          current: lifecycle.currentWeek,
          total: lifecycle.totalWeeks,
        );
    }
  }

  Color _programLifecycleColor(bool isDark, ProgramLifecycle state) {
    switch (state) {
      case ProgramLifecycle.notStarted:
      case ProgramLifecycle.active:
        return isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
      case ProgramLifecycle.completed:
        return isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D);
      case ProgramLifecycle.expired:
        return isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
    }
  }
}
