import 'package:flutter/material.dart';
import 'colors.dart';

/// Système d'ombres sophistiquées pour une interface haut de gamme
class AppShadows {
  AppShadows._();

  /// Ombre élégante principale - Boutons importants
  static List<BoxShadow> elegant = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.15), // Ombre dorée
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0x08000000), // Ombre noire subtile
      offset: const Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];

  /// Ombre sophistiquée pour cartes premium
  static List<BoxShadow> premium = [
    BoxShadow(
      color: const Color(0x12000000), // Très subtile
      offset: const Offset(0, 8),
      blurRadius: 32,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0x08000000), // Accent proche
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  /// Ombre discrète pour éléments flottants
  static List<BoxShadow> subtle = [
    BoxShadow(
      color: const Color(0x06000000), // Extrêmement subtile
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  /// Ombre dramatique pour hero sections
  static List<BoxShadow> dramatic = [
    BoxShadow(
      color: const Color(0x20000000), // Plus présente
      offset: const Offset(0, 16),
      blurRadius: 40,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0x08000000), // Accent proche
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  /// Ombre interne pour effets glass sophistiqués
  static List<BoxShadow> innerGlow = [
    BoxShadow(
      color: AppColors.champagne.withOpacity(0.1), // Lueur interne dorée
      offset: const Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  // Compatibility avec l'ancien système
  static List<BoxShadow> primary = elegant;
  static List<BoxShadow> secondary = premium;  
  static List<BoxShadow> card = premium;
}