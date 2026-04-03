import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Premium Dark Teal Palette (Optimized for Readability)
  static const Color premiumDark = Color(0xFF021414); // Plus profond pour le contraste
  static const Color premiumNavy = Color(0xFF05211E); // Surface
  static const Color premiumSteel = Color(0xFF0D2D27); // Bordures
  static const Color premiumTeal = Color(0xFF10B981); // Pour les actions (Emeraude/Teal)
  static const Color premiumLightTeal = Color(0xFFD1FAE5); // Pour les textes secondaires/badges

  // Primaires
  static const Color primary = premiumTeal; 
  static const Color primaryDark = Color(0xFF064E3B);
  static const Color primaryLight = premiumLightTeal;

  // Accents (Basé sur la référence pour les points d'attention)
  static const Color accent = Color(0xFFF59E0B); // Orange Ambre pour "Suivant" / "Attention"
  static const Color accentLight = Color(0xFFFEF3C7);

  // Neutres
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = premiumDark;
  static const Color surface = premiumNavy;
  static const Color surfaceVariant = premiumSteel;
  static const Color border = premiumSteel;

  // Textes (Contraste Maximum)
  static const Color textPrimary = Color(0xFFF8FAFC); 
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400 pour un look pro
  static const Color textHint = Color(0xFF475569); 

  // Alias pour compatibilité
  static const Color onBackground = white;
  static const Color onPrimary = white; // Texte Blanc sur Teal/Emeraude
  static const Color onAccent = Color(0xFF021414); // Texte Sombre sur Orange
  static const Color onSurface = white;
  static const Color onSurfaceVariant = Color(0xFFCBD5E1);

  // Couleurs sémantiques
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Ombre
  static const Color shadow = Color(0x99000000); 
}
