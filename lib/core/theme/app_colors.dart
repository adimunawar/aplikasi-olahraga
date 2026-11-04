import 'package:flutter/material.dart';

/// Palet warna "Home Bulking Coach v2" sesuai PRD Bagian 12.1.
/// Memadukan tema Light yang bersih, modern, dan energik dengan aksen Lime-Green.
class AppColors {
  AppColors._();

  // --- PRD v2 Core Tokens (Section 12.1) ---
  static const Color primary = Color(0xFFB8E66B); // Lime Green Primary
  static const Color textPrimary = Color(0xFF202820); // Dark Charcoal
  static const Color background = Color(0xFFF5F7F2); // Soft Neutral Canvas
  static const Color border = Color(0xFFE3E9DF); // Soft Neutral Border
  static const Color successSurface = Color(0xFFE9F5DA);
  static const Color warningSurface = Color(0xFFFCE8E5);

  // --- Surfaces & Containers (Light Theme) ---
  static const Color surface = Colors.white;
  static const Color surfaceCard = Colors.white;
  static const Color surfaceDim = Color(0xFFEAEFE6);
  static const Color surfaceBright = Colors.white;
  static const Color canvas = background;
  static const Color canvasRoot = background;

  static const Color surfaceContainerLowest = Colors.white;
  static const Color surfaceContainerLow = Color(0xFFF0F4EC);
  static const Color surfaceContainer = Colors.white;
  static const Color surfaceContainerHigh = Color(0xFFE7ECE1);
  static const Color surfaceContainerHighest = Color(0xFFDEE4D8);

  static const Color surfaceInteractive = Color(0xFFEDF2E8);
  static const Color surfaceElevated = Colors.white;

  // --- Borders & Outlines ---
  static const Color outline = border;
  static const Color outlineVariant = Color(0xFFD4DBD0);
  static const Color borderSubdued = border;
  static const Color borderHighlight = Color(0xFFCBD4C6);
  static const Color divider = border;

  // --- Text & Content ---
  static const Color onSurface = textPrimary;
  static const Color onSurfaceVariant = Color(0xFF495546);
  static const Color onBackground = textPrimary;
  static const Color textSecondary = Color(0xFF495546);
  static const Color textMuted = Color(0xFF738270);
  static const Color textDim = Color(0xFF8B9B88);

  // --- Brand & Kinetic Accents (Backwards Compatibility) ---
  static const Color electricLime = primary;
  static const Color primaryFixed = primary;
  static const Color onPrimaryFixed = Color(0xFF161E00);
  static const Color onPrimary = Color(0xFF161E00);
  static const Color onPrimaryContainer = Color(0xFF161E00);

  // --- Secondary & Functional Colors ---
  static const Color iceCyan = Color(0xFF0284C7);
  static const Color secondary = Color(0xFF0EA5E9);
  static const Color onSecondary = Colors.white;

  static const Color amberWarning = Color(0xFFD97706);
  static const Color tertiaryFixedDim = Color(0xFFF59E0B);
  static const Color onTertiary = Colors.white;

  static const Color vibrantCoral = Color(0xFFDC2626);
  static const Color error = Color(0xFFDC2626);
  static const Color onError = Colors.white;

  // --- Semantic Workout Classifications ---
  static const Color workoutPush = Color(0xFF65A30D); // P (Dorong) - Energetic Green
  static const Color workoutLegs = Color(0xFF0D9488); // K (Kaki) - Teal
  static const Color workoutCore = Color(0xFFD97706); // C (Core) - Amber
  static const Color workoutFull = Color(0xFF7C3AED); // F (Full Body) - Violet
  static const Color workoutRest = Color(0xFF64748B); // R (Istirahat) - Slate

  // --- Soft Elevation Shadows (Light Theme Friendly) ---
  static const List<BoxShadow> limeGlow = [
    BoxShadow(
      color: Color(0x33B8E66B),
      blurRadius: 14,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> amberGlow = [
    BoxShadow(
      color: Color(0x22F59E0B),
      blurRadius: 12,
      spreadRadius: 0,
      offset: Offset(0, 3),
    ),
  ];

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 10,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  // --- Convenience Semantic Aliases ---
  static const Color surfaceRaised = surfaceElevated;
  static const Color warmAmber = amberWarning;
  static const Color coral = vibrantCoral;
  static const Color pushWorkout = workoutPush;
  static const Color legsWorkout = workoutLegs;
  static const Color coreWorkout = workoutCore;
  static const Color fullBodyWorkout = workoutFull;
  static const Color restDay = workoutRest;

  static Color forWorkoutCode(String code) {
    switch (code.toUpperCase().trim()) {
      case 'P':
        return workoutPush;
      case 'K':
        return workoutLegs;
      case 'C':
        return workoutCore;
      case 'F':
        return workoutFull;
      case 'R':
      default:
        return workoutRest;
    }
  }
}
