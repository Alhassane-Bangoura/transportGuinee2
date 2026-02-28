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
    return SafeArea(
      child: Column(
        children: [
          // Bouton Passer (vert)
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onSkip,
                child: Text(
                  'Passer',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          // Illustration billet numérique
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: _buildTicketCard(),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  'Suivez vos réservations\nen toute sécurité',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.displayMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Recevez votre billet numérique et voyagez\nsereinement à travers la Guinée.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 32),
                OnboardingDots(
                    currentPage: currentPage, totalPages: totalPages),
                const SizedBox(height: 24),
                PrimaryButton(label: 'Suivant', onPressed: onNext),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête du billet
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Numéro billet
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'POT-2024-08',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Villes départ → arrivée
                Row(
                  children: [
                    // Point départ
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DÉPART', style: AppTextStyles.label),
                        const SizedBox(height: 4),
                        Text(
                          'Conakry',
                          style:
                              AppTextStyles.headingLarge.copyWith(fontSize: 20),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Ligne de trajet
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 40,
                              height: 2,
                              color: AppColors.border,
                            ),
                            const Icon(Icons.directions_bus_rounded,
                                color: AppColors.primary, size: 20),
                            Container(
                              width: 40,
                              height: 2,
                              color: AppColors.border,
                            ),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.textSecondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Arrivée
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('DESTINATION', style: AppTextStyles.label),
                        const SizedBox(height: 4),
                        Text(
                          'Labé',
                          style:
                              AppTextStyles.headingLarge.copyWith(fontSize: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Séparateur en pointillés
          _DashedDivider(),

          // QR Code zone
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CustomPaint(
                    painter: _QRPainter(),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.qr_code_2_rounded,
                          color: AppColors.primary, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Scanner votre billet',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const dashWidth = 6.0;
              const dashSpace = 4.0;
              final count =
                  (constraints.maxWidth / (dashWidth + dashSpace)).floor();
              return Row(
                children: List.generate(
                  count,
                  (_) => Padding(
                    padding: const EdgeInsets.only(right: dashSpace),
                    child: Container(
                      width: dashWidth,
                      height: 1.5,
                      color: AppColors.border,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

/// Simule un QR code avec CustomPainter
class _QRPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A1A2E)
      ..style = PaintingStyle.fill;

    final cellSize = size.width / 7;

    // Matrice simplifiée simulant un QR
    const matrix = [
      [1, 1, 1, 0, 1, 1, 1],
      [1, 0, 1, 0, 1, 0, 1],
      [1, 1, 1, 0, 1, 1, 1],
      [0, 0, 0, 1, 0, 0, 0],
      [1, 1, 1, 0, 1, 0, 1],
      [1, 0, 1, 1, 0, 1, 1],
      [1, 1, 1, 0, 1, 1, 1],
    ];

    for (int row = 0; row < 7; row++) {
      for (int col = 0; col < 7; col++) {
        if (matrix[row][col] == 1) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                col * cellSize + 1,
                row * cellSize + 1,
                cellSize - 2,
                cellSize - 2,
              ),
              const Radius.circular(2),
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
