import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../onboarding_screen.dart';
import '../../../core/constants/app_assets.dart';

/// Onboarding 4 — Recherche de Trajet
class OnboardingPage4 extends StatelessWidget {
  const OnboardingPage4({
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
          // Illustration / Carte de trajet (tiers supérieur)
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
              child: Stack(
                children: [
                  // Image de fond (Map abstract)
                  Opacity(
                    opacity: 0.2,
                    child: Image.network(
                      AppAssets.onboardingStep4,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Carte de destination flottante
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildRouteRow(
                            icon: Icons.location_on,
                            label: 'DÉPART',
                            value: 'Conakry, Grand Marché',
                            isStart: true,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 11),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('|', style: TextStyle(color: AppColors.border, fontSize: 10)),
                            ),
                          ),
                          _buildRouteRow(
                            icon: Icons.flag,
                            label: 'DESTINATION',
                            value: 'Labé, Centre Ville',
                            isStart: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
                'PASSER',
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
                    'Trouvez votre trajet\nen quelques secondes',
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
                    'Planifiez vos déplacements à travers la Guinée avec une précision inégalée et une sécurité garantie.',
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
                  
                  // Bouton Suivant
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

  Widget _buildRouteRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isStart,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
