import 'package:flutter/material.dart';

class AppTheme {
  static const Color mintPrimary = Color(0xFF10B981);
  static const Color mintSoft = Color(0xFFD1FAE5);
  static const Color surfaceSoft = Color(0xFFF9FAFB);
  static const Color textPrimary = Color(0xFF111827);

  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: mintPrimary,
        secondary: mintSoft,
        surface: surfaceSoft,
        onPrimary: Color(0xFFFFFFFF),
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: surfaceSoft,
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        color: surfaceSoft,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          minimumSize: const Size.fromHeight(54),
          backgroundColor: mintPrimary,
          foregroundColor: const Color(0xFFFFFFFF), // ✅ 추가: 텍스트 색상 명시
        ),
      ),
    );
  }
}
