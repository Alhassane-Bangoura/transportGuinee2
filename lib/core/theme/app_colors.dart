import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Premium Dark Palette (Spotify-like)
  static const Color premiumDark = Color(0xFF06141B);
  static const Color premiumNavy = Color(0xFF11212D);
  static const Color premiumSteel = Color(0xFF253745);
  static const Color premiumMutedBlue = Color(0xFF4A5C6A);
  static const Color premiumGrey = Color(0xFF9BABAB);
  static const Color premiumLight = Color(0xFFCCD0CF);

  // Primaires (Navy Blue de la maquette)
  static const Color primary = premiumNavy;
  static const Color primaryLight = premiumMutedBlue;
  static const Color primaryDark = premiumDark;

  // Accents (Orange de la maquette Syndicat)
  static const Color accent = Color(0xFFF97316);
  static const Color accentLight = Color(0xFFFFF7ED);

  // Neutres (Background & Surface de la maquette)
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF6F7F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);

  // Textes (Slate de Tailwind)
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textHint = Color(0xFF94A3B8);

  // Alias pour compatibilité
  static const Color onBackground = textPrimary;
  static const Color onPrimary = white;
  static const Color onSurface = textPrimary;
  static const Color onSurfaceVariant = textSecondary;

  // Couleurs sémantiques
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Ombre
  static const Color shadow = Color(0x0D1A3D75);
}
