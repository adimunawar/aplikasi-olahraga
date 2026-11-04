import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../widgets/exercise_hero_banner.dart';
import '../widgets/video_preview_card.dart';
import '../widgets/target_muscles_card.dart';
import '../widgets/exercise_metrics_strip.dart';
import '../widgets/exercise_steps_section.dart';
import '../widgets/exercise_tips_card.dart';

/// ExerciseDetailScreen:
/// Halaman detail gerakan yang modular, bersih, dan sesuai dengan desain referensi.
class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  bool _isFavorite = false;
  bool _isPlayingVideo = false;
  bool _isShowingEndPose = false;
  Timer? _poseTimer;

  @override
  void initState() {
    super.initState();
    // Animasi preview posisi awal & akhir
    _poseTimer = Timer.periodic(const Duration(milliseconds: 1600), (_) {
      if (mounted) {
        setState(() => _isShowingEndPose = !_isShowingEndPose);
      }
    });
  }

  @override
  void dispose() {
    _poseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.exercise;
    final primaryMuscleStr = e.primaryMuscles.map((m) => m.id).join(', ');
    final secondaryMuscleStr = e.stabilizerMuscles.isNotEmpty
        ? e.stabilizerMuscles.map((m) => m.id).join(', ')
        : 'Triceps, Bahu';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Exercise Detail',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
              color: _isFavorite ? AppColors.vibrantCoral : AppColors.textPrimary,
              size: 24,
            ),
            onPressed: () {
              setState(() => _isFavorite = !_isFavorite);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isFavorite ? 'Disimpan ke favorit' : 'Dihapus dari favorit'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HERO BANNER WITH COACH CHARACTER
            ExerciseHeroBanner(
              exercise: e,
              primaryMuscles: primaryMuscleStr,
            ),

            const SizedBox(height: 18),

            // 2. VIDEO PREVIEW & TARGET MUSCLES CARDS
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: VideoPreviewCard(
                    isPlaying: _isPlayingVideo,
                    isShowingEndPose: _isShowingEndPose,
                    onTogglePlay: () {
                      setState(() => _isPlayingVideo = !_isPlayingVideo);
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 5,
                  child: TargetMusclesCard(
                    primaryMuscles: primaryMuscleStr,
                    secondaryMuscles: secondaryMuscleStr,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // 3. METRICS STRIP (Sets, Reps, Rest, Level)
            ExerciseMetricsStrip(exercise: e),

            const SizedBox(height: 24),

            // 4. CARA MELAKUKAN (Step-by-step & Visual Poses)
            ExerciseStepsSection(exercise: e),

            const SizedBox(height: 20),

            // 5. TIPS CARD
            ExerciseTipsCard(exercise: e),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
