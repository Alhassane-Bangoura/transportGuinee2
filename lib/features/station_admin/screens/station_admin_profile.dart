import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/constants/app_assets.dart';
import '../../auth/login_page.dart';
import '../../profile/screens/edit_profile_page.dart';
import '../../../core/services/biometric_service.dart';

class StationAdminProfile extends StatefulWidget {
  const StationAdminProfile({super.key});

  @override
  State<StationAdminProfile> createState() => _StationAdminProfileState();
}

class _StationAdminProfileState extends State<StationAdminProfile> {
  UserProfile? _profile;
  bool _isLoading = true;
  bool _isBiometricEnabled = false;
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final response = await AuthService.getCurrentProfile();
    final available = await BiometricService.isAvailable();
    final enabled = await BiometricService.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _profile = response.data;
        _isLoading = false;
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final Color primaryColor = AppColors.primary;
    final Color backgroundColor = AppColors.background;
    final Color textSlate900 = AppColors.textPrimary;
    final Color textSlate500 = AppColors.textSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(primaryColor, textSlate900),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                children: [
                  _buildProfileCard(primaryColor, textSlate900, textSlate500),
                  const SizedBox(height: 24),
                  _buildContactCards(primaryColor, textSlate900, textSlate500),
                  const SizedBox(height: 32),
                  _buildManagementSection(primaryColor, textSlate900),
                  const SizedBox(height: 32),
                  _buildSettingsSection(primaryColor, textSlate900, textSlate500),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color primary, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: primary.withValues(alpha: 0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back)),
          Text(
            "Profil de l'Admin",
            style: GoogleFonts.plusJakartaSans(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings, color: Color(0xFF16A249))),
        ],
      ),
    );
  }

  Widget _buildProfileCard(Color primary, Color textColor, Color subColor) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: primary.withValues(alpha: 0.2), width: 4),
            image: const DecorationImage(
              image: const NetworkImage(AppAssets.stationAdminProfileBackground),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _profile?.fullName ?? 'Admin',
          style: GoogleFonts.plusJakartaSans(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, color: primary, size: 16),
            const SizedBox(width: 4),
            Text(
              '${_profile?.metadata?['station_name'] ?? 'Ma Gare'}, ${_profile?.metadata?['city_name'] ?? 'Guinée'}',
              style: GoogleFonts.plusJakartaSans(
                color: primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          _profile?.email ?? 'Pas d\'email',
          style: GoogleFonts.plusJakartaSans(
            color: subColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildContactCards(Color primary, Color textColor, Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildQuickCard('ID EMPLOYÉ', _profile?.metadata?['employee_id'] ?? 'N/A', primary, textColor, subColor),
          const SizedBox(width: 12),
          _buildQuickCard('TÉLÉPHONE', _profile?.phone ?? '+224 -- -- --', primary, textColor, subColor),
        ],
      ),
    );
  }

  Widget _buildQuickCard(String label, String value, Color primary, Color textColor, Color subColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: GoogleFonts.plusJakartaSans(color: subColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.plusJakartaSans(color: textColor, fontSize: 13, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementSection(Color primary, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gestion du Syndicat',
                style: GoogleFonts.plusJakartaSans(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '124 Chauffeurs',
                  style: GoogleFonts.plusJakartaSans(
                    color: primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildManageButton('Ajouter', Icons.person_add, primary),
              _buildManageButton('Chauffeurs', Icons.group, primary),
              _buildManageButton('Modifier', Icons.edit_square, primary),
              _buildManageButton('Supprimer', Icons.delete, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManageButton(String label, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF64748B).withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF0F172A),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(Color primary, Color textColor, Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paramètres',
            style: GoogleFonts.plusJakartaSans(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingsItem('Informations personnelles', 'Mettre à jour vos détails', Icons.person, primary, subColor, textColor, onTap: () async {
            if (_profile == null) return;
            final updated = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditProfilePage(profile: _profile!)),
            );
            if (updated == true) {
              _loadProfile();
            }
          }),
          const SizedBox(height: 12),
          _buildSettingsItem('Notifications', 'Gérer vos alertes et rappels', Icons.notifications_active, primary, subColor, textColor),
          const SizedBox(height: 12),
          if (_isBiometricAvailable) ...[
            _buildBiometricToggle(primary, subColor, textColor),
            const SizedBox(height: 12),
          ],
          _buildSettingsItem('Sécurité', 'Mot de passe et authentification', Icons.security, primary, subColor, textColor),
          const SizedBox(height: 24),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(String title, String subtitle, IconData icon, Color primary, Color subColor, Color textColor, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF64748B).withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: primary, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.plusJakartaSans(color: textColor, fontSize: 14, fontWeight: FontWeight.bold)),
                    Text(subtitle, style: GoogleFonts.plusJakartaSans(color: subColor, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: subColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricToggle(Color primary, Color subColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF64748B).withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.fingerprint, color: primary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Authentification biométrique',
                      style: GoogleFonts.plusJakartaSans(
                          color: textColor, fontSize: 14, fontWeight: FontWeight.bold)),
                  Text('Utiliser votre empreinte pour vous connecter',
                      style: GoogleFonts.plusJakartaSans(color: subColor, fontSize: 12)),
                ],
              ),
            ),
            Switch(
              value: _isBiometricEnabled,
              onChanged: _toggleBiometric,
              activeColor: primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
      ),
        child: InkWell(
          onTap: () async {
            await AuthService.signOut();
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              const Icon(Icons.logout, color: Colors.red, size: 20),
              const SizedBox(width: 12),
              Text(
                'Déconnexion',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
    );
  }
}
