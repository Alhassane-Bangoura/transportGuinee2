import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StationAdminProfile extends StatelessWidget {
  const StationAdminProfile({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF16A249);
    const Color backgroundColor = Color(0xFFF6F8F7);
    const Color textSlate900 = Color(0xFF0F172A);
    const Color textSlate500 = Color(0xFF64748B);

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
              image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAPz5kPAOQ-Kku67HOnYMU6ZECyikIkfz0cmvnb6J2ijIVVj44tFo0NlIge7PUHDIZmNv_K4c3NtBv37XEAnC11yzJAbGxhyofJaYonRFgWGHMrUMEXqB60Hm3ZY-0UK5KaSTSfJEywXsLGAiVYDYl0m9_8ntDb07EUj13q5maAnsYNiE_WYjvRn6wJFFyXd6QKA1VLZwJggEoDiV2EtH1JYBXKGlCAcfdPaqbzxmSOZBHKBrzjPpqH0zwysS3FazH1ES6g3s_YGSgf'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Moussa Camara',
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
              'Gare de Madina, Conakry',
              style: GoogleFonts.plusJakartaSans(
                color: primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          'm.camara@garedemadina.gn',
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
          _buildQuickCard('Email', 'm.camara@madina.gn', primary, textColor, subColor),
          const SizedBox(width: 12),
          _buildQuickCard('Téléphone', '+224 620 00 00 00', primary, textColor, subColor),
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
          _buildSettingsItem('Informations personnelles', 'Mettre à jour vos détails', Icons.person, primary, subColor, textColor),
          const SizedBox(height: 12),
          _buildSettingsItem('Notifications', 'Gérer vos alertes et rappels', Icons.notifications_active, primary, subColor, textColor),
          const SizedBox(height: 12),
          _buildSettingsItem('Sécurité', 'Mot de passe et authentification', Icons.security, primary, subColor, textColor),
          const SizedBox(height: 24),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(String title, String subtitle, IconData icon, Color primary, Color subColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF64748B).withValues(alpha: 0.1)),
      ),
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
    );
  }
}
