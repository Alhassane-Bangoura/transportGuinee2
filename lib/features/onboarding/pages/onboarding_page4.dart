import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/login_page.dart';
import '../../auth/register/passenger_register_page.dart';
import '../../auth/register/driver_register_page.dart';
import '../../auth/register/syndicate_register_page.dart';
import '../../auth/register/station_admin_register_page.dart';
import '../onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding 4 — Une plateforme pour tous
class OnboardingPage4 extends StatefulWidget {
  const OnboardingPage4({
    super.key,
    required this.onFinish,
    required this.currentPage,
    required this.totalPages,
  });

  final VoidCallback onFinish;
  final int currentPage;
  final int totalPages;

  @override
  State<OnboardingPage4> createState() => _OnboardingPage4State();
}

class _OnboardingPage4State extends State<OnboardingPage4> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // En-tête avec bouton retour + logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 20, color: AppColors.textPrimary),
                ),
                const Spacer(),
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
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
          ),

          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Grille des 4 rôles
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: _buildRolesGrid(),
                    ),

                    const SizedBox(height: 40),

                    // Texte
                    Text(
                      'Une plateforme\npour tous',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.displayMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Passagers, chauffeurs, syndicats et gares connectés sur un seul réseau.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bas de page
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                if (_selectedRole == null) ...[
                  OnboardingDots(
                      currentPage: widget.currentPage,
                      totalPages: widget.totalPages),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Commencer',
                    onPressed: widget.onFinish,
                    showArrow: true,
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Navigation vers la page d'inscription spécifique
                            Widget page;
                            switch (_selectedRole) {
                              case 'PASSAGER':
                                page = const PassengerRegisterPage();
                                break;
                              case 'CHAUFFEUR':
                                page = const DriverRegisterPage();
                                break;
                              case 'SYNDICAT':
                                page = const SyndicateRegisterPage();
                                break;
                              case 'GARE':
                                page = const StationAdminRegisterPage();
                                break;
                              default:
                                page = const PassengerRegisterPage();
                            }
                            _setFirstLaunchDone();
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => page),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(
                                color: AppColors.primary, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('S\'inscrire',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _setFirstLaunchDone();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      LoginPage(initialRole: _selectedRole)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('Se connecter',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRolesGrid() {
    final roles = [
      _RoleItem(
        icon: Icons.person_rounded,
        label: 'PASSAGER',
        color: AppColors.primary,
        bgColor: AppColors.primaryLight,
      ),
      _RoleItem(
        icon: Icons.drive_eta_rounded,
        label: 'CHAUFFEUR',
        color: AppColors.primary,
        bgColor: AppColors.primaryLight,
      ),
      _RoleItem(
        icon: Icons.store_rounded,
        label: 'GARE',
        color: AppColors.primary,
        bgColor: AppColors.primaryLight,
      ),
      _RoleItem(
        icon: Icons.handshake_rounded,
        label: 'SYNDICAT',
        color: AppColors.primary,
        bgColor: AppColors.primaryLight,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: roles.map(_buildRoleCard).toList(),
    );
  }

  Widget _buildRoleCard(_RoleItem role) {
    final isSelected = _selectedRole == role.label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role.label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : role.bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.15),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(role.icon,
                  color: isSelected ? Colors.white : role.color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              role.label,
              style: AppTextStyles.label.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setFirstLaunchDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);
  }
}

class _RoleItem {
  const _RoleItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
}
