import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../exercises/domain/models/exercise.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  bool _isShowingEndPose = false;
  bool _isAutoLooping = true;
  Timer? _loopTimer;

  @override
  void initState() {
    super.initState();
    _startLoopTimer();
  }

  void _startLoopTimer() {
    _loopTimer?.cancel();
    if (_isAutoLooping) {
      _loopTimer = Timer.periodic(const Duration(milliseconds: 1400), (timer) {
        if (mounted) {
          setState(() {
            _isShowingEndPose = !_isShowingEndPose;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _loopTimer?.cancel();
    super.dispose();
  }

  void _toggleAutoLoop() {
    setState(() {
      _isAutoLooping = !_isAutoLooping;
      if (_isAutoLooping) {
        _startLoopTimer();
      } else {
        _loopTimer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.exercise;
    final diffColor = e.difficulty == ExerciseDifficulty.beginner
        ? AppColors.electricLime
        : e.difficulty == ExerciseDifficulty.advanced
            ? AppColors.coral
            : AppColors.warmAmber;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          e.name.id,
          style: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: diffColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: diffColor.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Text(
                e.difficulty.localizedName('id'),
                style: AppTypography.labelSmall.copyWith(
                  color: diffColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Two-Pose Interactive Visual Card
            _buildVisualCard(e),

            const SizedBox(height: 24),

            // 2. Muscle Targeting (Primary & Stabilizers)
            _buildMusclesSection(e),

            const SizedBox(height: 24),

            // 3. Breathing Rhythm
            _buildBreathingSection(e),

            const SizedBox(height: 24),

            // 4. Execution Steps
            _buildStepsSection(e),

            const SizedBox(height: 24),

            // 5. Common Form Mistakes
            _buildMistakesSection(e),

            const SizedBox(height: 24),

            // 6. Variations (Regressions / Progressions)
            _buildVariationsSection(e),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualCard(Exercise e) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Visual Simulation Box
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.electricLime.withValues(alpha: 0.2),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Skeleton / Pose Representation
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _isShowingEndPose
                            ? AppColors.electricLime.withValues(alpha: 0.2)
                            : AppColors.iceCyan.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isShowingEndPose ? AppColors.electricLime : AppColors.iceCyan,
                          width: 2.5,
                        ),
                      ),
                      child: Icon(
                        _isShowingEndPose ? Icons.fitness_center : Icons.accessibility_new_rounded,
                        color: _isShowingEndPose ? AppColors.electricLime : AppColors.iceCyan,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isShowingEndPose ? 'POSE AKHIR (KONTRAKSI)' : 'POSE AWAL (PERSIAPAN)',
                      style: AppTypography.labelCaps.copyWith(
                        color: _isShowingEndPose ? AppColors.electricLime : AppColors.iceCyan,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),

                // Auto-loop toggle pill
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: _toggleAutoLoop,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.canvas.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isAutoLooping ? Icons.pause_circle_outline : Icons.play_circle_outline,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isAutoLooping ? 'Animasi Aktif' : 'Animasi Jeda',
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Manual Pose Switcher Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isShowingEndPose = false;
                      _isAutoLooping = false;
                      _loopTimer?.cancel();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: !_isShowingEndPose
                        ? AppColors.iceCyan.withValues(alpha: 0.15)
                        : Colors.transparent,
                    side: BorderSide(
                      color: !_isShowingEndPose ? AppColors.iceCyan : AppColors.divider,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    '1. Pose Awal',
                    style: AppTypography.bodySmall.copyWith(
                      color: !_isShowingEndPose ? AppColors.iceCyan : AppColors.textDim,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isShowingEndPose = true;
                      _isAutoLooping = false;
                      _loopTimer?.cancel();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _isShowingEndPose
                        ? AppColors.electricLime.withValues(alpha: 0.15)
                        : Colors.transparent,
                    side: BorderSide(
                      color: _isShowingEndPose ? AppColors.electricLime : AppColors.divider,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    '2. Pose Akhir',
                    style: AppTypography.bodySmall.copyWith(
                      color: _isShowingEndPose ? AppColors.electricLime : AppColors.textDim,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMusclesSection(Exercise e) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OTOT YANG BEKERJA',
          style: AppTypography.labelCaps.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Otot Utama (Target Hipertrofi):',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textDim),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: e.primaryMuscles.map((m) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.electricLime.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.electricLime.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          m.id,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.electricLime,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (e.stabilizerMuscles.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Otot Penstabil & Sinergis:',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textDim),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: e.stabilizerMuscles.map((m) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.iceCyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.iceCyan.withValues(alpha: 0.3)),
                ),
                child: Text(
                  m.id,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.iceCyan,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildBreathingSection(Exercise e) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.iceCyan.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.air_rounded, color: AppColors.iceCyan, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'POLA PERNAPASAN',
                  style: AppTypography.labelCaps.copyWith(
                    color: AppColors.iceCyan,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  e.breathing.id,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsSection(Exercise e) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LANGKAH EKSEKUSI FORM',
          style: AppTypography.labelCaps.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: e.steps.id.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.electricLime,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      e.steps.id[index],
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMistakesSection(Exercise e) {
    if (e.commonMistakes.id.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KESALAHAN UMUM & BAHAYA',
          style: AppTypography.labelCaps.copyWith(
            color: AppColors.coral,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.coral.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.coral.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: e.commonMistakes.id.map((mistake) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.coral, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        mistake,
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildVariationsSection(Exercise e) {
    final easier = e.variations.easier;
    final harder = e.variations.harder;

    if (easier.isEmpty && harder.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VARIASI BEBAN PROGRESIF',
          style: AppTypography.labelCaps.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (easier.isNotEmpty) ...[
                Text(
                  'Regresi (Lebih Ringan jika belum kuat):',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textDim),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: easier.map((v) {
                    return Chip(
                      backgroundColor: AppColors.surfaceRaised,
                      side: BorderSide(color: AppColors.divider),
                      label: Text(
                        v.replaceAll('_', ' ').toUpperCase(),
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
              if (harder.isNotEmpty) ...[
                Text(
                  'Progresi (Lebih Menantang untuk stimulasi baru):',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textDim),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: harder.map((v) {
                    return Chip(
                      backgroundColor: AppColors.electricLime.withValues(alpha: 0.1),
                      side: BorderSide(color: AppColors.electricLime.withValues(alpha: 0.3)),
                      label: Text(
                        v.replaceAll('_', ' ').toUpperCase(),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.electricLime,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

