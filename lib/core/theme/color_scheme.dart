import 'package:flutter/material.dart';

// ─── Calm Medical Green Palette ─────────────────────────────
// Low-saturation, rehabilitation-focused. iOS-native feel.

const Color seedGreen = Color(0xFF6B9080);

const ColorScheme appColorScheme = ColorScheme(
  brightness: Brightness.light,

  // Primary: muted sage green
  primary: seedGreen,
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFDCEDE6),
  onPrimaryContainer: Color(0xFF2C4A3E),

  // Secondary: warm neutral
  secondary: Color(0xFF8A9A92),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFE8F0ED),
  onSecondaryContainer: Color(0xFF3A4A42),

  // Tertiary: subtle warm accent
  tertiary: Color(0xFFA3937B),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFF0EBE3),
  onTertiaryContainer: Color(0xFF4A4235),

  // Error
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),

  // Surface: clean white with warm off-white scaffold
  surface: Color(0xFFFFFFFF),
  onSurface: Color(0xFF1C1C1E),
  onSurfaceVariant: Color(0xFF6E6E73),
  surfaceContainerHighest: Color(0xFFF2F2F7),

  // Outline: very light neutral dividers
  outline: Color(0xFFD1D1D6),
  outlineVariant: Color(0xFFE5E5EA),

  // Misc
  shadow: Color(0x0A000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFF2C2C2E),
  onInverseSurface: Color(0xFFF2F2F7),
  inversePrimary: Color(0xFFA8D4C0),
);

// Scaffold / page background: warm off-white
const Color scaffoldBackground = Color(0xFFF8F8F6);
