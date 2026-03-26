import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../onboarding_screen.dart';

/// Onboarding 3 — Suivez vos réservations en toute sécurité
class OnboardingPage3 extends StatelessWidget {
  const OnboardingPage3({
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
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
                'https://r.jina.ai/i/6cdec3f0694e419890f6b43063851532',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: AppColors.primary),
              ),
            ),
          ),
          
          // Bouton Passer
          Positioned(
            top: 60,
            right: 20,
            child: TextButton(
              onPressed: onSkip,
              child: Text(
                'PASSER',
                style: AppTextStyles.label.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
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
                color: AppColors.white,
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
                    'L\'application simplifie\nle transport',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headingLarge.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      height: 1.1,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Description
                  Text(
                    'Gagnez du temps et voyagez plus sereinement. Votre trajet commence ici, avec Guinee Transport.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Pagination Dots
                  OnboardingDots(currentPage: currentPage, totalPages: totalPages),
                  
                  const SizedBox(height: 32),
                  
                  // Bouton Suivant (Démarrer)
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
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
