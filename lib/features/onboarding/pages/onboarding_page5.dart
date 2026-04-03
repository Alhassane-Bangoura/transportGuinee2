import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../onboarding_screen.dart';

/// Onboarding 5 — Simplicité du transport
class OnboardingPage5 extends StatelessWidget {
  const OnboardingPage5({
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
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Illustration / Bus (tiers supérieur)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuD15yPZEtjhSILW9WP_Q0LNxp54wBwb-wIqs7hxeHrbyxN9EkYHj5Kb9D19Vhf4Gq-iq82tNIEUxR0viFcWuCW2rGNaAfZ7K7XwGwcDWFp8_KKjx3bqYzAtq0qsiAQGkMv8kGWZnI4OOaM9ttqQJ4wUK8MqvcrHYBx9ozYFBYhEWvvwi7ScDBoFJp1FGhQSs6nD7fgjP0TqWfMuClSjkprO-RrARhozO_lWJe5OWL79FiylSSnvvuNDz58LDyNv9CkazR8Y2Df_XtPE',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: AppColors.primary),
                ),
              ),
            ),
          ),
          
          // Bouton Passer
          Positioned(
            top: 60,
            right: 20,
            child: TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                'COMMENCER',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
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
                color: AppColors.background,
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
                    'L\'application simplifie\nle transport entre les villes',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headingLarge.copyWith(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Description
                  Text(
                    'Réservez vos trajets en quelques clics et voyagez en toute sécurité à travers le pays.',
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
                  
                  // Bouton Terminer
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: onNext,
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
                            'C\'est parti !',
                            style: AppTextStyles.buttonText.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.flash_on_rounded, size: 22),
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
