import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/models/user_profile.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/auth_service.dart';
import '../../auth/login_page.dart';

class DriverProfilePage extends StatefulWidget {
  final UserProfile? profile;
  final VoidCallback? onRefresh;
  const DriverProfilePage({super.key, this.profile, this.onRefresh});

  @override
  State<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
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
    final Color primaryColor = AppColors.primary;
    const Color backgroundColor = AppColors.background;
    const Color surfaceColor = AppColors.surface;
    const Color textColor = AppColors.textPrimary;
    const Color subColor = AppColors.textSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            children: [
              _buildModernHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildPremiumDriverCard(context, primaryColor, textColor, subColor),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Informations personnelles'),
                    const SizedBox(height: 16),
                    _buildPersonalInfoList(primaryColor, textColor, subColor),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Mon Véhicule'),
                    const SizedBox(height: 16),
                    _buildVehicleCard(surfaceColor, textColor, subColor),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Documents officiels'),
                    const SizedBox(height: 16),
                    _buildDocumentsList(textColor, subColor),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Paramètres & Sécurité'),
                    const SizedBox(height: 16),
                    _buildSettingsList(textColor, subColor),
                    const SizedBox(height: 48),
                    _buildLogoutButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.menu, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GUINEE TRANSPORT',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'ESPACE CHAUFFEUR',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumDriverCard(BuildContext context, Color primary, Color textColor, Color subColor) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 4),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAsIrE2r0xrBC59Uyo6nwN0KTGcLtNk0QSE3aXEW4a9w86NOIqILu5O69E4hvnIlO_f0U7dmyhoKfm8PEbq0r4nMVkzVi7g_8wQl5eufKHVCAbWW3xf2tzvSPzBdq2OIJjJC9k7csnkseroEItJNRVcqBi779mfgqEeYg39OYucrtqEvZvNvUXbIR1LrDW3HD2jUXuBmJBtFDk5JdCLTjxWQoOP2sidEE98YcB4H949vkWtxAvX9GyCF8RSUkfEZEyJ-Gh1IqW--JIL',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 5,
              right: 5,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: AppColors.surface, width: 2))),
                child: const Icon(Icons.photo_camera, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.profile?.fullName ?? 'Moussa Camara',
          style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
              child: Text('Chauffeur Vérifié', style: GoogleFonts.plusJakartaSans(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text('4.9', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary.withOpacity(0.5),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildPersonalInfoList(Color primary, Color textColor, Color subColor) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          _buildInfoItem(Icons.phone_outlined, 'Numéro de téléphone', widget.profile?.phone ?? '+224 620 00 00 00', primary, subColor, Colors.white, showEdit: true),
          const Divider(height: 1, color: AppColors.border),
          _buildInfoItem(Icons.location_on_outlined, 'Ville de résidence', widget.profile?.metadata?['city'] ?? 'Conakry, Guinée', primary, subColor, Colors.white),
          const Divider(height: 1, color: AppColors.border),
          _buildInfoItem(Icons.badge_outlined, 'Numéro de permis', widget.profile?.metadata?['license_number'] ?? 'GUI-1298374-C', primary, subColor, Colors.white),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, Color primary, Color labelColor, Color valueColor, {bool showEdit = false}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: labelColor, fontWeight: FontWeight.w600)),
                Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: valueColor, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          if (showEdit) Icon(Icons.edit_outlined, color: AppColors.textSecondary.withOpacity(0.5), size: 16),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(Color surface, Color textColor, Color subColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuB-2cyMjmn4HPc61W0FqxcbToO8r7W2FbeGLHVY76hJD_IwQr80x7BO_UQA-wq_LGbqrSezLx5r0PLu1aMhLR7Fj3oMSiep3feeB1p1FMfDdL4D6CmsqA_YJEQEQ6YUEMaK-PyC3RK49Guqt8pGJ8LZucotVvRFYIG3wzWLSDJT3j7O2cpy1ZfkHng5Cscl-pX-yBuk_HykpU9KxS68n2f0_7S3IDSnMbSus_4rkIAgsHb2rk8UdvKObxBb1DeFPHxHhjzCvkkeIpn4'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Toyota Hiace', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('Minibus • 15 places', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: subColor)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.primary.withOpacity(0.2))),
                  child: Text('RC-1234-A', style: GoogleFonts.robotoMono(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList(Color textColor, Color subColor) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          _buildDocItem(Icons.assignment_ind_outlined, 'Permis de conduire', 'VÉRIFIÉ', Colors.green),
          const Divider(height: 1, color: AppColors.border),
          _buildDocItem(Icons.verified_user_outlined, 'Assurance véhicule', 'EN ATTENTE', Colors.amber),
          const Divider(height: 1, color: AppColors.border),
          _buildDocItem(Icons.report_problem_outlined, 'Carte technique', 'EXPIRÉ', Colors.red),
        ],
      ),
    );
  }

  Widget _buildDocItem(IconData icon, String title, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary.withOpacity(0.5), size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(status, style: GoogleFonts.plusJakartaSans(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList(Color textColor, Color subColor) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          _buildSettingsItem(Icons.lock_person_outlined, 'Sécurité & Mot de passe'),
          const Divider(height: 1, color: AppColors.border),
          if (_isBiometricAvailable) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.fingerprint_rounded, color: AppColors.textSecondary, size: 24),
                  const SizedBox(width: 16),
                  Expanded(child: Text('Biométrie (Empreinte)', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
                  Switch(value: _isBiometricEnabled, onChanged: _toggleBiometric, activeColor: AppColors.primary),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
          ],
          _buildSettingsItem(Icons.help_center_outlined, 'Support Technique'),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary.withOpacity(0.5), size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
          Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary.withOpacity(0.3)),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: TextButton(
        onPressed: () async {
          await AuthService.signOut();
          if (mounted && context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: Colors.red),
            const SizedBox(width: 12),
            Text('SE DÉCONNECTER', style: GoogleFonts.plusJakartaSans(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2)),
          ],
        ),
      ),
    );
  }
}
