import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Palettes de référence (HTML)
  static const Color primary = Color(0xFF1A3D75); // Deep Blue Navy
  static const Color background = Color(0xFFF6F7F8); // Fond clair cassé
  static const Color surface = Color(0xFFFFFFFF); // Blanc pur pour les cartes
  static const Color onPrimary = Color(0xFFFFFFFF); 
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textHint = Color(0xFF94A3B8); // Slate 400
  static const Color border = Color(0xFFE2E8F0); // Slate 200

  // Accents & Statuts
  static const Color accent = Color(0xFF059669); // Emerald 600
  static const Color onAccent = Color(0xFFFFFFFF); // White for contrast
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color info = Color(0xFF3B82F6); // Blue 500

  // Neutres & Surfaces
  static const Color white = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color shadow = Color(0x0D000000); // Ombre très légère (Tailwind shadow-sm)

  // Alias pour rétrocompatibilité
  static const Color onBackground = textPrimary;
  static const Color onSurface = textPrimary;
  static const Color onSurfaceVariant = textSecondary;
  static const Color premiumNavy = primary;
  static const Color premiumGreen = success;
  static const Color premiumLightGray = background;
  static const Color premiumWhite = white;
  static const Color premiumBorder = border;
  static const Color primaryLight = Color(0xFF334155); // Pour compatibilité splash
  static const Color primaryDark = Color(0xFF0F172A); // Pour compatibilité splash
}
