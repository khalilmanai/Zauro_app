import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'theme_tokens.dart';

enum GradientDirection {
  topLeft(Alignment.topLeft, Alignment.bottomRight),
  topCenter(Alignment.topCenter, Alignment.bottomCenter),
  topRight(Alignment.topRight, Alignment.bottomLeft),
  left(Alignment.centerLeft, Alignment.centerRight),
  right(Alignment.centerRight, Alignment.centerLeft),
  bottomLeft(Alignment.bottomLeft, Alignment.topRight),
  bottomCenter(Alignment.bottomCenter, Alignment.topCenter),
  bottomRight(Alignment.bottomRight, Alignment.topLeft);

  const GradientDirection(this.begin, this.end);
  final Alignment begin;
  final Alignment end;
}

class AppTheme {
  // Map AppTheme constants to AppColors for centralized control
  static const Color lightBackground = AppColors.lightBackground;
  static const Color lightForeground = AppColors.lightForeground;
  static const Color lightPrimary = AppColors.lightPrimary;
  static const Color lightPrimaryForeground = AppColors.lightPrimaryForeground;
  static const Color lightSecondary = AppColors.lightSecondary;
  static const Color lightSecondaryForeground =
      AppColors.lightSecondaryForeground;
  static const Color lightMuted = AppColors.lightMuted;
  static const Color lightMutedForeground = AppColors.lightMutedForeground;
  static const Color lightAccent = AppColors.lightAccent;
  static const Color lightAccentForeground = AppColors.lightAccentForeground;
  static const Color lightDestructive = AppColors.lightDestructive;
  static const Color lightDestructiveForeground =
      AppColors.lightDestructiveForeground;
  static const Color lightBorder = AppColors.lightBorder;
  static const Color lightInput = AppColors.lightInput;
  static const Color lightRing = AppColors.lightRing;

  static const Color darkBackground = AppColors.darkBackground;
  static const Color darkForeground = AppColors.darkForeground;
  static const Color darkPrimary = AppColors.darkPrimary;
  static const Color darkPrimaryForeground = AppColors.darkPrimaryForeground;
  static const Color darkSecondary = AppColors.darkSecondary;
  static const Color darkSecondaryForeground =
      AppColors.darkSecondaryForeground;
  static const Color darkMuted = AppColors.darkMuted;
  static const Color darkMutedForeground = AppColors.darkMutedForeground;
  static const Color darkAccent = AppColors.darkAccent;
  static const Color darkAccentForeground = AppColors.darkAccentForeground;
  static const Color darkDestructive = AppColors.darkDestructive;
  static const Color darkDestructiveForeground =
      AppColors.darkDestructiveForeground;
  static const Color darkBorder = AppColors.darkBorder;
  static const Color darkInput = AppColors.darkInput;
  static const Color darkRing = AppColors.darkRing;

  static const Color white = AppColors.white;
  static const Color black = AppColors.black;
  static const Color transparent = AppColors.transparent;

  static const Color success = AppColors.success;
  static const Color warning = AppColors.warning;
  static const Color info = AppColors.info;
  static const Color error = AppColors.error;

  static const Color grey50 = AppColors.grey50;
  static const Color grey100 = AppColors.grey100;
  static const Color grey200 = AppColors.grey200;
  static const Color grey300 = AppColors.grey300;
  static const Color grey400 = AppColors.grey400;
  static const Color grey500 = AppColors.grey500;
  static const Color grey600 = AppColors.grey600;
  static const Color grey700 = AppColors.grey700;
  static const Color grey800 = AppColors.grey800;
  static const Color grey900 = AppColors.grey900;

  static const Color slate50 = AppColors.slate50;
  static const Color slate100 = AppColors.slate100;
  static const Color slate200 = AppColors.slate200;
  static const Color slate300 = AppColors.slate300;
  static const Color slate400 = AppColors.slate400;
  static const Color slate500 = AppColors.slate500;
  static const Color slate600 = AppColors.slate600;
  static const Color slate700 = AppColors.slate700;
  static const Color slate800 = AppColors.slate800;
  static const Color slate900 = AppColors.slate900;

  static const Color indigo500 = AppColors.indigo500;
  static const Color indigo600 = AppColors.indigo600;
  static const Color purple500 = AppColors.purple500;
  static const Color purple600 = AppColors.purple600;
  static const Color violet500 = AppColors.violet500;
  static const Color violet600 = AppColors.violet600;
  static const Color pink500 = AppColors.pink500;
  static const Color pink600 = AppColors.pink600;

  static const Color red500 = AppColors.red500;
  static const Color red600 = AppColors.red600;
  static const Color red700 = AppColors.red700;
  static const Color red800 = AppColors.red800;
  static const Color red900 = AppColors.red900;
  static const Color green500 = AppColors.green500;
  static const Color green600 = AppColors.green600;
  static const Color blue500 = AppColors.blue500;
  static const Color blue600 = AppColors.blue600;
  static const Color orange500 = AppColors.orange500;
  static const Color orange600 = AppColors.orange600;
  static const Color teal500 = AppColors.teal500;
  static const Color teal600 = AppColors.teal600;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.lightPrimary, AppColors.darkPrimary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [AppColors.lightAccent, Color(0xFFD4B896)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);

  static const Color neonPrimary = AppColors.lightPrimary;
  static const Color neonPrimaryGlow = Color(0x40215732);
  static const Color neonAccent = AppColors.lightAccent;
  static const Color neonAccentGlow = Color(0x40E9D3B0);
  static const Color neonSecondary = AppColors.lightSecondary;
  static const Color neonSecondaryGlow = Color(0x40E7F0E7);
  static const Color neonDestructive = AppColors.lightDestructive;
  static const Color neonDestructiveGlow = Color(0x40B23A1F);

  static const Color neonPrimaryDark = AppColors.darkPrimary;
  static const Color neonPrimaryGlowDark = Color(0x40397D4C);
  static const Color neonAccentDark = AppColors.darkAccent;
  static const Color neonAccentGlowDark = Color(0x405A422B);
  static const Color neonSecondaryDark = AppColors.darkSecondary;
  static const Color neonSecondaryGlowDark = Color(0x4025372A);
  static const Color neonDestructiveDark = AppColors.darkDestructive;
  static const Color neonDestructiveGlowDark = Color(0x408F2F18);

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        surface: lightBackground,
        onSurface: lightForeground,
        primary: lightPrimary,
        onPrimary: lightPrimaryForeground,
        secondary: lightSecondary,
        onSecondary: lightSecondaryForeground,
        tertiary: lightAccent,
        onTertiary: lightAccentForeground,
        error: lightDestructive,
        onError: lightDestructiveForeground,
        outline: lightBorder,
        surfaceContainerHighest: lightMuted,
        onSurfaceVariant: lightMutedForeground,
      ),
      scaffoldBackgroundColor: lightBackground,
      extensions: <ThemeExtension<dynamic>>[
        AppTokens.defaultLight,
      ],

      // Text Theme
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: lightForeground,
          height: 1.2,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: lightForeground,
          height: 1.2,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: lightForeground,
          height: 1.3,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: lightForeground,
          height: 1.3,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightForeground,
          height: 1.3,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: lightForeground,
          height: 1.3,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: lightForeground,
          height: 1.4,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: lightForeground,
          height: 1.4,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: lightForeground,
          height: 1.4,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: lightForeground,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: lightForeground,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: lightMutedForeground,
          height: 1.5,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: lightForeground,
          height: 1.4,
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: lightForeground,
          height: 1.4,
        ),
        labelSmall: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: lightMutedForeground,
          height: 1.4,
        ),
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightForeground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightForeground,
        ),
        iconTheme: const IconThemeData(
          color: lightForeground,
          size: 24,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: white,
        elevation: 2,
        shadowColor: shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: lightPrimaryForeground,
          elevation: 2,
          shadowColor: shadowLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightPrimary,
          side: const BorderSide(color: lightPrimary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightDestructive),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightDestructive, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.poppins(
          color: lightMutedForeground,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.poppins(
          color: lightMutedForeground,
          fontSize: 14,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: lightPrimary,
        unselectedItemColor: lightMutedForeground,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: lightPrimary,
        foregroundColor: lightPrimaryForeground,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: lightMuted,
        selectedColor: lightPrimary,
        disabledColor: lightMuted,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: lightBorder,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: lightForeground,
        size: 24,
      ),

      // Primary Icon Theme
      primaryIconTheme: const IconThemeData(
        color: lightPrimaryForeground,
        size: 24,
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        surface: darkBackground,
        onSurface: darkForeground,
        primary: darkPrimary,
        onPrimary: darkPrimaryForeground,
        secondary: darkSecondary,
        onSecondary: darkSecondaryForeground,
        tertiary: darkAccent,
        onTertiary: darkAccentForeground,
        error: darkDestructive,
        onError: darkDestructiveForeground,
        outline: darkBorder,
        surfaceContainerHighest: darkMuted,
        onSurfaceVariant: darkMutedForeground,
      ),
      scaffoldBackgroundColor: darkBackground,
      extensions: <ThemeExtension<dynamic>>[
        AppTokens.defaultDark,
      ],

      // Text Theme
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkForeground,
          height: 1.2,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkForeground,
          height: 1.2,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: darkForeground,
          height: 1.3,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: darkForeground,
          height: 1.3,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkForeground,
          height: 1.3,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkForeground,
          height: 1.3,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkForeground,
          height: 1.4,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkForeground,
          height: 1.4,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkForeground,
          height: 1.4,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: darkForeground,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: darkForeground,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: darkMutedForeground,
          height: 1.5,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkForeground,
          height: 1.4,
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkForeground,
          height: 1.4,
        ),
        labelSmall: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: darkMutedForeground,
          height: 1.4,
        ),
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkForeground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkForeground,
        ),
        iconTheme: const IconThemeData(
          color: darkForeground,
          size: 24,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: darkMuted,
        elevation: 2,
        shadowColor: shadowDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: darkPrimaryForeground,
          elevation: 2,
          shadowColor: shadowDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimary,
          side: const BorderSide(color: darkPrimary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkDestructive),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkDestructive, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.poppins(
          color: darkMutedForeground,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.poppins(
          color: darkMutedForeground,
          fontSize: 14,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkMuted,
        selectedItemColor: darkPrimary,
        unselectedItemColor: darkMutedForeground,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: darkPrimary,
        foregroundColor: darkPrimaryForeground,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: darkSecondary,
        selectedColor: darkPrimary,
        disabledColor: darkSecondary,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: darkForeground,
        size: 24,
      ),

      // Primary Icon Theme
      primaryIconTheme: const IconThemeData(
        color: darkPrimaryForeground,
        size: 24,
      ),
    );
  }

  // Build theme with optional seed color (Material 3 dynamic feel)
  static ThemeData themed({required bool isDark, Color? seedColor}) {
    final base = isDark ? darkTheme : lightTheme;
    if (seedColor == null) return base;
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );
    return base.copyWith(colorScheme: scheme);
  }

  // Helper methods for getting colors based on theme
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  static Color getForegroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color getSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  static Color getMutedColor(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerHighest;
  }

  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).colorScheme.outline;
  }

  // Shadow helpers
  static List<BoxShadow> getLightShadow() {
    return [
      BoxShadow(
        color: shadowLight,
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> getMediumShadow() {
    return [
      BoxShadow(
        color: shadowMedium,
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static List<BoxShadow> getDarkShadow() {
    return [
      BoxShadow(
        color: shadowDark,
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ];
  }

  // Color getters for backward compatibility
  static Color get primaryColor => lightPrimary;
  static Color get successColor => success;
  static Color get errorColor => error;
  static Color get accentColor => lightAccent;
  static Color get lightShadow => shadowLight;
  static Color get mediumShadow => shadowMedium;
  static Color get darkShadow => shadowDark;

  // Context-based color getters
  static Color getPrimaryColorFromContext(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color getSuccessColor(BuildContext context) {
    return success;
  }

  static Color getErrorColor(BuildContext context) {
    return error;
  }

  static Color getAccentColorFromContext(BuildContext context) {
    return Theme.of(context).colorScheme.tertiary;
  }

  static List<BoxShadow> getContextShadow(BuildContext context) {
    return getLightShadow();
  }

  // Neon Glow Effects
  static List<BoxShadow> getNeonGlow({
    required Color color,
    double blurRadius = 20,
    double spreadRadius = 0,
    double opacity = 0.3,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
      BoxShadow(
        color: color.withValues(alpha: opacity * 0.5),
        blurRadius: blurRadius * 0.5,
        spreadRadius: spreadRadius,
      ),
    ];
  }

  static List<BoxShadow> getPrimaryNeonGlow({bool isDark = false}) {
    return getNeonGlow(
      color: isDark ? neonPrimaryDark : neonPrimary,
      blurRadius: 25,
      spreadRadius: 2,
      opacity: 0.4,
    );
  }

  static List<BoxShadow> getAccentNeonGlow({bool isDark = false}) {
    return getNeonGlow(
      color: isDark ? neonAccentDark : neonAccent,
      blurRadius: 20,
      spreadRadius: 1,
      opacity: 0.3,
    );
  }

  static List<BoxShadow> getSecondaryNeonGlow({bool isDark = false}) {
    return getNeonGlow(
      color: isDark ? neonSecondaryDark : neonSecondary,
      blurRadius: 15,
      spreadRadius: 1,
      opacity: 0.25,
    );
  }

  static List<BoxShadow> getDestructiveNeonGlow({bool isDark = false}) {
    return getNeonGlow(
      color: isDark ? neonDestructiveDark : neonDestructive,
      blurRadius: 20,
      spreadRadius: 1,
      opacity: 0.3,
    );
  }

  // Enhanced Neon Gradients
  static LinearGradient getNeonPrimaryGradient(
      {bool isDark = false,
      GradientDirection direction = GradientDirection.topLeft}) {
    Color startColor = isDark ? neonPrimaryDark : neonPrimary;
    Color endColor = isDark
        ? neonPrimaryDark.withValues(alpha: 0.7)
        : neonPrimary.withValues(alpha: 0.7);

    return LinearGradient(
      colors: [startColor, endColor, startColor],
      stops: const [0.0, 0.5, 1.0],
      begin: direction.begin,
      end: direction.end,
    );
  }

  static LinearGradient getNeonAccentGradient(
      {bool isDark = false,
      GradientDirection direction = GradientDirection.topLeft}) {
    Color startColor = isDark ? neonAccentDark : neonAccent;
    Color endColor = isDark
        ? neonAccentDark.withValues(alpha: 0.8)
        : neonAccent.withValues(alpha: 0.8);

    return LinearGradient(
      colors: [startColor, endColor, startColor],
      stops: const [0.0, 0.5, 1.0],
      begin: direction.begin,
      end: direction.end,
    );
  }

  // Premium Gradients
  static LinearGradient getPremiumGradient({
    required List<Color> colors,
    GradientDirection direction = GradientDirection.topLeft,
    List<double>? stops,
  }) {
    return LinearGradient(
      colors: colors,
      stops: stops,
      begin: direction.begin,
      end: direction.end,
    );
  }

  static LinearGradient getRainbowGradient({
    double opacity = 1.0,
    GradientDirection direction = GradientDirection.topLeft,
  }) {
    return LinearGradient(
      colors: [
        red500.withValues(alpha: opacity),
        orange500.withValues(alpha: opacity),
        AppColors.yellow500.withValues(alpha: opacity),
        green500.withValues(alpha: opacity),
        blue500.withValues(alpha: opacity),
        indigo500.withValues(alpha: opacity),
        purple500.withValues(alpha: opacity),
      ],
      begin: direction.begin,
      end: direction.end,
    );
  }

  // Glass Morphism Effects
  static BoxDecoration getGlassMorphismDecoration({
    Color? color,
    double borderRadius = 16,
    double blurRadius = 10,
    double borderWidth = 1,
    bool isDark = false,
  }) {
    return BoxDecoration(
      color: (color ??
          (isDark
              ? AppColors.white.withValues(alpha: 0.1)
              : AppColors.white.withValues(alpha: 0.2))),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: AppColors.white.withValues(alpha: 0.2),
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.1),
          blurRadius: blurRadius,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Neon Border Decoration
  static BoxDecoration getNeonBorderDecoration({
    required Color color,
    double borderWidth = 2,
    double borderRadius = 12,
    bool isDark = false,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: color,
        width: borderWidth,
      ),
      boxShadow: getNeonGlow(
        color: color,
        blurRadius: 15,
        spreadRadius: 1,
        opacity: 0.3,
      ),
    );
  }

  // Neon Button Decoration
  static BoxDecoration getNeonButtonDecoration({
    required Color color,
    double borderRadius = 12,
    bool isDark = false,
    bool isPressed = false,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        colors: [
          color,
          color.withValues(alpha: 0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: isPressed
          ? []
          : getNeonGlow(
              color: color,
              blurRadius: 20,
              spreadRadius: 2,
              opacity: 0.4,
            ),
    );
  }

  // Animation Curves
  static const Curve bounceInOut = Curves.elasticInOut;
  static const Curve smoothTransition = Curves.easeInOutCubic;
  static const Curve quickTransition = Curves.easeOutQuart;
  static const Curve slowTransition = Curves.easeInOutQuart;

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Premium Card Styles
  static BoxDecoration getPremiumCardDecoration({
    required BuildContext context,
    bool isDark = false,
    bool hasElevation = true,
    double borderRadius = 20,
  }) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: hasElevation ? getMediumShadow() : [],
      border: Border.all(
        color: isDark ? darkBorder : lightBorder,
        width: 0.5,
      ),
    );
  }

  // Shimmer Effects
  static BoxDecoration getShimmerDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.grey300.withValues(alpha: 0.1),
          AppColors.grey500.withValues(alpha: 0.3),
          AppColors.grey300.withValues(alpha: 0.1),
        ],
        stops: const [0.4, 0.6, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(12),
    );
  }

  // Success/Error State Decorations
  static BoxDecoration getSuccessDecoration() {
    return BoxDecoration(
      color: success.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: success.withValues(alpha: 0.3)),
    );
  }

  static BoxDecoration getErrorDecoration() {
    return BoxDecoration(
      color: error.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: error.withValues(alpha: 0.3)),
    );
  }

  static BoxDecoration getWarningDecoration() {
    return BoxDecoration(
      color: warning.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: warning.withValues(alpha: 0.3)),
    );
  }

  // Interactive Hover Effects
  static Map<WidgetState, IconThemeData> getIconThemeData(
    BuildContext context, {
    bool isHovered = false,
    Color? color,
  }) {
    final baseColor = color ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return {
      if (isHovered)
        WidgetState.hovered: IconThemeData(
          color: baseColor.withValues(alpha: 0.8),
          size: 24,
        ),
      if (!isHovered)
        WidgetState.focused: IconThemeData(
          color: baseColor,
          size: 24,
        ),
    }..putIfAbsent(
        WidgetState.selected,
        () => IconThemeData(
              color: baseColor,
              size: 24,
            ));
  }

  // Enhanced Typography Helpers
  static TextStyle getHeadlineTextStyle(
    BuildContext context, {
    bool isDark = false,
    Color? color,
  }) {
    return Theme.of(context).textTheme.headlineLarge!.copyWith(
          color: color ?? getForegroundColor(context),
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        );
  }

  static TextStyle getCaptionTextStyle(
    BuildContext context, {
    bool isDark = false,
    Color? color,
  }) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
          color: color ?? getMutedColor(context),
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        );
  }

  // Custom Backdrop Filter
  static Widget createBackdropFilter({
    Color? color,
    double blur = 10,
    Widget? child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          color: color ?? AppColors.white.withValues(alpha: 0.1),
          child: child,
        ),
      ),
    );
  }

  // Comprehensive Color Utilities
  static Color getCardBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? slate800 : white;
  }

  static Color getSurfaceColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? slate800 : white;
  }

  static Color getTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? white : slate900;
  }

  static Color getMutedTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? slate400 : slate500;
  }

  static Color getBorderColorFromContext(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? slate700 : slate200;
  }

  static Color getDividerColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? slate700 : slate200;
  }

  static Color getHoverColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? slate700 : slate100;
  }

  static Color getPressedColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? slate600 : slate200;
  }

  // Brand Gradient Collections
  static List<Color> getBrandGradientColors() {
    return [indigo500, purple500, violet500, pink500];
  }

  static List<Color> getBrandGradientColorsLight() {
    return [
      indigo500.withValues(alpha: 0.8),
      purple500.withValues(alpha: 0.8),
      violet500.withValues(alpha: 0.8),
      pink500.withValues(alpha: 0.8)
    ];
  }

  static LinearGradient getBrandGradient(
      {GradientDirection direction = GradientDirection.topLeft}) {
    return LinearGradient(
      colors: getBrandGradientColors(),
      begin: direction.begin,
      end: direction.end,
    );
  }

  static LinearGradient getBrandGradientLight(
      {GradientDirection direction = GradientDirection.topLeft}) {
    return LinearGradient(
      colors: getBrandGradientColorsLight(),
      begin: direction.begin,
      end: direction.end,
    );
  }

  // Status Color Helpers
  static Color getStatusColor(String status, BuildContext context) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'active':
        return green500;
      case 'error':
      case 'failed':
      case 'rejected':
        return red500;
      case 'warning':
      case 'pending':
        return orange500;
      case 'info':
      case 'processing':
        return blue500;
      default:
        return getMutedTextColor(context);
    }
  }

  static Color getStatusBackgroundColor(String status, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'active':
        return green500.withValues(alpha: isDark ? 0.2 : 0.1);
      case 'error':
      case 'failed':
      case 'rejected':
        return red500.withValues(alpha: isDark ? 0.2 : 0.1);
      case 'warning':
      case 'pending':
        return orange500.withValues(alpha: isDark ? 0.2 : 0.1);
      case 'info':
      case 'processing':
        return blue500.withValues(alpha: isDark ? 0.2 : 0.1);
      default:
        return getHoverColor(context);
    }
  }

  // Opacity Helpers
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  static Color getOverlayColor(BuildContext context, {double opacity = 0.5}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return (isDark ? black : white).withValues(alpha: opacity);
  }

  // Shadow Helpers with Context
  static List<BoxShadow> getContextShadowFromTheme(BuildContext context,
      {double elevation = 1}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (elevation <= 1) {
      return [
        BoxShadow(
          color: (isDark ? black : black).withValues(alpha: isDark ? 0.3 : 0.1),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];
    } else if (elevation <= 2) {
      return [
        BoxShadow(
          color:
              (isDark ? black : black).withValues(alpha: isDark ? 0.3 : 0.15),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: (isDark ? black : black).withValues(alpha: isDark ? 0.3 : 0.2),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
    }
  }

  // Material Design Color System
  static Map<String, Color> getMaterialColors() {
    return {
      'red': red500,
      'green': green500,
      'blue': blue500,
      'orange': orange500,
      'purple': purple500,
      'pink': pink500,
      'indigo': indigo500,
      'violet': violet500,
      'teal': teal500,
    };
  }

  // Accessibility Helpers
  static Color getHighContrastColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? white : black;
  }

  static Color getLowContrastColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? slate400 : slate600;
  }

  // Animation Color Helpers
  static Color getAnimatedColor(BuildContext context,
      {required Color startColor,
      required Color endColor,
      required double progress}) {
    return Color.lerp(startColor, endColor, progress) ?? startColor;
  }

  // Theme-aware Color Picker
  static Color getThemeAwareColor(BuildContext context,
      {required Color lightColor, required Color darkColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkColor : lightColor;
  }
}

// Context extension for accessing current context
extension AppThemeContext on Widget {
  static late BuildContext currentContext;
}
