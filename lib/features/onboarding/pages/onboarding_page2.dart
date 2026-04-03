import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_text_styles.dart';
import '../onboarding_screen.dart';

/// Onboarding 2 — Réservez votre siège en quelques clics
class OnboardingPage2 extends StatefulWidget {
  const OnboardingPage2({
    super.key,
    required this.onNext,
    required this.onSkip,
    required this.currentPage,
    required this.totalPages,
  });

  final VoidCallback onNext;
  final VoidCallback onSkip;
  final int currentPage;
  final int totalPages;

  @override
  State<OnboardingPage2> createState() => _OnboardingPage2State();
}

class _OnboardingPage2State extends State<OnboardingPage2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Image de fond premium (tiers supérieur)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              child: Image.network(
                AppAssets.onboardingStep2,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: AppColors.primary),
              ),
            ),
          ),
          
          // Bouton Passer
          Positioned(
            top: 60,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: TextButton(
                onPressed: widget.onSkip,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(
                  'PASSER',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Contenu (deux tiers inférieurs)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.42,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              decoration: const BoxDecoration(
                color: AppColors.background, // Correction ici
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                   const SizedBox(height: 20),
                  // Logo / Petit badge
                  Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Titre
                  Text(
                    'Recherche\nIntelligente',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headingLarge.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Description
                  Text(
                    'Planifiez vos déplacements en toute sérénité. Notre algorithme trouve pour vous les meilleurs itinéraires au meilleur prix.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Pagination Dots
                  OnboardingDots(currentPage: widget.currentPage, totalPages: widget.totalPages),
                  
                  const SizedBox(height: 32),
                  
                  // Bouton Suivant
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: widget.onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.onAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                        shadowColor: AppColors.accent.withValues(alpha: 0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Suivant',
                            style: AppTextStyles.buttonText.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 22),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
