import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Sistem tipografi "Obsidian Kinetic":
/// - Barlow Condensed: Untuk angka metrik, timer (tabular figures), headline, dan badge caps.
/// - Plus Jakarta Sans: Untuk instruksi form gerakan, deskripsi anatomi, dan label antarmuka.
class AppTypography {
  AppTypography._();

  // --- Display & Timers (Barlow Condensed) ---
  static TextStyle get displayTimer => GoogleFonts.barlowCondensed(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        height: 1.0,
        letterSpacing: 0.03,
        color: AppColors.onSurface,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle get timerDisplay => displayTimer;

  static TextStyle get displayLarge => GoogleFonts.barlowCondensed(
        fontSize: 44,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: 0.02,
        color: AppColors.onSurface,
      );

  static TextStyle get displayMedium => GoogleFonts.barlowCondensed(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: 0.02,
        color: AppColors.onSurface,
      );

  static TextStyle get dataMetric => GoogleFonts.barlowCondensed(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.0,
        letterSpacing: 0.02,
        color: AppColors.secondary,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle get tabularMetricSmall => GoogleFonts.barlowCondensed(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.0,
        color: AppColors.secondary,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  // --- Headlines (Barlow Condensed) ---
  static TextStyle get headlineLarge => GoogleFonts.barlowCondensed(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.12,
        letterSpacing: 0.01,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineMedium => GoogleFonts.barlowCondensed(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.16,
        letterSpacing: 0.01,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineSmall => GoogleFonts.barlowCondensed(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.005,
        color: AppColors.onSurface,
      );

  static TextStyle get labelCaps => GoogleFonts.barlowCondensed(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: 0.08,
        color: AppColors.onSurfaceVariant,
      );

  // --- Body & Labels (Plus Jakarta Sans) ---
  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.42,
        color: AppColors.onSurface,
      );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        color: AppColors.onSurfaceVariant,
      );

  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.28,
        letterSpacing: 0.02,
        color: AppColors.onSurface,
      );

  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: 0.03,
        color: AppColors.onSurfaceVariant,
      );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: 0.02,
        color: AppColors.onSurfaceVariant,
      );
}
