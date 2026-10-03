import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Design tokens: Typography specifications
class AppTypography {
  AppTypography._();

  // Display (Montserrat ExtraBold Uppercase)
  static TextStyle displayLarge = GoogleFonts.montserrat(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: 1.2,
    color: AppColors.secondary,
  );

  // Headlines (Montserrat Bold / ExtraBold)
  static TextStyle headlineLarge = GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1.25,
    letterSpacing: 1.0,
    color: AppColors.secondary,
  );

  static TextStyle headlineMedium = GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0.8,
    color: AppColors.secondary,
  );

  static TextStyle headlineSmall = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0.6,
    color: AppColors.secondary,
  );

  // Body text (Plus Jakarta Sans Humanist)
  static TextStyle bodyLarge = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.6,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.55,
    color: AppColors.textPrimary,
  );

  static TextStyle bodySmall = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textMuted,
  );

  // Labels & Tags (Montserrat Uppercase Tracking)
  static TextStyle labelLarge = GoogleFonts.montserrat(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 1.0,
    color: AppColors.secondary,
  );

  static TextStyle labelMedium = GoogleFonts.montserrat(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 1.0,
    color: AppColors.textMuted,
  );

  static TextStyle labelSmall = GoogleFonts.montserrat(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 1.2,
    color: AppColors.textMuted,
  );
}
