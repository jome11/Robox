import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Serif display font for logo/page titles, matching the reference design.
  static TextStyle get logo => GoogleFonts.playfairDisplay(
        color: AppColors.primary,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get headline => GoogleFonts.playfairDisplay(
        color: AppColors.text,
        fontSize: 26,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get body => GoogleFonts.inter(
        color: AppColors.text,
        fontSize: 15,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get label => GoogleFonts.inter(
        color: AppColors.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
      );

  static TextStyle get button => GoogleFonts.inter(
        color: AppColors.onPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      );
}
