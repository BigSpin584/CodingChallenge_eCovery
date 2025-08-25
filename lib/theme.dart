import 'package:flutter/material.dart';

class AppTheme {
  static const Color bgPage     = Color(0xFFF5F7FA); 
  static const Color card       = Color(0xFFFFFFFF); 
  static const Color textDark   = Color(0xFF2E3440); 
  static const Color textMuted  = Color(0x992E3440); 
  static const Color divider    = Color(0x142E3440); 

  static const Color blueButton = Color(0xFF3E7BFA); 
  static const Color greenFill  = Color(0xFF34C759); 
  static const Color trackGrey  = Color(0xFFE8EEF4); 

  static const double cardRadius  = 32;
  static const double fieldRadius = 16;

  static ThemeData get theme {
    final base = ThemeData.light();
    return base.copyWith(
      useMaterial3: true,
      scaffoldBackgroundColor: bgPage,
      colorScheme: const ColorScheme.light(
        primary: blueButton,
        surface: card,
      ),
      textTheme: base.textTheme.copyWith(
        titleLarge: const TextStyle(
          color: textDark, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 0.8),
        displayLarge: const TextStyle(
          color: textDark, fontSize: 56, fontWeight: FontWeight.w900, height: 1.05),
        bodySmall: const TextStyle(
          color: textMuted, fontSize: 18, letterSpacing: 0.3),
        bodyMedium: const TextStyle(
          color: textDark, fontSize: 22, fontWeight: FontWeight.w600),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: blueButton,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
      ),

      dialogTheme: DialogThemeData(
  backgroundColor: card,
  surfaceTintColor: card,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(cardRadius),
  ),
  titleTextStyle: const TextStyle(
    color: textDark, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 0.5),
  contentTextStyle: const TextStyle(color: textDark, fontSize: 16),
),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: textDark.withOpacity(0.06),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
          borderSide: BorderSide(color: textMuted.withOpacity(0.25)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
          borderSide: BorderSide(color: textMuted.withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
          borderSide: const BorderSide(color: blueButton, width: 1.4),
        ),
      ),

      dividerTheme: const DividerThemeData(color: divider, thickness: 1, space: 1),
      iconTheme: const IconThemeData(color: textDark, size: 22),
    );
  }
}
