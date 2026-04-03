import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'register/driver_register_page.dart';
import 'register/passenger_register_page.dart';
import 'register/station_admin_register_page.dart';
import 'register/syndicate_register_page.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'GUINÉE TRANSPORT',
          style: AppTextStyles.label.copyWith(
            color: AppColors.primary.withValues(alpha: 0.5),
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface, // Correction ici
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'GUINÉE TRANSPORT',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Choisissez votre rôle\ndans le transport',
                textAlign: TextAlign.center,
                style: AppTextStyles.headingLarge.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                  color: AppColors.textPrimary, // Correction ici
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Rejoignez l\'écosystème de transport le plus moderne de Guinée. Sélectionnez le profil qui correspond à votre activité pour commencer.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              _buildRoleCard(
                context,
                icon: Icons.person_rounded,
                title: 'Passager',
                description: 'Réservez vos trajets en un clic, suivez vos chauffeurs en temps réel et voyagez en toute sécurité à travers le pays.',
                cta: 'Continuer en tant que passager',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PassengerRegisterPage())),
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                context,
                icon: Icons.directions_bus_rounded,
                title: 'Chauffeur',
                description: 'Optimisez vos revenus, gérez vos trajets et rejoignez une communauté de professionnels certifiés.',
                cta: 'S\'inscrire comme chauffeur',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverRegisterPage())),
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                context,
                icon: Icons.groups_rounded,
                title: 'Syndicat',
                description: 'Supervisez les activités, gérez les chauffeurs et assurez la fluidité du transport dans vos gares.',
                cta: 'Rejoindre un syndicat',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SyndicateRegisterPage())),
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                context,
                icon: Icons.admin_panel_settings_rounded,
                title: 'Administrateur Gare',
                description: 'Gérez les quais, les départs et l\'organisation de votre établissement en toute simplicité.',
                cta: 'Gérer une gare',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StationAdminRegisterPage())),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String cta,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface, // Correction ici
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border, width: 1.5), // Correction ici
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2), // Correction ici
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.headingLarge.copyWith(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  cta,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
