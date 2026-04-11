import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class DriverSecurityScreen extends StatefulWidget {
  const DriverSecurityScreen({super.key});

  @override
  State<DriverSecurityScreen> createState() => _DriverSecurityScreenState();
}

class _DriverSecurityScreenState extends State<DriverSecurityScreen> {
  bool _twoFactorEnabled = false;
  bool _faceIdEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Sécurité du Compte',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSecurityList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildActionItem(
            icon: Icons.lock_outline_rounded,
            title: 'Changer le mot de passe',
            subtitle: 'Dernière modification : il y a 3 mois',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 60, color: AppColors.border),
          _buildSwitchItem(
            icon: Icons.shield_outlined,
            title: 'Authentification à deux facteurs',
            subtitle: 'Protégez votre compte avec un code SMS',
            value: _twoFactorEnabled,
            onChanged: (val) => setState(() => _twoFactorEnabled = val),
          ),
          const Divider(height: 1, indent: 60, color: AppColors.border),
          _buildSwitchItem(
            icon: Icons.fingerprint_rounded,
            title: 'Biométrie (Face ID / Touche ID)',
            subtitle: 'Connexion rapide et sécurisée',
            value: _faceIdEnabled,
            onChanged: (val) => setState(() => _faceIdEnabled = val),
          ),
          const Divider(height: 1, indent: 60, color: AppColors.border),
          _buildActionItem(
            icon: Icons.history_rounded,
            title: 'Sessions actives',
            subtitle: 'Voir les appareils connectés',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.all(16),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
      title: Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged, activeColor: AppColors.primary),
        ],
      ),
    );
  }
}
