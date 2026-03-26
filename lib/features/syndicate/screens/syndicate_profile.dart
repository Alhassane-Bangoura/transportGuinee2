import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/models/user_profile.dart';
import '../../profile/screens/edit_profile_page.dart';

import '../../../core/services/biometric_service.dart';
import '../../../core/services/auth_service.dart';
import '../../auth/login_page.dart';

class SyndicateProfilePage extends StatefulWidget {
  final UserProfile? profile;
  final VoidCallback? onRefresh;
  const SyndicateProfilePage({super.key, this.profile, this.onRefresh});

  @override
  State<SyndicateProfilePage> createState() => _SyndicateProfilePageState();
}

class _SyndicateProfilePageState extends State<SyndicateProfilePage> {
  bool _isBiometricEnabled = false;
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricSettings();
  }

  Future<void> _loadBiometricSettings() async {
    final available = await BiometricService.isAvailable();
    final enabled = await BiometricService.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _isBiometricAvailable = available;
        _isBiometricEnabled = enabled;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      final authenticated = await BiometricService.authenticate();
      if (authenticated) {
        await BiometricService.setBiometricEnabled(true);
        setState(() => _isBiometricEnabled = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentification biométrique activée')),
          );
        }
      }
    } else {
      await BiometricService.setBiometricEnabled(false);
      setState(() => _isBiometricEnabled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            _buildProfileHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildStatsGrid(),
                  const SizedBox(height: 24),
                  _buildDetailedInfo(),
                  const SizedBox(height: 24),
                  _buildActions(context),
                  const SizedBox(height: 24),
                  _buildSupportCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, Color(0xFF1e3a8a)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Opacity(
            opacity: 0.3,
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDldn65BomRbpgSP2jQGsHYSqeS8KYk91ds-XPrSeNRO9ByXBrhpDp6Yb-RSUtLGJ4CgyggM-koFOVtncyoy2uwGUYVK_MwDWgT2RbUjtwLwybte6PrwdoKJMhGm1V0XR3YPO2nLWuv_WgLZ_YFPv2fQTzpf8P9KroNUF_IY8k9SO0Uy-YjnbgpNdO-F9lo5RwCGCijPfcDDpX9p-_uXp-Gfr6szBAAQonbwDxg91iqx9AC4lTiLkFRaaXvRslIwXtlexutGhSqUbcM',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 16,
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ),
        Positioned(
          bottom: -40,
          left: 24,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBhA7cKadw9w6BRZPgYEjjFISsKa9S3f-6Otj_rOR9Jo4jTEnj_evZ_KtU1aae0KKCXkqe1Df_bNcJhYPlwnZNtbHdtNYHUz2BKnht24qkJVCZ6ZI46wAzTiFUylVWrnSVKtrUzHURhg3k8TVD9kCJ8PTJkVHACUQ6H8VuOfMo3PawONLqEUliogvifAEPCgK0uC0NrncIk5m6B-X1BltW6DS9AuuV-NIk16JtcujUj2F09Sb7E82PGWZ-3Oq7r04sQfpAFCMK_sJQP',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'UNION OFFICIELLE',
                        style: AppTextStyles.label.copyWith(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.profile?.fullName ?? 'Syndicat Conakry-Labé',
                      style: AppTextStyles.headingLarge.copyWith(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'GuineeTransport - Votre compte',
                          style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(
              child: _buildSimpleStatCard('Chauffeurs', '1,284', Icons.groups_rounded, '+12%', AppColors.success),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSimpleStatCard('Véhicules', '856', Icons.local_shipping_rounded, '/ 920', AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.analytics_rounded, color: Colors.blueAccent, size: 32),
                  SizedBox(),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'DÉPARTS CE MOIS',
                style: AppTextStyles.label.copyWith(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700),
              ),
              Text(
                '4,120',
                style: AppTextStyles.headingLarge.copyWith(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleStatCard(String title, String value, IconData icon, String subtitle, Color subtitleColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 12),
          Text(
            title.toUpperCase(),
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTextStyles.headingLarge.copyWith(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 4),
              Text(
                subtitle,
                style: AppTextStyles.label.copyWith(color: subtitleColor, fontSize: 10, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations Détaillées',
            style: AppTextStyles.headingLarge.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.route_rounded, 'Trajet géré', widget.profile?.metadata?['managed_route'] ?? 'Conakry ↔ Labé', 'Ligne nationale principale via Mamou et Dalaba.'),
          const Divider(height: 32, color: AppColors.border),
          _buildInfoRow(Icons.warehouse_rounded, 'Gare de rattachement', widget.profile?.metadata?['station_name'] ?? 'Gare Routière de Bambéto', 'Terminal de départ principal - Secteur Conakry.'),
          const Divider(height: 32, color: AppColors.border),
          _buildInfoRow(Icons.badge_rounded, 'Responsable', widget.profile?.fullName ?? 'M. Mamadou Diallo', 'Secrétaire Général de la Coordination Syndicale.'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: AppTextStyles.label.copyWith(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w800),
              ),
              Text(
                value,
                style: AppTextStyles.headingLarge.copyWith(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        _buildActionButton(Icons.edit_rounded, 'Modifier le profil', AppColors.primary, Colors.white, onTap: () async {
          if (widget.profile == null) return;
          final updated = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfilePage(profile: widget.profile!),
            ),
          );
          if (updated == true) {
            widget.onRefresh?.call();
          }
        }),
        const SizedBox(height: 12),
        if (_isBiometricAvailable) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.fingerprint, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Connexion par empreinte',
                    style: AppTextStyles.headingLarge.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
                Switch(
                  value: _isBiometricEnabled,
                  onChanged: _toggleBiometric,
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        _buildActionButton(Icons.bar_chart_rounded, 'Voir stats détaillées', Colors.white, AppColors.textPrimary, isOutlined: true),
        const SizedBox(height: 12),
        _buildActionButton(Icons.logout_rounded, 'Se déconnecter', const Color(0xFFFEF2F2), AppColors.error, onTap: () async {
          await AuthService.signOut();
          if (mounted && context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          }
        }),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color bgColor, Color textColor, {bool isOutlined = false, VoidCallback? onTap}) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: isOutlined ? Border.all(color: AppColors.border) : null,
        boxShadow: !isOutlined && bgColor == AppColors.primary
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.headingLarge.copyWith(color: textColor, fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD0E8FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SUPPORT SYNDICAL',
            style: AppTextStyles.label.copyWith(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'Besoin d\'aide pour gérer vos véhicules ou vos trajets ? Contactez notre centre d\'assistance.',
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 13, color: const Color(0xFF1E429F), height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.support_agent_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Contacter le support',
                style: AppTextStyles.headingLarge.copyWith(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
