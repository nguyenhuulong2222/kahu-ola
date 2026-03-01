import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Kahu Ola — Material 3 Design System
/// Colour palette inspired by Hawaiian volcanic landscape:
///   Primary   : Deep Ocean Blue   #005B8E
///   Secondary : Lava Orange       #E8601C
///   Tertiary  : Pali Green        #2E7D32
///   Error     : Alert Red         #B00020
class AppTheme {
  AppTheme._();

  // ── Brand colours ──────────────────────────────────────────────────────────
  static const Color _primaryColor = Color(0xFF005B8E);
  static const Color _secondaryColor = Color(0xFFE8601C);
  static const Color _tertiaryColor = Color(0xFF2E7D32);
  static const Color _errorColor = Color(0xFFB00020);

  static const Color _primaryDark = Color(0xFF90CAF9);
  static const Color _secondaryDark = Color(0xFFFFB74D);
  static const Color _tertiaryDark = Color(0xFF81C784);

  // ── Severity colours (alert tiers) ────────────────────────────────────────
  static const Color alertExtreme = Color(0xFFB71C1C); // Extreme
  static const Color alertSevere = Color(0xFFE64A19); // Severe
  static const Color alertModerate = Color(0xFFF9A825); // Moderate
  static const Color alertMinor = Color(0xFF2E7D32); // Minor / Advisory

  // ── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      secondary: _secondaryColor,
      tertiary: _tertiaryColor,
      error: _errorColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(colorScheme),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 4,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryDark,
      secondary: _secondaryDark,
      tertiary: _tertiaryDark,
      error: const Color(0xFFCF6679),
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(colorScheme),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 4,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
      ),
    );
  }

  // ── Text Theme (Kupuna-friendly large type) ────────────────────────────────
  static TextTheme _buildTextTheme(ColorScheme scheme) {
    final base = GoogleFonts.notoSansTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontFamily: GoogleFonts.nunito().fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 57,
        color: scheme.onSurface,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontFamily: GoogleFonts.nunito().fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 28,
        color: scheme.onSurface,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 22,
        color: scheme.onSurface,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 18,
        color: scheme.onSurface,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 16,
        color: scheme.onSurfaceVariant,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
    );
  }
}
