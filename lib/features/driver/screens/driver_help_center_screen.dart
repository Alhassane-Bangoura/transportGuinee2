import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class DriverHelpCenterScreen extends StatelessWidget {
  const DriverHelpCenterScreen({super.key});

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
          'Centre d\'aide',
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
            _buildContactCard(),
            const SizedBox(height: 24),
            _buildFaqSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.headset_mic_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            'Besoin d\'assistance ?',
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5),
          ),
          const SizedBox(height: 10),
          Text(
            'Notre équipe d\'experts est disponible 24h/24 pour garantir votre sécurité.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white.withOpacity(0.7), fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _buildContactButton(
                  icon: Icons.phone_forwarded_rounded,
                  label: 'Appeler',
                  color: Colors.white,
                  textColor: AppColors.primary,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildContactButton(
                  icon: Icons.forum_rounded,
                  label: 'Chatter',
                  color: Colors.white.withOpacity(0.15),
                  textColor: Colors.white,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({required IconData icon, required String label, required Color color, required Color textColor, required VoidCallback onTap}) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 10),
              Text(label, style: GoogleFonts.plusJakartaSans(color: textColor, fontWeight: FontWeight.w800, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 4, height: 16, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 10),
            Text(
              'QUESTIONS FRÉQUENTES',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 1.5),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildFaqItem(
          'Comment valider mes documents ?', 
          'Importez une photo claire de votre permis, carte grise et assurance dans la section "Documents". Notre équipe les vérifiera sous 24h.'
        ),
        _buildFaqItem(
          'Oubli de mot de passe ?', 
          'Cliquez sur "Mot de passe oublié" sur l\'écran de connexion pour recevoir un lien de réinitialisation par email.'
        ),
        _buildFaqItem(
          'Comment modifier mon trajet ?', 
          'Allez dans l\'onglet "Trajets", sélectionnez le trajet concerné et cliquez sur les options (trois points) pour modifier les détails.'
        ),
        _buildFaqItem(
          'Problème technique sur l\'assistant IA ?', 
          'Redémarrez l\'application ou videz le cache. Si le problème persiste, utilisez le bouton "Chatter" pour une aide immédiate.'
        ),
      ],
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textSecondary,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(question, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(
                answer,
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
