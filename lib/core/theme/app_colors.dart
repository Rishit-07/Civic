import 'package:flutter/material.dart';

/// Design tokens: CIVIC Legal Design System Colors
class AppColors {
  AppColors._();

  // Core Brand & Accents
  static const Color primary = Color(0xFFFF5A00); // Vivid judicial orange
  static const Color primaryDark = Color(0xFFA83900);
  static const Color primaryContainer = Color(0xFFFFDBCE);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF511700);

  // Secondary Slate
  static const Color secondary = Color(0xFF17261F); // Deep botanical slate-black
  static const Color secondaryLight = Color(0xFF526259);
  static const Color secondaryContainer = Color(0xFFD5E7DC);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // Canvas & Surfaces
  static const Color canvas = Color(0xFFFAFAFA); // Warm chalk off-white
  static const Color surface = Color(0xFFFFFFFF); // Pure white card surface
  static const Color surfaceLow = Color(0xFFF3F3F3);
  static const Color surfaceContainerLow = Color(0xFFF3F3F3);
  static const Color surfaceContainer = Color(0xFFEEEEEE);
  static const Color surfaceContainerHigh = Color(0xFFE8E8E8);
  static const Color surfaceContainerHighest = Color(0xFFE2E2E2);

  // Architectural Background Accents
  static const Color blobBackground = Color(0xFFE8E9F0);

  // Text & Reading Contrast
  static const Color textPrimary = Color(0xFF111111); // Deep charcoal body ink
  static const Color textSecondary = Color(0xFF17261F);
  static const Color textMuted = Color(0xFF8A8A8A); // Controlled neutral subtext
  static const Color onSurfaceVariant = Color(0xFF5B4137);

  // Borders & Dividers
  static const Color borderSubtle = Color(0xFFECEEF2);
  static const Color borderOutline = Color(0xFFE2E4EB);

  // Affirmative & Alert Semantics
  static const Color doGreen = Color(0xFF15803D);
  static const Color doGreenContainer = Color(0xFFECFDF5);
  static const Color dontRed = Color(0xFFDC2626);
  static const Color dontRedContainer = Color(0xFFFEF2F2);
}
