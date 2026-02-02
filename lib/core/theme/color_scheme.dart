import 'package:flutter/material.dart';

// ─── Fresh Mint Green Palette ───────────────────────────────
// Clean, modern rehabilitation app. High-end reference aesthetic.

const Color seedMint = Color(0xFF00D09E);

const ColorScheme appColorScheme = ColorScheme(
  brightness: Brightness.light,

  // Primary: fresh mint green
  primary: seedMint,
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFD4F5EC),
  onPrimaryContainer: Color(0xFF0D3B2E),

  // Secondary: soft teal
  secondary: Color(0xFF6BBFAB),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFDFF5EF),
  onSecondaryContainer: Color(0xFF1A4A3D),

  // Tertiary: warm sand accent
  tertiary: Color(0xFFA3937B),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFF0EBE3),
  onTertiaryContainer: Color(0xFF4A4235),

  // Error
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),

  // Surface: pure white cards on pale mint-grey scaffold
  surface: Color(0xFFFFFFFF),
  onSurface: Color(0xFF2D3142),
  onSurfaceVariant: Color(0xFF6E7787),
  surfaceContainerHighest: Color(0xFFEEF3F1),

  // Outline: light neutral dividers
  outline: Color(0xFFCDD5D2),
  outlineVariant: Color(0xFFE2E8E5),

  // Misc
  shadow: Color(0x14000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFF2D3142),
  onInverseSurface: Color(0xFFF1F8F6),
  inversePrimary: Color(0xFF7DDFCA),
);

// Scaffold / page background: pale mint-grey
const Color scaffoldBackground = Color(0xFFF1F8F6);
