import 'package:flutter/material.dart';

class AppTheme {
  // Neon Cyan and Deep Dark based on design reference
  static const Color neonCyan = Color(0xFF00F5FF);
  static const Color deepDark = Color(0xFF0A0A0B);
  
  // Supplementary colors from the cyber-grid aesthetic
  static const Color background = Color(0xFF131317);
  static const Color surface = Color(0xFF131317);
  static const Color surfaceHighlight = Color(0xFF1F1F23);
  static const Color error = Color(0xFFFFB4AB);
  static const Color secondary = Color(0xFFDFB7FF);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: neonCyan,
      scaffoldBackgroundColor: deepDark,
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: secondary,
        surface: surface,
        error: error,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold, color: Colors.white),
        displayMedium: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold, color: Colors.white),
        titleLarge: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: TextStyle(fontFamily: 'Inter', color: Colors.white70),
        bodyMedium: TextStyle(fontFamily: 'Inter', color: Colors.white70),
        labelLarge: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold, letterSpacing: 1.5, color: neonCyan),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: deepDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: neonCyan),
        titleTextStyle: TextStyle(
          fontFamily: 'Space Grotesk',
          color: neonCyan,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          letterSpacing: 2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonCyan,
          foregroundColor: deepDark,
          textStyle: const TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
