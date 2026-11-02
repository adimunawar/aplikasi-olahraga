import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Tema aplikasi "Obsidian Kinetic" dengan dukungan Dark Mode (tema utama)
/// dan Light Mode dengan rasio kontras tinggi sesuai PRD Bagian 8 & 9.
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.electricLime,
        onPrimary: AppColors.onPrimaryFixed,
        primaryContainer: AppColors.primaryFixed,
        onPrimaryContainer: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.surfaceInteractive,
        onSecondaryContainer: AppColors.iceCyan,
        tertiary: AppColors.tertiaryFixedDim,
        onTertiary: AppColors.onTertiary,
        error: AppColors.vibrantCoral,
        onError: AppColors.onError,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.borderSubdued,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: AppTypography.displayLarge(),
        headlineLarge: AppTypography.headlineLarge(),
        headlineMedium: AppTypography.headlineMedium(),
        headlineSmall: AppTypography.headlineSmall(),
        bodyLarge: AppTypography.bodyLarge(),
        bodyMedium: AppTypography.bodyMedium(),
        bodySmall: AppTypography.bodySmall(),
        labelLarge: AppTypography.labelLarge(),
        labelMedium: AppTypography.labelMedium(),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderSubdued, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.electricLime,
          foregroundColor: AppColors.canvasRoot,
          textStyle: AppTypography.headlineSmall(color: AppColors.canvasRoot),
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurface,
          side: const BorderSide(color: AppColors.borderSubdued, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainer,
        selectedItemColor: AppColors.electricLime,
        unselectedItemColor: AppColors.workoutRest,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubdued,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: AppColors.onSurface),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF5E8B00), // Adjusted dark lime for contrast
        onPrimary: Colors.white,
        secondary: Color(0xFF007799),
        onSecondary: Colors.white,
        error: Color(0xFFBA1A1A),
        onError: Colors.white,
        surface: Colors.white,
        onSurface: Color(0xFF191C1D),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }
}
