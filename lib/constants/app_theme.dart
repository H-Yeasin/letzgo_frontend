import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'defi_theme_extension.dart';

/// "True Void" — dark Bitcoin DeFi theme.
final ThemeData defiDarkTheme = _buildDefiTheme(
  brightness: Brightness.dark,
  defi: DefiThemeExtension.dark,
  inputFill: const Color(0x66000000), // black 40%
  hintColor: const Color(0x4DFFFFFF), // white 30%
  snackBarBackground: AppColors.surfaceElevated,
  snackBarForeground: AppColors.fg,
);

/// "Daylight Gold" — light Bitcoin DeFi theme.
final ThemeData defiLightTheme = _buildDefiTheme(
  brightness: Brightness.light,
  defi: DefiThemeExtension.light,
  inputFill: Colors.white,
  hintColor: AppColorsLight.fgDim,
  // Inverse snackbar keeps it legible above light content.
  snackBarBackground: const Color(0xFF1E293B),
  snackBarForeground: Colors.white,
);

ThemeData _buildDefiTheme({
  required Brightness brightness,
  required DefiThemeExtension defi,
  required Color inputFill,
  required Color hintColor,
  required Color snackBarBackground,
  required Color snackBarForeground,
}) {
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: brightness == Brightness.dark
          ? AppColors.tertiary
          : AppColorsLight.tertiary,
      surface: defi.surface,
      error: defi.danger,
      onPrimary: Colors.white,
      onSurface: defi.fg,
      onSurfaceVariant: defi.fgMuted,
      outline: defi.border,
    ),
    scaffoldBackgroundColor: defi.bg,
    fontFamily: GoogleFonts.inter().fontFamily,
    extensions: <ThemeExtension<dynamic>>[defi],

    // AppBar
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: defi.fg,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: defi.fg,
      ),
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
        ),
        side: BorderSide(color: defi.border),
        foregroundColor: defi.fg,
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),

    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputFill,
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: defi.border, width: 2),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: defi.border, width: 2),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: defi.danger, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(
        color: hintColor,
        fontSize: 14,
      ),
      labelStyle: TextStyle(
        color: defi.fgMuted,
        fontSize: 14,
      ),
    ),

    // Cards
    cardTheme: CardThemeData(
      elevation: 0,
      color: defi.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: defi.borderLight),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),

    // Chips
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: defi.surface,
      selectedColor: AppColors.primary,
      side: BorderSide(color: defi.borderLight),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: TextStyle(
        color: defi.fgMuted,
        fontSize: 13,
      ),
    ),

    // Bottom Navigation (legacy widget)
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 0,
      backgroundColor: defi.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: defi.fgMuted,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
      ),
    ),

    // NavigationBar (Material 3, used by MainShell)
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: defi.surface,
      indicatorColor: AppColors.primary.withValues(alpha: 0.15),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.primary
              : defi.fgMuted,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w400,
          color: states.contains(WidgetState.selected)
              ? AppColors.primary
              : defi.fgMuted,
        ),
      ),
    ),

    // Divider
    dividerTheme: DividerThemeData(
      color: defi.border,
      thickness: 1,
      space: 1,
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: defi.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: snackBarBackground,
      contentTextStyle: TextStyle(color: snackBarForeground),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
