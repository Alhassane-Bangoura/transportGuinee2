import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../onboarding_screen.dart';

/// Onboarding 1 — Trouvez vos trajets facilement
class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            // Header avec bouton Passer
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onSkip,
                child: Text(
                  'Passer',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Illustration principale
            _buildIllustration(),

            const SizedBox(height: 48),

            // Titre
            Text(
              'Trouvez vos trajets\nfacilement',
              textAlign: TextAlign.center,
              style: AppTextStyles.displayMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              'Consultez les départs disponibles en quelques\nsecondes et réservez votre place en toute simplicité.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),

            const Spacer(),

            // Dots
            OnboardingDots(currentPage: currentPage, totalPages: totalPages),
            const SizedBox(height: 24),

            // Bouton Suivant
            PrimaryButton(
              label: 'Suivant',
              onPressed: onNext,
              showArrow: true,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Cercles décoratifs
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          // Bus icon centré
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_bus_filled_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Pin de destination
          Positioned(
            bottom: 40,
            left: 48,
            child: _locationPin(AppColors.primaryLight),
          ),
          Positioned(
            top: 40,
            right: 64,
            child: _locationPin(Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _locationPin(Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        Icons.location_on_rounded,
        size: 18,
        color:
            color == Colors.white ? AppColors.primary : AppColors.primaryDark,
      ),
    );
  }
}
