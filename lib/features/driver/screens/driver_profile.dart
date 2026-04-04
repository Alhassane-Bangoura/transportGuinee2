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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'MON PROFIL',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'ÉDITER',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        child: Column(
          children: [
            _buildDriverSummary(),
            const SizedBox(height: 32),
            _buildStatsGrid(),
            const SizedBox(height: 32),
            _buildSectionHeader('Informations personnelles'),
            const SizedBox(height: 16),
            _buildPersonalInfoList(),
            const SizedBox(height: 32),
            _buildSectionHeader('Mon Véhicule'),
            const SizedBox(height: 16),
            _buildVehicleCard(),
            const SizedBox(height: 32),
            _buildSectionHeader('Documents officiels'),
            const SizedBox(height: 16),
            _buildDocumentsList(),
            const SizedBox(height: 32),
            _buildSectionHeader('Paramètres & Sécurité'),
            const SizedBox(height: 16),
            _buildSettingsList(),
            const SizedBox(height: 48),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverSummary() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(widget.profile?.metadata?['avatar_url'] ?? 'https://ui-avatars.com/api/?name=${widget.profile?.fullName ?? "Driver"}&background=1A3D75&color=fff&size=128'),
                backgroundColor: AppColors.primary,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
              child: const Icon(Icons.verified_rounded, color: Colors.white, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.profile?.fullName ?? 'Moussa Camara',
          style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          'Chauffeur Principal • Station Conakry',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        _buildStatItem('Trajets', '1,284', Icons.route_rounded),
        const SizedBox(width: 12),
        _buildStatItem('Note', '4.9', Icons.star_rounded, iconColor: Colors.amber),
        const SizedBox(width: 12),
        _buildStatItem('Exp.', '5 ans', Icons.emoji_events_rounded, iconColor: AppColors.success),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {Color? iconColor}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor ?? AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ],
        ),
      ),
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
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildPersonalInfoList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface, 
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: AppColors.border)
      ),
      child: Column(
        children: [
          _buildInfoItem(Icons.phone_outlined, 'Téléphone', widget.profile?.phone ?? '+224 000 00 00 00'),
          const Divider(height: 1, indent: 60, color: AppColors.border),
          _buildInfoItem(Icons.email_outlined, 'Email', widget.profile?.email ?? 'chauffeur@transport.gn'),
          const Divider(height: 1, indent: 60, color: AppColors.border),
          _buildInfoItem(Icons.badge_outlined, 'Permis', widget.profile?.metadata?['license_number'] ?? 'G-PRM-XXXXXX'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface, 
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: AppColors.border)
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&q=80&w=200'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mercedes Sprinter', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                Text('Bus VIP • 18 places', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text('RC-1294-B', style: GoogleFonts.robotoMono(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 1)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface, 
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: AppColors.border)
      ),
      child: Column(
        children: [
          _buildDocItem(Icons.assignment_ind_rounded, 'Permis de conduire', 'VALIDE', AppColors.success),
          const Divider(height: 1, indent: 60, color: AppColors.border),
          _buildDocItem(Icons.verified_user_rounded, 'Assurance véhicule', 'À RENOUVELER', Colors.orange),
          const Divider(height: 1, indent: 60, color: AppColors.border),
          _buildDocItem(Icons.description_rounded, 'Carte grise', 'VALIDE', AppColors.success),
        ],
      ),
    );
  }

  Widget _buildDocItem(IconData icon, String title, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary.withValues(alpha: 0.5), size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: GoogleFonts.plusJakartaSans(color: statusColor, fontSize: 9, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface, 
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: AppColors.border)
      ),
      child: Column(
        children: [
          _buildSettingsItem(Icons.lock_rounded, 'Sécurité du compte'),
          const Divider(height: 1, indent: 60, color: AppColors.border),
          if (_isBiometricAvailable) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
              child: Row(
                children: [
                  const Icon(Icons.fingerprint_rounded, color: AppColors.textSecondary, size: 24),
                  const SizedBox(width: 16),
                  Expanded(child: Text('Authentification biométrique', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                  Switch.adaptive(value: _isBiometricEnabled, onChanged: _toggleBiometric, activeColor: AppColors.primary),
                ],
              ),
            ),
            const Divider(height: 1, indent: 60, color: AppColors.border),
          ],
          _buildSettingsItem(Icons.help_outline_rounded, 'Centre d\'aide'),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary.withValues(alpha: 0.5), size: 24),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
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
            const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
            const SizedBox(width: 12),
            Text('DECONNEXION', style: GoogleFonts.plusJakartaSans(color: AppColors.error, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }
}
