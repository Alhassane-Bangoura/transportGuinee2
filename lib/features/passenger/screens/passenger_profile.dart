import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';
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

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Choisir la langue', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Français', style: TextStyle(color: AppColors.primary)),
              trailing: Icon(Icons.check, color: AppColors.primary),
            ),
            ListTile(
              title: Text('English', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Traduction en cours de développement.')));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPasswordDialog() {
    final tc = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Mot de passe', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
        content: TextField(
          controller: tc,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'Nouveau mot de passe', hintStyle: TextStyle(color: Colors.grey)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (tc.text.isNotEmpty) {
                try {
                  await Supabase.instance.client.auth.updateUser(UserAttributes(password: tc.text));
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mot de passe mis à jour avec succès!')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur inattendue.')));
                  }
                }
              }
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void _showTopUpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Recharger (Simulation)', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
        content: const Text('Le rechargement via Orange Money/MTN MoMo est désactivé en mode simulation.', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Compris')),
        ],
      ),
    );
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
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (context) => Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                                  const SizedBox(height: 24),
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(color: const Color(0xFFF59E0B).withValues(alpha: 0.1), shape: BoxShape.circle),
                                    child: const Icon(Icons.notifications_off_outlined, color: Color(0xFFF59E0B), size: 48),
                                  ),
                                  const SizedBox(height: 24),
                                  Text('Aucune notification', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Vous êtes à jour ! Vos alertes de trajets, paiements et messages de votre gare s\'afficheront ici.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                                  ),
                                  const SizedBox(height: 32),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                      child: Text('Fermer', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
                        onTap: _showLanguageDialog,
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
                        onTap: _showPasswordDialog,
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
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppColors.surface,
                              title: const Text('Centre d\'aide', style: TextStyle(color: Colors.white)),
                              content: const Text('Notre centre d\'aide est actuellement disponible au +224 600 00 00 00.', style: TextStyle(color: Colors.white70)),
                              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer'))],
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.description_outlined,
                        iconColor: const Color(0xFF64748B),
                        title: 'Conditions d\'utilisation',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppColors.surface,
                              title: const Text('Conditions d\'utilisation', style: TextStyle(color: Colors.white)),
                              content: const Text('Vos conditions d\'utilisation sont en cours de rédaction juridique.', style: TextStyle(color: Colors.white70)),
                              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer'))],
                            ),
                          );
                        },
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
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
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
                        AppAssets.profileHeaderBackground),
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
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        image: DecorationImage(
          image: const NetworkImage(AppAssets.patternCubes),
          opacity: 0.1,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Solde Portefeuille',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '150.000 GNF',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _showTopUpDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Recharger',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('L\'historique de transactions est vide.')));
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Historique',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
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
              color: AppColors.textSecondary,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
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
          color: AppColors.textPrimary,
        ),
      ),
      trailing: trailing ??
          Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
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
