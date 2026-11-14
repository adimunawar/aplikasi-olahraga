import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Widget Avatar Pengguna dengan Dukungan Gambar & Fallback Huruf Inisial (Light Premium)
class UserAvatar extends StatelessWidget {
  final String displayName;
  final String? avatarUrl;
  final double radius;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;

  const UserAvatar({
    super.key,
    required this.displayName,
    this.avatarUrl,
    this.radius = 23,
    this.onTap,
    this.borderColor,
    this.backgroundColor,
  });

  /// Mengambil inisial nama pengguna (Maksimal 2 huruf, contoh: "Adi Munawar" -> "AM", "Adi" -> "A")
  String _getInitials(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return '';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final first = parts[0].isNotEmpty ? parts[0][0] : '';
      final second = parts[1].isNotEmpty ? parts[1][0] : '';
      return (first + second).toUpperCase();
    }
    return clean[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final initials = _getInitials(displayName);

    Widget avatarContent;

    if (avatarUrl != null && avatarUrl!.trim().isNotEmpty) {
      final url = avatarUrl!.trim();
      final isNetwork = url.startsWith('http://') || url.startsWith('https://');

      avatarContent = isNetwork
          ? Image.network(
              url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildFallback(initials),
            )
          : Image.asset(
              url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildFallback(initials),
            );
    } else {
      avatarContent = _buildFallback(initials);
    }

    final avatarWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor ?? const Color(0xFFD4EBA8),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(child: avatarContent),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }

  Widget _buildFallback(String initials) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor ?? const Color(0xFFEBF7CB),
            const Color(0xFFD4F836),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: initials.isNotEmpty
          ? Text(
              initials,
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: radius * 0.72,
                color: AppColors.darkCharcoal,
                letterSpacing: -0.2,
              ),
            )
          : Icon(
              Icons.person_rounded,
              size: radius * 1.1,
              color: AppColors.darkCharcoal,
            ),
    );
  }
}
