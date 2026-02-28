import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
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
  // Sièges sélectionnés (orange) pour la démo
  final Set<int> _selected = {4, 7};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // En-tête avec logo + Passer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: const TextSpan(children: [
                    TextSpan(
                      text: 'Guinee',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    TextSpan(
                      text: 'Transport',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ]),
                ),
                TextButton(
                  onPressed: widget.onSkip,
                  child: Text(
                    'Passer',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Illustration grille de sièges
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: _buildSeatGrid(),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Titre
                Text(
                  'Réservez votre siège\nen quelques clics',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.displayMedium,
                ),
                const SizedBox(height: 16),
                // Description
                Text(
                  'Choisissez votre place préférée et confirmez\ninstantanément votre voyage.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 32),

                // Dots
                OnboardingDots(
                    currentPage: widget.currentPage,
                    totalPages: widget.totalPages),
                const SizedBox(height: 24),

                // Bouton Suivant
                PrimaryButton(
                  label: 'Suivant',
                  onPressed: widget.onNext,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatGrid() {
    // Grille 4 colonnes x 3 rangées = 12 sièges
    const int cols = 4;
    const int rows = 3;

    return Column(
      children: [
        // Icône chauffeur en haut
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person_rounded,
                  color: AppColors.textSecondary, size: 22),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Grille
        ...List.generate(rows, (row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 2 sièges gauche
                _buildSeat(row * cols),
                const SizedBox(width: 10),
                _buildSeat(row * cols + 1),
                const SizedBox(width: 24), // couloir
                // 2 sièges droite
                _buildSeat(row * cols + 2),
                const SizedBox(width: 10),
                _buildSeat(row * cols + 3),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSeat(int idx) {
    final bool isSelected = _selected.contains(idx);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selected.contains(idx)) {
            _selected.remove(idx);
          } else {
            _selected.add(idx);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 54,
        height: 52,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.orange : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.orange.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Icon(
          Icons.airline_seat_recline_normal_rounded,
          size: 26,
          color: isSelected ? Colors.white : AppColors.textHint,
        ),
      ),
    );
  }
}
