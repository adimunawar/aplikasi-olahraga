import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// MuscleAnatomyViewer: Reusable Flutter Widget untuk Visualisasi Anatomi Otot Dinamis.
///
/// Menggunakan sistem layering PNG transparan presisi 1:1:
/// - Base Gray Body (#EEF0F3) sebagai fondasi
/// - Layer aktif di-highlight dengan warna Lime Green (#A8E900)
/// - Mendukung Front View & Back View dengan toggle interaktif
class MuscleAnatomyViewer extends StatefulWidget {
  final List<String> targetMuscles;
  final double height;
  final bool showViewToggle;
  final bool initialBackView;
  final bool isCard;
  final bool showChips;

  const MuscleAnatomyViewer({
    super.key,
    required this.targetMuscles,
    this.height = 240,
    this.showViewToggle = true,
    this.initialBackView = false,
    this.isCard = true,
    this.showChips = true,
  });

  @override
  State<MuscleAnatomyViewer> createState() => _MuscleAnatomyViewerState();
}

class _MuscleAnatomyViewerState extends State<MuscleAnatomyViewer> {
  late bool _isBackView;

  @override
  void initState() {
    super.initState();
    // Auto-detect apakah target muscles lebih dominan punggung/posterior
    _isBackView =
        widget.initialBackView || _shouldDefaultToBack(widget.targetMuscles);
  }

  bool _shouldDefaultToBack(List<String> muscles) {
    final lower = muscles.map((m) => m.toLowerCase()).toList();
    int backCount = 0;
    int frontCount = 0;

    for (final m in lower) {
      if (m.contains('back') ||
          m.contains('punggung') ||
          m.contains('lat') ||
          m.contains('trap') ||
          m.contains('tricep') ||
          m.contains('glute') ||
          m.contains('hamstring')) {
        backCount++;
      }
      if (m.contains('chest') ||
          m.contains('dada') ||
          m.contains('abs') ||
          m.contains('core') ||
          m.contains('bicep') ||
          m.contains('quad')) {
        frontCount++;
      }
    }
    return backCount > frontCount;
  }

  @override
  Widget build(BuildContext context) {
    final normalized = widget.targetMuscles
        .map((m) => m.toLowerCase().trim())
        .toSet();

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header / Toggle Depan-Belakang
        if (widget.showViewToggle) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.limeAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Muscle Anatomy',
                    style: AppTypography.headlineSmall.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF141718),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleButton('Front', !_isBackView, () {
                      setState(() => _isBackView = false);
                    }),
                    _buildToggleButton('Back', _isBackView, () {
                      setState(() => _isBackView = true);
                    }),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Visualisasi Anatomi Layering
        SizedBox(
          height: widget.height,
          child: AspectRatio(
            aspectRatio: 950 / 2540,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _isBackView
                  ? _buildBackView(normalized)
                  : _buildFrontView(normalized),
            ),
          ),
        ),

        // Chips Target Otot Aktif
        if (widget.showChips) ...[
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: widget.targetMuscles.map((muscle) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.limeCardSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.limeAccent.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.greenDark,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      muscle,
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );

    if (!widget.isCard) return content;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: content,
    );
  }
}

Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: isSelected
            ? const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? const Color(0xFF141718) : const Color(0xFF64748B),
        ),
      ),
    ),
  );
}

Widget _buildFrontView(Set<String> muscles) {
  return Stack(
    key: const ValueKey('front_view'),
    fit: StackFit.expand,
    children: [
      // 1. Master Base Front
      Image.asset(
        'assets/muscle/front/base_front.png',
        fit: BoxFit.contain,
        gaplessPlayback: true,
      ),

      // 2. Chest (Dada)
      if (_hasMatch(muscles, ['chest', 'dada', 'pectoral', 'pecs']))
        Image.asset(
          'assets/muscle/front/chest.png',
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),

      // 3. Shoulders (Bahu)
      if (_hasMatch(muscles, [
        'shoulder',
        'shoulders',
        'bahu',
        'deltoid',
        'delts',
      ]))
        Image.asset(
          'assets/muscle/front/shoulders.png',
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),

      // 4. Biceps
      if (_hasMatch(muscles, ['bicep', 'biceps', 'arms', 'lengan']))
        Image.asset(
          'assets/muscle/front/biceps.png',
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),

      // 5. Forearms
      if (_hasMatch(muscles, ['forearm', 'forearms', 'grip']))
        Image.asset(
          'assets/muscle/front/forearms.png',
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),

      // 6. Abs (Perut / Core)
      if (_hasMatch(muscles, ['abs', 'core', 'perut', 'abdominals']))
        Image.asset(
          'assets/muscle/front/abs.png',
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),

      // 7. Obliques
      if (_hasMatch(muscles, ['oblique', 'obliques']))
        Image.asset(
          'assets/muscle/front/obliques.png',
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),

      // 8. Quads (Paha Depan)
      if (_hasMatch(muscles, [
        'quad',
        'quads',
        'quadriceps',
        'legs',
        'kaki',
        'paha',
      ]))
        Image.asset(
          'assets/muscle/front/quads.png',
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),

      // 9. Calves (Betis)
      if (_hasMatch(muscles, ['calf', 'calves', 'betis']))
        Image.asset(
          'assets/muscle/front/calves.png',
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),
    ],
  );
}

Widget _buildBackView(Set<String> muscles) {
  return Stack(
    key: const ValueKey('back_view'),
    fit: StackFit.expand,
    children: [
      // 1. Master Base Back
      Image.asset(
        'assets/muscle/back/base_back.png',
        fit: BoxFit.contain,
        gaplessPlayback: true,
      ),

      // 2. Traps
      if (_hasMatch(muscles, ['trap', 'traps', 'trapezius', 'neck']))
        Image.asset(
          'assets/muscle/back/traps.png',
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),

      // 3. Back / Lats (Sayap Punggung)
      if (_hasMatch(muscles, [
        'back',
        'punggung',
        'lat',
        'lats',
        'latissimus',
        'upper back',
      ]))
        Image.asset(
          'assets/muscle/back/back.png',
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),

      // 4. Rear Shoulders
      if (_hasMatch(muscles, [
        'shoulder',
        'shoulders',
        'bahu',
        'rear delts',
        'deltoid',
      ]))
        Image.asset(
          'assets/muscle/back/shoulders.png',
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),

      // 5. Triceps
      if (_hasMatch(muscles, ['tricep', 'triceps', 'arms', 'lengan']))
        Image.asset(
          'assets/muscle/back/triceps.png',
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),

      // 6. Posterior Forearms
      if (_hasMatch(muscles, ['forearm', 'forearms']))
        Image.asset(
          'assets/muscle/back/forearms.png',
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),

      // 7. Lower Back
      if (_hasMatch(muscles, [
        'lower back',
        'lower_back',
        'erectors',
        'pinggang',
      ]))
        Image.asset(
          'assets/muscle/back/lower_back.png',
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),

      // 8. Glutes
      if (_hasMatch(muscles, ['glute', 'glutes', 'butt', 'pantat', 'hips']))
        Image.asset(
          'assets/muscle/back/glutes.png',
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),

      // 9. Hamstrings
      if (_hasMatch(muscles, ['hamstring', 'hamstrings', 'legs', 'kaki']))
        Image.asset(
          'assets/muscle/back/hamstrings.png',
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),

      // 10. Calves
      if (_hasMatch(muscles, ['calf', 'calves', 'betis']))
        Image.asset(
          'assets/muscle/back/calves.png',
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),
    ],
  );
}

bool _hasMatch(Set<String> activeMuscles, List<String> matchKeywords) {
  for (final muscle in activeMuscles) {
    for (final keyword in matchKeywords) {
      if (muscle.contains(keyword)) return true;
    }
  }
  return false;
}
