import 'package:flutter/material.dart';

/// Palet warna "Obsidian Kinetic" sesuai acuan Google Stitch dan PRD.
/// Didesain dengan rasio kontras tinggi di atas kanvas obsidian gelap.
class AppColors {
  AppColors._();

  // --- Background & Canvas ---
  static const Color canvasRoot = Color(0xFF0D0E11);
  static const Color background = Color(0xFF121316);
  static const Color surface = Color(0xFF121316);
  static const Color surfaceDim = Color(0xFF121316);
  static const Color surfaceBright = Color(0xFF38393C);

  // --- Surface Containers (Tonal Stacking) ---
  static const Color surfaceContainerLowest = Color(0xFF0D0E11);
  static const Color surfaceContainerLow = Color(0xFF1B1B1F);
  static const Color surfaceContainer = Color(0xFF1F1F23);
  static const Color surfaceContainerHigh = Color(0xFF292A2D);
  static const Color surfaceContainerHighest = Color(0xFF343538);

  static const Color surfaceCard = Color(0xFF1E212B);
  static const Color surfaceInteractive = Color(0xFF262A36);
  static const Color surfaceElevated = Color(0xFF2D3241);

  // --- Borders & Outlines ---
  static const Color outline = Color(0xFF8E9379);
  static const Color outlineVariant = Color(0xFF444933);
  static const Color borderSubdued = Color(0xFF373D4E);
  static const Color borderHighlight = Color(0xFF4B5563);

  // --- Text & Content ---
  static const Color onSurface = Color(0xFFE3E2E6);
  static const Color onSurfaceVariant = Color(0xFFC4C9AC);
  static const Color onBackground = Color(0xFFE3E2E6);
  static const Color textMuted = Color(0xFF94A3B8);

  // --- Brand & Kinetic Accents ---
  static const Color electricLime = Color(0xFFCCFF00); // Primary Accent CTA
  static const Color primaryFixed = Color(0xFFC3F400);
  static const Color onPrimaryFixed = Color(0xFF161E00);
  static const Color onPrimary = Color(0xFF283500);

  static const Color iceCyan = Color(0xFF38BDF8); // Secondary Metric / Protein
  static const Color secondary = Color(0xFF7BD0FF);
  static const Color onSecondary = Color(0xFF00354A);

  static const Color amberWarning = Color(0xFFF59E0B); // Rest Interval / Alert
  static const Color tertiaryFixedDim = Color(0xFFFFB95F);
  static const Color onTertiary = Color(0xFF472A00);

  static const Color vibrantCoral = Color(0xFFEF4444); // Danger / Missed Day
  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);

  // --- Semantic Workout Classifications (PRD Bagian 5) ---
  static const Color workoutPush = Color(0xFFCCFF00); // P (Dorong) - Electric Lime
  static const Color workoutLegs = Color(0xFF10B981); // K (Kaki) - Emerald Cyan
  static const Color workoutCore = Color(0xFFF59E0B); // C (Core) - Warm Amber
  static const Color workoutFull = Color(0xFFC084FC); // F (Full Body) - Neon Violet
  static const Color workoutRest = Color(0xFF64748B); // R (Istirahat) - Steel Slate

  // --- Phosphor Glow Shadows ---
  static const List<BoxShadow> limeGlow = [
    BoxShadow(
      color: Color(0x40CCFF00),
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 0),
    ),
    BoxShadow(
      color: Color(0x80CCFF00),
      blurRadius: 2,
      spreadRadius: 0,
      offset: Offset(0, 0),
    ),
  ];

  static const List<BoxShadow> amberGlow = [
    BoxShadow(
      color: Color(0x33F59E0B),
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 0),
    ),
  ];

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // --- Convenience Semantic Aliases for Clean Feature UI Presentation ---
  static const Color canvas = canvasRoot;
  static const Color surfaceRaised = surfaceElevated;
  static const Color divider = borderSubdued;
  static const Color textPrimary = onSurface;
  static const Color textSecondary = onSurfaceVariant;
  static const Color textDim = textMuted;
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

