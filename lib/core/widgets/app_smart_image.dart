import 'package:material_ui/material_ui.dart';
import '../theme/app_colors.dart';
import '../utils/media_url_resolver.dart';

/// AppSmartImage: Widget Global Reusable untuk rendering gambar fleksibel (DRY Principle).
///
/// Otomatis mendeteksi sumber gambar:
/// 1. Jika diawali `http://` atau `https://` 👉 Menggunakan [Image.network] dengan loading shimmer & error fallback.
/// 2. Jika file lokal di folder aset 👉 Menggunakan [Image.asset] dengan error fallback.
/// 3. Jika path kosong atau null 👉 Langsung menampilkan ikon/widget fallback tanpa exception.
class AppSmartImage extends StatelessWidget {
  final String? imagePathOrUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;
  final Color fallbackIconColor;
  final double fallbackIconSize;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppSmartImage({
    super.key,
    required this.imagePathOrUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.borderRadius,
    this.fallbackIcon = Icons.fitness_center_rounded,
    this.fallbackIconColor = AppColors.neutral500,
    this.fallbackIconSize = 28,
    this.placeholder,
    this.errorWidget,
  });

  /// Helper factory untuk gambar bulat (avatar/icon bubble)
  factory AppSmartImage.circle({
    Key? key,
    required String? imagePathOrUrl,
    required double radius,
    BoxFit fit = BoxFit.cover,
    IconData fallbackIcon = Icons.fitness_center_rounded,
    Color fallbackIconColor = AppColors.neutral500,
  }) {
    return AppSmartImage(
      key: key,
      imagePathOrUrl: imagePathOrUrl,
      width: radius * 2,
      height: radius * 2,
      fit: fit,
      borderRadius: BorderRadius.circular(radius),
      fallbackIcon: fallbackIcon,
      fallbackIconColor: fallbackIconColor,
      fallbackIconSize: radius,
    );
  }

  @override
  Widget build(BuildContext context) {
    final raw = imagePathOrUrl?.trim() ?? '';
    final path = MediaUrlResolver.resolve(imagePathOrUrl)?.trim() ?? '';
    final isNetwork = path.startsWith('http://') || path.startsWith('https://');

    if (raw.contains('knee') || raw.contains('thumbnail') || raw.contains('.webp')) {
      debugPrint('[AppSmartImage] 🖼️ Loading image:');
      debugPrint('   raw : "$raw"');
      debugPrint('   path: "$path" (isNetwork: $isNetwork)');
    }

    Widget content;
    if (path.isEmpty) {
      content = _buildFallback();
    } else if (isNetwork) {
      content = Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? _buildDefaultPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('[AppSmartImage] ❌ GAGAL memuat Image.network: "$path"');
          debugPrint('   Error: $error');
          return errorWidget ?? _buildFallback();
        },
      );
    } else {
      content = Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('[AppSmartImage] ❌ Gagal memuat Image.asset: "$path" (Error: $error)');
          return errorWidget ?? _buildFallback();
        },
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    }

    return content;
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: AppColors.neutral100,
      child: Center(
        child: Icon(
          fallbackIcon,
          size: fallbackIconSize,
          color: fallbackIconColor,
        ),
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.neutral100,
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

