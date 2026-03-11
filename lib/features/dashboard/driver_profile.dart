import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverProfilePage extends StatelessWidget {
  const DriverProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF16A34A);
    const Color backgroundColor = Color(0xFFF6F8F6);
    const Color textSlate900 = Color(0xFF0F172A);
    const Color textSlate500 = Color(0xFF64748B);
    const Color textSlate400 = Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            children: [
              _buildHeader(textSlate900),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildDriverCard(primaryColor, textSlate900, textSlate500),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Informations personnelles'),
                    const SizedBox(height: 12),
                    _buildPersonalInfoList(primaryColor, textSlate900, textSlate400),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Mon Véhicule'),
                    const SizedBox(height: 12),
                    _buildVehicleCard(textSlate900, textSlate500),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Documents'),
                    const SizedBox(height: 12),
                    _buildDocumentsList(textSlate900, textSlate400),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Paramètres du compte'),
                    const SizedBox(height: 12),
                    _buildSettingsList(textSlate900, textSlate400),
                    const SizedBox(height: 32),
                    _buildLogoutButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Profil',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.settings_outlined, color: Color(0xFF475569)),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(Color primary, Color textColor, Color subColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primary.withValues(alpha: 0.2), width: 4),
                  image: const DecorationImage(
                    image: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDxKIVW39uOtjCNB1YK819pchfOjkMs6IE9C6Iw0X1OYHHbV93UuQUpzOP7THVT2IFxJ1NVf8b7UUUlGmXLgTYgx6KloCtAZWasjALzZn_lk5oStYOxzg1WhlF6N24jyLk048iaw6bKZH0ww0_dPEuyQUrBxBWhP83tv46JvDu9t_paG9LTqHqb-1psNz24q8WPZM0DyAZEesuZh3p0XhPzYHpPkiu7IHql1j3RIb_RSrtwyRUzBG86Og6PGb_okXfLmnZ6jWozAGPk'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.verified, color: Colors.white, size: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Moussa Camara',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            'Conakry, Guinée',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: subColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Syndicat National de Guinée',
              style: GoogleFonts.plusJakartaSans(
                color: primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Modifier le profil',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF64748B),
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoList(Color primary, Color textColor, Color stale400) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          _buildInfoItem(Icons.call_outlined, 'Téléphone', '+224 621 00 00 00', primary, stale400, textColor),
          const Divider(height: 1, color: Color(0xFFF8FAFC)),
          _buildInfoItem(Icons.mail_outline_rounded, 'Email', 'm.camara@guineetransport.gn', primary, stale400, textColor),
          const Divider(height: 1, color: Color(0xFFF8FAFC)),
          _buildInfoItem(Icons.location_on_outlined, 'Ville de résidence', 'Conakry, Matam', primary, stale400, textColor),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, Color primary, Color labelColor, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(fontSize: 10, color: labelColor, fontWeight: FontWeight.w500),
                ),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, color: valueColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1), size: 20),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(Color textColor, Color subColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuB-2cyMjmn4HPc61W0FqxcbToO8r7W2FbeGLHVY76hJD_IwQr80x7BO_UQA-wq_LGbqrSezLx5r0PLu1aMhLR7Fj3oMSiep3feeB1p1FMfDdL4D6CmsqA_YJEQEQ6YUEMaK-PyC3RK49Guqt8pGJ8LZucotVvRFYIG3wzWLSDJT3j7O2cpy1ZfkHng5Cscl-pX-yBuk_HykpU9KxS68n2f0_7S3IDSnMbSus_4rkIAgsHb2rk8UdvKObxBb1DeFPHxHhjzCvkkeIpn4'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Toyota Hiace',
                  style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                ),
                Text(
                  'Minibus • 15 places',
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, color: subColor),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    'RC-1234-A',
                    style: GoogleFonts.robotoMono(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF334155)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList(Color textColor, Color stale400) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          _buildDocItem(Icons.assignment_ind_outlined, 'Permis de conduire', 'VÉRIFIÉ', const Color(0xFF10B981), const Color(0xFFECFDF5), stale400, textColor),
          const Divider(height: 1, color: Color(0xFFF8FAFC)),
          _buildDocItem(Icons.verified_user_outlined, 'Assurance véhicule', 'EN ATTENTE', const Color(0xFFF59E0B), const Color(0xFFFFFBEB), stale400, textColor),
          const Divider(height: 1, color: Color(0xFFF8FAFC)),
          _buildDocItem(Icons.directions_car_outlined, 'Carte technique', 'EXPIRÉ', const Color(0xFFEF4444), const Color(0xFFFEF2F2), stale400, textColor),
        ],
      ),
    );
  }

  Widget _buildDocItem(IconData icon, String title, String status, Color statusColor, Color statusBg, Color iconColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: iconColor.withValues(alpha: 0.6), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: GoogleFonts.plusJakartaSans(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList(Color textColor, Color stale400) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          _buildSettingsItem(Icons.lock_outline_rounded, 'Modifier le mot de passe', textColor, stale400),
          const Divider(height: 1, color: Color(0xFFF8FAFC)),
          _buildSettingsItem(Icons.language_rounded, 'Langue', textColor, stale400, trailing: 'Français'),
          const Divider(height: 1, color: Color(0xFFF8FAFC)),
          _buildSettingsItem(Icons.notifications_none_rounded, 'Notifications', textColor, stale400),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, Color textColor, Color stale400, {String? trailing}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: stale400, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
            ),
          ),
          if (trailing != null)
            Text(
              trailing,
              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: stale400, fontWeight: FontWeight.w500),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1), size: 20),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4E6).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECDD3).withValues(alpha: 0.5)),
      ),
      child: TextButton(
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: Color(0xFFE11D48)),
            const SizedBox(width: 12),
            Text(
              'Se déconnecter',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFE11D48),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
