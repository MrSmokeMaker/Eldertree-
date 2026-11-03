import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF4A90E2);
  static const Color secondary = Color(0xFF50E3C2);
  static const Color background = Color(0xFFF5F7FA);
  static const Color text = Color(0xFF212121);

  static final ThemeData light = ThemeData(
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      surface: background,
    ),
    useMaterial3: true,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: text, fontFamily: 'Inter'),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: text, fontFamily: 'Inter'),
      bodyMedium: TextStyle(fontSize: 14, color: text, fontFamily: 'Inter'),
      labelSmall: TextStyle(fontSize: 12, color: text, fontFamily: 'Inter'),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );

  static final ThemeData dark = ThemeData(
    primaryColor: primary,
    scaffoldBackgroundColor: const Color(0xFF0F1115),
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      surface: const Color(0xFF0F1115),
    ),
    useMaterial3: true,
  );
}
