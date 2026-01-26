import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color ink = Color(0xFF1E1A1A);
  static const Color paper = Color(0xFFF3F1EE);
  static const Color card = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFF9A948C);
  static const Color accent = Color(0xFFF0A21A);
  static const Color accentDeep = Color(0xFFE78A00);
  static const Color green = Color(0xFF22A35A);
  static const Color red = Color(0xFFE54545);
  static const Color sky = Color(0xFF5F8DFF);
  static const Color slate = Color(0xFFE4E0DB);
}

ThemeData buildAppTheme() {
  final base = ThemeData.light();
  final textTheme = GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
    titleLarge: GoogleFonts.dmSans(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: AppColors.ink,
    ),
    titleMedium: GoogleFonts.dmSans(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.ink,
    ),
    bodyLarge: GoogleFonts.dmSans(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.ink,
    ),
    bodyMedium: GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.ink,
    ),
    labelLarge: GoogleFonts.dmSans(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: AppColors.ink,
    ),
  );

  return base.copyWith(
    useMaterial3: false,
    scaffoldBackgroundColor: AppColors.paper,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.accent,
      secondary: AppColors.accentDeep,
      surface: AppColors.card,
    ),
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.paper,
      foregroundColor: AppColors.ink,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  );
}
