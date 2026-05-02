import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class DriverHelpSupportScreen extends StatelessWidget {
  const DriverHelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Aide & Support', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Comment pouvons-nous vous aider ?',
            style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Trouvez des réponses à vos questions ou contactez l\'assistance en direct.',
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          _buildItem(Icons.headset_mic_outlined, 'Contacter le support client', 'Discutez avec notre équipe 24/7', () {}),
          _buildItem(Icons.menu_book_outlined, 'Guide d\'utilisation', 'Comment publier et gérer vos trajets', () {}),
          _buildItem(Icons.help_outline_rounded, 'Foire aux Questions', 'Questions fréquemment posées', () {}),
          _buildItem(Icons.warning_amber_rounded, 'Signaler un problème', 'Problème avec un passager ou un trajet ?', () {}),
          
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Text('Guinée Transport', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                Text('Version 1.0.0', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textHint)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        title: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 15)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 12)),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary, size: 14),
        ),
      ),
    );
  }
}
