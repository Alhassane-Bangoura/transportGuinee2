import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/login_page.dart';
import '../../profile/screens/edit_profile_page.dart';

import '../../../core/services/biometric_service.dart';

class PassengerProfile extends StatefulWidget {
  final UserProfile? profile;
  final VoidCallback? onRefresh;
  const PassengerProfile({super.key, this.profile, this.onRefresh});

  @override
  State<PassengerProfile> createState() => _PassengerProfileState();
}

class _PassengerProfileState extends State<PassengerProfile> {
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
      // If turning on, we might want to authenticate first to verify
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
    final Color primaryColor = AppColors.primary;
    final Color backgroundColor = AppColors.background;
    final Color textSlate900 = AppColors.textPrimary;
    final Color textSlate500 = AppColors.textSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            _buildHeroSection(primaryColor, textSlate900, textSlate500),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Wallet Card
                  _buildWalletCard(primaryColor),
                  const SizedBox(height: 24),

                  // Menu Sections
                  _buildMenuSection(
                    title: 'PARAMÈTRES',
                    items: [
                      _buildMenuItem(
                        icon: Icons.person_outline,
                        iconColor: const Color(0xFF3B82F6),
                        title: 'Informations personnelles',
                        onTap: () async {
                          if (widget.profile == null) return;
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfilePage(profile: widget.profile!),
                            ),
                          );
                          if (updated == true && context.mounted) {
                            widget.onRefresh?.call();
                          }
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.notifications_none,
                        iconColor: const Color(0xFFF59E0B),
                        title: 'Notifications',
                        trailing: _buildBadge('3'),
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.language,
                        iconColor: const Color(0xFF8B5CF6),
                        title: 'Langue',
                        trailing: Text(
                          'Français',
                          style: GoogleFonts.plusJakartaSans(
                            color: textSlate500,
                            fontSize: 14,
                          ),
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildMenuSection(
                    title: 'SÉCURITÉ',
                    items: [
                      _buildMenuItem(
                        icon: Icons.lock_outline,
                        iconColor: const Color(0xFFEF4444),
                        title: 'Changer le mot de passe',
                        onTap: () {},
                      ),
                      if (_isBiometricAvailable)
                        _buildMenuItem(
                          icon: Icons.fingerprint,
                          iconColor: const Color(0xFF10B981),
                          title: 'Authentification biométrique',
                          trailing: Switch(
                            value: _isBiometricEnabled,
                            onChanged: _toggleBiometric,
                            activeColor: primaryColor,
                          ),
                          onTap: () {},
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildMenuSection(
                    title: 'AIDE & SUPPORT',
                    items: [
                      _buildMenuItem(
                        icon: Icons.help_outline,
                        iconColor: const Color(0xFF6366F1),
                        title: 'Centre d\'aide',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.description_outlined,
                        iconColor: const Color(0xFF64748B),
                        title: 'Conditions d\'utilisation',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await AuthService.signOut();
                        if (!context.mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text('Se déconnecter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEE2E2),
                        foregroundColor: const Color(0xFFEF4444),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Version 2.4.0',
                    style: GoogleFonts.plusJakartaSans(
                      color: textSlate500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(Color primary, Color titleColor, Color subtitleColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Profil',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primary.withValues(alpha: 0.2), width: 4),
                  image: const DecorationImage(
                    image: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuCJQJWMzfK1-hg8ZXuj_Tw7966a9-RDqY_9rxvMG9Mf7J7eM5psGRD6oXJQdQ4mbuJ4JElXcSiYCjiUtihoImX0NeeXMMcBfqnGI93nvb-A5rWkcJYwNNL__qrVU8YhVecSZ-Gdue5FGebvwKo9TH2x0-LRQRxi4ArAWNR2hKO7ntGr23WGQOKSvNUPGxYadR0xlcB0VUoaHIWpPk4WDkreVXCGhlbFCRcqvVUZ_R-C-4gEdwu8qas2q8-L7RSB7FkThuLuLDlhiaqT'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.profile?.fullName ?? 'Utilisateur',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          Text(
            widget.profile?.phone ?? '+224 000 00 00 00',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard(Color primary) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, const Color(0xFF0D9D0D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Solde Portefeuille',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '150.000 GNF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(0, 36), // override global infinity width
              ),
              child: Text(
                'Détails',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF94A3B8),
              letterSpacing: 1.0,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0F172A),
        ),
      ),
      trailing: trailing ??
          const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1), size: 20),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
