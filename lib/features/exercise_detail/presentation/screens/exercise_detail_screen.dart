import 'package:material_ui/material_ui.dart';

import 'package:go_router/go_router.dart';

import 'package:workout_app/core/widgets/app_snack_bar.dart';
import 'package:workout_app/features/exercises/domain/models/exercise.dart';

import '../widgets/exercise_detail_widgets.dart';

/// ExerciseDetailScreen:
/// Halaman detail gerakan sesuai desain mockup referensi 1:1:
/// - Mendukung penuh Dark Mode & Light Mode (resolusi warna dinamis via Theme.of(context))
/// - Header terpisah dalam sub-komponen modular (ExerciseDetailHeader)
/// - Box 1: Demo Gerakan (Pose Awal >>> Pose Akhir & tombol Watch Demo)
/// - Box 2: Focus Area (Otot target list di kiri & Anatomi Front/Back di kanan)
/// - Box 3: How to Perform (Step 1, 2, 3 berurutan dinamis dari data steps)
/// - Box 4: Common Mistakes (List kesalahan umum tanpa gambar dengan icon silang merah)
/// - Box 5: Tips for Beginners (Kartu tips adaptif dengan icon lampu bohlam)
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

  void _toggleBookmark() {
    setState(() => _isBookmarked = !_isBookmarked);
    if (_isBookmarked) {
      AppSnackBar.showSuccess(context, 'Disimpan ke bookmark');
    } else {
      AppSnackBar.showInfo(context, 'Dihapus dari bookmark');
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.exercise;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: ExerciseDetailHeader(
        title: _exerciseTitle,
        isBookmarked: _isBookmarked,
        onBack: () => context.pop(),
        onBookmarkToggle: _toggleBookmark,
        onMore: () {
          // Menu aksi tambahan opsional (share, info)
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Box 1: Demo Gerakan
            ExerciseDemoCard(exercise: e),
            const SizedBox(height: 16),

            // Box 2: Focus Area (Chips Otot & Anatomi Tubuh)
            ExerciseFocusAreaCard(exercise: e),
            const SizedBox(height: 16),

            // Box 3: How to Perform (Step 1, 2, 3...)
            ExerciseHowToPerformCard(exercise: e),
            const SizedBox(height: 16),

            // Box 4: Common Mistakes (List dengan icon silang merah)
            ExerciseCommonMistakesCard(exercise: e),
            const SizedBox(height: 16),

            // Box 5: Tips for Beginners (Kartu tips adaptif dengan icon lampu bohlam)
            ExerciseTipsCard(exercise: e),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
