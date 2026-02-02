import 'package:flutter/material.dart';
import 'color_scheme.dart';
import 'text_theme.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: appColorScheme,
      textTheme: appTextTheme,
      scaffoldBackgroundColor: scaffoldBackground,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: appColorScheme.outlineVariant, width: 0.5),
        ),
        color: appColorScheme.surface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size.fromHeight(52),
          backgroundColor: appColorScheme.primary,
          foregroundColor: appColorScheme.onPrimary,
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: appColorScheme.primary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: appColorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      dividerTheme: DividerThemeData(
        color: appColorScheme.outlineVariant,
        thickness: 0.5,
      ),
      iconTheme: IconThemeData(
        color: appColorScheme.onSurfaceVariant,
      ),
    );
  }
}
