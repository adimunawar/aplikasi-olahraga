import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Sistem tipografi "Obsidian Kinetic":
/// - Barlow Condensed: Untuk angka metrik, timer (tabular figures), headline, dan badge caps.
/// - Plus Jakarta Sans: Untuk instruksi form gerakan, deskripsi anatomi, dan label antarmuka.
class AppTypography {
  AppTypography._();

  // --- Display & Timers (Barlow Condensed) ---
  static TextStyle displayTimer({Color color = AppColors.onSurface}) {
    return GoogleFonts.barlowCondensed(
      fontSize: 56,
      fontWeight: FontWeight.w800,
      height: 1.0,
      letterSpacing: 0.03,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle displayLarge({Color color = AppColors.onSurface}) {
    return GoogleFonts.barlowCondensed(
      fontSize: 44,
      fontWeight: FontWeight.w800,
      height: 1.1,
      letterSpacing: 0.02,
      color: color,
    );
  }

  static TextStyle dataMetric({Color color = AppColors.secondary}) {
    return GoogleFonts.barlowCondensed(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.0,
      letterSpacing: 0.02,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  // --- Headlines (Barlow Condensed) ---
  static TextStyle headlineLarge({Color color = AppColors.onSurface}) {
    return GoogleFonts.barlowCondensed(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 1.12,
      letterSpacing: 0.01,
      color: color,
    );
  }

  static TextStyle headlineMedium({Color color = AppColors.onSurface}) {
    return GoogleFonts.barlowCondensed(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.16,
      letterSpacing: 0.01,
      color: color,
    );
  }

  static TextStyle headlineSmall({Color color = AppColors.onSurface}) {
    return GoogleFonts.barlowCondensed(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.005,
      color: color,
    );
  }

  static TextStyle labelCaps({Color color = AppColors.onSurfaceVariant}) {
    return GoogleFonts.barlowCondensed(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      height: 1.1,
      letterSpacing: 0.08,
      color: color,
    );
  }

  // --- Body & Labels (Plus Jakarta Sans) ---
  static TextStyle bodyLarge({Color color = AppColors.onSurface}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.5,
      color: color,
    );
  }

  static TextStyle bodyMedium({Color color = AppColors.onSurface}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.42,
      color: color,
    );
  }

  static TextStyle bodySmall({Color color = AppColors.onSurfaceVariant}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.33,
      color: color,
    );
  }

  static TextStyle labelLarge({Color color = AppColors.onSurface}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      height: 1.28,
      letterSpacing: 0.02,
      color: color,
    );
  }

  static TextStyle labelMedium({Color color = AppColors.onSurfaceVariant}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.33,
      letterSpacing: 0.03,
      color: color,
    );
  }
}

