import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/theme/app_typography.dart';

/// Header bar khusus ExerciseDetailScreen:
/// - Menggunakan NavigationToolbar native tanpa ketergantungan AppBar MaterialLocalizations
/// - Sepenuhnya mendukung Dark Mode & Light Mode via Theme.of(context)
/// - Menampilkan tombol kembali, judul gerakan dinamis di tengah, dan aksi bookmark/opsi
class ExerciseDetailHeader extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final bool isBookmarked;
  final VoidCallback onBack;
  final VoidCallback onBookmarkToggle;
  final VoidCallback? onMore;

  const ExerciseDetailHeader({
    super.key,
    required this.title,
    required this.isBookmarked,
    required this.onBack,
    required this.onBookmarkToggle,
    this.onMore,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurface;

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: kToolbarHeight,
        child: NavigationToolbar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: onSurfaceColor,
              size: 24,
            ),
            onPressed: onBack,
          ),
          middle: Text(
            title,
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: onSurfaceColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          centerMiddle: true,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  color: isBookmarked
                      ? theme.colorScheme.primary
                      : onSurfaceColor,
                  size: 24,
                ),
                onPressed: onBookmarkToggle,
              ),
              IconButton(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: onSurfaceColor,
                  size: 24,
                ),
                onPressed: onMore,
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}
