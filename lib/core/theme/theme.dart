import 'package:flutter/material.dart';

class AppTheme {
  // Благородная геральдическая палитра Eldertree
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color primaryGoldLight = Color(0xFFE5C158);
  static const Color primaryGoldDark = Color(0xFFAA8012);

  static const Color emeraldForest = Color(0xFF1B3B2B);
  static const Color deepEmerald = Color(0xFF2D4A3E);
  static const Color sageAccent = Color(0xFF5E8B75);

  static const Color darkBackground = Color(0xFF0C0E12);
  static const Color darkSurface = Color(0xFF161A22);
  static const Color darkCard = Color(0xFF1C222D);

  static const Color lightBackground = Color(0xFFF9F7F2);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF4F0E6);

  static const Color textLight = Color(0xFF23272F);
  static const Color textDark = Color(0xFFE8ECEF);
  static const Color textMuted = Color(0xFF8F9CA8);

  static final ThemeData light = ThemeData(
    primaryColor: primaryGold,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: primaryGold,
      onPrimary: Colors.black,
      secondary: deepEmerald,
      onSecondary: Colors.white,
      surface: lightSurface,
      onSurface: textLight,
      error: Color(0xFFD32F2F),
      onError: Colors.white,
    ),
    useMaterial3: true,
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textLight,
        letterSpacing: 0.2,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textLight,
      ),
      bodyMedium: TextStyle(fontSize: 14, color: textLight),
      labelSmall: TextStyle(fontSize: 12, color: textMuted),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGold,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 3,
        shadowColor: primaryGold.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  static final ThemeData dark = ThemeData(
    primaryColor: primaryGold,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: primaryGold,
      onPrimary: Colors.black,
      secondary: sageAccent,
      onSecondary: Colors.black,
      surface: darkSurface,
      onSurface: textDark,
      error: Color(0xFFEF5350),
      onError: Colors.black,
    ),
    useMaterial3: true,
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textDark,
        letterSpacing: 0.2,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      bodyMedium: TextStyle(fontSize: 14, color: textDark),
      labelSmall: TextStyle(fontSize: 12, color: textMuted),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGold,
        foregroundColor: const Color(0xFF10141A),
        elevation: 4,
        shadowColor: primaryGold.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
