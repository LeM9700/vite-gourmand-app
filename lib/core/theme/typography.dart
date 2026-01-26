import 'package:flutter/material.dart';
import 'colors.dart';

/// Typography sophistiquée pour une application gourmande haut de gamme
class AppTextStyles {
  AppTextStyles._();

  // Font families - Élégance et lisibilité
  static const String primaryFont =
      'Playfair Display'; // Pour les titres élégants
  static const String secondaryFont = 'Inter'; // Pour le corps de texte

  // Hierarchy - Titres avec élégance
  static TextStyle heroTitle = const TextStyle(
    fontFamily: primaryFont,
    fontSize: 42,
    fontWeight: FontWeight.w700,
    height: 1.1,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle displayTitle = const TextStyle(
    fontFamily: primaryFont,
    fontSize: 34,
    fontWeight: FontWeight.w600,
    height: 1.15,
    color: AppColors.textPrimary,
    letterSpacing: -0.25,
  );

  static TextStyle sectionTitle = const TextStyle(
    fontFamily: primaryFont,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static TextStyle cardTitle = const TextStyle(
    fontFamily: secondaryFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: AppColors.textPrimary,
    letterSpacing: 0.15,
  );

  static TextStyle subtitle = const TextStyle(
    fontFamily: secondaryFont,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textSecondary,
    letterSpacing: 0.1,
  );

  // Body text - Lisibilité optimale
  static TextStyle body = const TextStyle(
    fontFamily: secondaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = const TextStyle(
    fontFamily: secondaryFont,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.textPrimary,
  );

  static TextStyle caption = const TextStyle(
    fontFamily: secondaryFont,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.35,
    color: AppColors.textSecondary,
    letterSpacing: 0.25,
  );

  static TextStyle overline = const TextStyle(
    fontFamily: secondaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: AppColors.textMuted,
    letterSpacing: 0.8,
  );

  // Button text - Lisibilité et hiérarchie
  static TextStyle buttonPrimary = const TextStyle(
    fontFamily: secondaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: AppColors.onPrimary,
    letterSpacing: 0.15,
  );

  static TextStyle buttonSecondary = const TextStyle(
    fontFamily: secondaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: AppColors.primary,
    letterSpacing: 0.15,
  );

  // Accent styles - Pour les moments spéciaux
  static TextStyle goldAccent = TextStyle(
    fontFamily: primaryFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.primary,
    letterSpacing: 0.15,
  );

  static TextStyle elegantQuote = TextStyle(
    fontFamily: primaryFont,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
    fontStyle: FontStyle.italic,
    letterSpacing: 0.1,
  );
}
