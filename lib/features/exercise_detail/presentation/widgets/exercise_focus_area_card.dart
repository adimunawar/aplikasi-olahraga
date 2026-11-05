import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../exercises/domain/models/exercise.dart';

/// Box 2: Focus Area (Mockup 1:1)
/// - Kiri: Chip otot target dengan centang hijau (Primary & Secondary)
/// - Kanan: Anatomi atletis Front & Back side-by-side dengan highlight Lime Green (#A8E900)
class ExerciseFocusAreaCard extends StatelessWidget {
  final Exercise exercise;

  const ExerciseFocusAreaCard({super.key, required this.exercise});

  Set<String> get _activeMuscleKeywords {
    final set = <String>{};
    for (final m in exercise.primaryMuscles) {
      set.add(m.en.toLowerCase());
      set.add(m.id.toLowerCase());
    }
    for (final m in exercise.stabilizerMuscles) {
      set.add(m.en.toLowerCase());
      set.add(m.id.toLowerCase());
    }
    return set;
  }

  @override
  Widget build(BuildContext context) {
    final active = _activeMuscleKeywords;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF1F3F5), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title with Green Accent Indicator
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.limeAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Focus Area',
                style: AppTypography.headlineSmall.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF141718),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 1. Muscle Chips (Di Atas - Wrap Rapi Horizontal)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Otot Utama (Primary) - Hijau Muda
              ...exercise.primaryMuscles.map((muscle) {
                return _buildMusclePill(name: muscle.en, isPrimary: true);
              }),

              // Otot Sekunder (Stabilizer) - Abu-abu Muda
              ...exercise.stabilizerMuscles.map((muscle) {
                return _buildMusclePill(name: muscle.en, isPrimary: false);
              }),
            ],
          ),

          const SizedBox(height: 16),

          // 2. Anatomi Tubuh Atletis (Di Bawah - Full Width, Besar, Tajam & Jelas)
          Container(
            height: 220,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFCF8),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF1F5EB), width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Front View Anatomy
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 950 / 2540,
                        child: _buildFrontAnatomy(active),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Front View',
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),

                // Divider Pemisah Halus
                Container(
                  width: 1,
                  height: 140,
                  color: const Color(0xFFE9ECEF),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),

                // Back View Anatomy
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 950 / 2540,
                        child: _buildBackAnatomy(active),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Back View',
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusclePill({required String name, required bool isPrimary}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.limeCardSurface : const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPrimary
              ? AppColors.limeAccent.withValues(alpha: 0.6)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: isPrimary ? AppColors.limeAccent : const Color(0xFFCBD5E1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 11,
              color: Color(0xFF141718),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              name,
              style: AppTypography.labelSmall.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF141718),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrontAnatomy(Set<String> active) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/muscle/front/base_front.png',
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),
        if (_match(active, ['chest', 'dada', 'pectoral']))
          Image.asset(
            'assets/muscle/front/chest.png',
            fit: BoxFit.contain,
            gaplessPlayback: true,
          ),
        if (_match(active, ['shoulder', 'shoulders', 'bahu', 'deltoid']))
          Image.asset(
            'assets/muscle/front/shoulders.png',
            fit: BoxFit.contain,
            gaplessPlayback: true,
          ),
        if (_match(active, ['bicep', 'biceps', 'arms', 'lengan']))
          Image.asset(
            'assets/muscle/front/biceps.png',
            fit: BoxFit.contain,
            gaplessPlayback: true,
          ),
        if (_match(active, ['forearm', 'forearms']))
          Image.asset(
            'assets/muscle/front/forearms.png',
            fit: BoxFit.contain,
            gaplessPlayback: true,
          ),
        if (_match(active, ['abs', 'core', 'perut']))
          Image.asset(
            'assets/muscle/front/abs.png',
            fit: BoxFit.contain,
            gaplessPlayback: true,
          ),
        if (_match(active, ['oblique', 'obliques']))
          Image.asset(
            'assets/muscle/front/obliques.png',
            fit: BoxFit.contain,
            gaplessPlayback: true,
          ),
        if (_match(active, ['quad', 'quads', 'legs', 'kaki', 'paha']))
          Image.asset(
            'assets/muscle/front/quads.png',
            fit: BoxFit.contain,
            gaplessPlayback: true,
          ),
        if (_match(active, ['calf', 'calves', 'betis']))
          Image.asset(
            'assets/muscle/front/calves.png',
            fit: BoxFit.contain,
            gaplessPlayback: true,
          ),
      ],
    );
  }

  Widget _buildBackAnatomy(Set<String> active) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/muscle/back/base_back.png',
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),
        if (_match(active, ['trap', 'traps', 'trapezius', 'neck']))
          Image.asset(
            'assets/muscle/back/traps.png',
            fit: BoxFit.contain,
            gaplessPlayback: true,
          ),
        if (_match(active, ['back', 'punggung', 'lat', 'lats']))
          Image.asset(
            'assets/muscle/back/back.png',
            fit: BoxFit.contain,
            gaplessPlayback: true,
          ),
        if (_match(active, ['shoulder', 'shoulders', 'bahu', 'rear delts']))
          Image.asset(
            'assets/muscle/back/shoulders.png',
            fit: BoxFit.contain,
            gaplessPlayback: true,
          ),
        if (_match(active, ['tricep', 'triceps', 'arms', 'lengan']))
          Image.asset(
            'assets/muscle/back/triceps.png',
            fit: BoxFit.contain,
            gaplessPlayback: true,
          ),
        if (_match(active, ['forearm', 'forearms']))
          Image.asset(
            'assets/muscle/back/forearms.png',
            fit: BoxFit.contain,
            gaplessPlayback: true,
          ),
        if (_match(active, ['lower back', 'lower_back', 'erectors']))
          Image.asset(
            'assets/muscle/back/lower_back.png',
            fit: BoxFit.contain,
            gaplessPlayback: true,
          ),
        if (_match(active, ['glute', 'glutes', 'butt', 'bokong', 'pantat']))
          Image.asset(
            'assets/muscle/back/glutes.png',
            fit: BoxFit.contain,
            gaplessPlayback: true,
          ),
        if (_match(active, ['hamstring', 'hamstrings', 'legs', 'kaki']))
          Image.asset(
            'assets/muscle/back/hamstrings.png',
            fit: BoxFit.contain,
            gaplessPlayback: true,
          ),
        if (_match(active, ['calf', 'calves', 'betis']))
          Image.asset(
            'assets/muscle/back/calves.png',
            fit: BoxFit.contain,
            gaplessPlayback: true,
          ),
      ],
    );
  }

  bool _match(Set<String> active, List<String> targets) {
    for (final a in active) {
      for (final t in targets) {
        if (a.contains(t)) return true;
      }
    }
    return false;
  }
}
