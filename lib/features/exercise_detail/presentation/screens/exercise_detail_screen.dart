import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../widgets/exercise_demo_card.dart';
import '../widgets/exercise_focus_area_card.dart';
import '../widgets/exercise_how_to_perform_card.dart';
import '../widgets/exercise_common_mistakes_card.dart';
import '../widgets/exercise_tips_card.dart';

/// ExerciseDetailScreen:
/// Halaman detail gerakan sesuai desain mockup referensi 1:1:
/// - AppBar menampilkan nama latihan langsung (bukan teks 'Exercise Detail')
/// - Tanpa header teks tambahan di atas video (langsung mulai dari demo player)
/// - Box 1: Demo Gerakan (Pose Awal >>> Pose Akhir & tombol Watch Demo)
/// - Box 2: Focus Area (Otot target list di kiri & Anatomi Front/Back di kanan)
/// - Box 3: How to Perform (Step 1, 2, 3 berurutan dinamis dari data steps)
/// - Box 4: Common Mistakes (List kesalahan umum tanpa gambar dengan icon silang merah)
/// - Box 5: Tips for Beginners (Kartu tips hijau lembut dengan icon lampu bohlam)
class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  bool _isBookmarked = false;

  String get _exerciseTitle {
    final e = widget.exercise;
    if (e.name.en.isNotEmpty) return e.name.en;
    if (e.name.id.isNotEmpty) return e.name.id;
    return 'Exercise';
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.exercise;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.darkCharcoal,
            size: 24,
          ),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        // 1. Header sekarang ganti informasinya pakai nama exercisenya
        title: Text(
          _exerciseTitle,
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: const Color(0xFF141718),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_outline_rounded,
              color: const Color(0xFF141718),
              size: 24,
            ),
            onPressed: () {
              setState(() => _isBookmarked = !_isBookmarked);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isBookmarked
                        ? 'Disimpan ke bookmark'
                        : 'Dihapus dari bookmark',
                  ),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Color(0xFF141718),
              size: 24,
            ),
            onPressed: () {
              // Menu opsional (share, report, info)
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. Tanpa header teks di atas video -> Langsung Box 1: Demo Gerakan
            ExerciseDemoCard(exercise: e),
            const SizedBox(height: 16),

            // Box 2: Focus Area (Chips Otot di Kiri & Anatomi Tubuh di Kanan)
            ExerciseFocusAreaCard(exercise: e),
            const SizedBox(height: 16),

            // Box 3: How to Perform (Step 1, 2, 3...)
            ExerciseHowToPerformCard(exercise: e),
            const SizedBox(height: 16),

            // Box 4: Common Mistakes (List tanpa gambar dengan icon silang merah)
            ExerciseCommonMistakesCard(exercise: e),
            const SizedBox(height: 16),

            // Box 5: Tips for Beginners (Kartu hijau lembut dengan icon lampu bohlam)
            ExerciseTipsCard(exercise: e),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
