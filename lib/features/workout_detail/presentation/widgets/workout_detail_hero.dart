import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/app_smart_image.dart';

/// Helper to copy workout details to the clipboard and show a floating snackbar.
class WorkoutDetailShareHelper {
  static Future<void> copy({
    required BuildContext context,
    required String title,
    required String durationText,
    required String exerciseCountLabel,
    required String levelText,
    required String description,
    required String snackbarMessage,
  }) async {
    final details = [
      title,
      '$durationText • $exerciseCountLabel • $levelText',
      description,
    ].join('\n');

    await Clipboard.setData(ClipboardData(text: details));
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(snackbarMessage),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }
}

/// Hero image and action bar for Workout Detail screen.
class WorkoutDetailHero extends StatelessWidget {
  final String imagePath;
  final VoidCallback onBackPressed;
  final VoidCallback onSharePressed;
  final VoidCallback onBookmarkPressed;
  final bool isBookmarked;
  final String backTooltip;
  final String shareTooltip;
  final String bookmarkTooltip;

  const WorkoutDetailHero({
    super.key,
    required this.imagePath,
    required this.onBackPressed,
    required this.onSharePressed,
    required this.onBookmarkPressed,
    required this.isBookmarked,
    this.backTooltip = 'Back',
    this.shareTooltip = 'Copy workout details',
    this.bookmarkTooltip = 'Bookmark workout',
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return SizedBox(
      width: double.infinity,
      height: 218 + topInset,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imagePath.isNotEmpty)
            AppSmartImage(
              imagePathOrUrl: imagePath,
              fit: BoxFit.cover,
              errorWidget: _buildHeroFallback(context),
            )
          else
            _buildHeroFallback(context),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x66000000),
                  Color(0x08000000),
                  Color(0x33000000),
                ],
                stops: [0, 0.45, 1],
              ),
            ),
          ),
          Positioned(
            top: topInset + 8,
            left: 16,
            child: _buildHeroAction(
              icon: Icons.arrow_back_rounded,
              tooltip: backTooltip,
              onPressed: onBackPressed,
            ),
          ),
          Positioned(
            top: topInset + 8,
            right: 66,
            child: _buildHeroAction(
              icon: Icons.ios_share_rounded,
              tooltip: shareTooltip,
              onPressed: onSharePressed,
            ),
          ),
          Positioned(
            top: topInset + 8,
            right: 16,
            child: _buildHeroAction(
              icon: isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              tooltip: bookmarkTooltip,
              onPressed: onBookmarkPressed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroFallback(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.fitness_center_rounded,
        size: 54,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _buildHeroAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: const Color(0x66000000),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 21),
        constraints: const BoxConstraints.tightFor(width: 42, height: 42),
      ),
    );
  }
}
