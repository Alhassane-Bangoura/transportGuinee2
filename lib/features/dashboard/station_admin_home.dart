import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StationAdminHome extends StatelessWidget {
  const StationAdminHome({super.key});

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsGrid(primaryColor, textSlate900, textSlate500),
                    _buildAlertsSection(primaryColor, textSlate900),
                    _buildDeparturesSection(primaryColor, textSlate900, textSlate500),
                  ],
                ),
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
        color: Colors.white.withValues(alpha: 0.8),
        border: Border(bottom: BorderSide(color: primary.withValues(alpha: 0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.directions_bus, color: primary, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gare de Madina',
                    style: GoogleFonts.plusJakartaSans(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: primary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Conakry, Guinée',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_outlined),
                    color: const Color(0xFF64748B),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: const DecorationImage(
                    image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAvDB_ZCnclzOSfIDe6vpN2xtSTiB39YHl0uuIrrzEsw5fBzXQWcZOEciUUZfHysALgLTjyBJm4RUsE2kO8caAmlv6CPV0lw6uqLYX6LZawSrmCWu-ouTl1T28W0KmHHqtivLX3gc-ktKSOQOLxbkxHXTGFWMEWLX8khlOHVYX5srJfA_78tnXVnaaMJ_OvKrqNI79tYWMeTlvpf2CqXCRjIde2c4HFt_YMc9N2DWgdycTdM8F35wysabCN-y1HYB3xkWxeE3pzCWa3'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Color primary, Color textColor, Color subColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatCard('Syndicats', '8', Icons.groups, primary, subColor, textColor),
              const SizedBox(width: 12),
              _buildStatCard('Chauffeurs', '142', Icons.badge, primary, subColor, textColor),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard('Véhicules', '45', Icons.local_shipping, primary, subColor, textColor),
              const SizedBox(width: 12),
              _buildStatCard('Départs', '32', Icons.departure_board, primary, subColor, textColor),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatCard('Passagers', '2,840', Icons.person_add, primary, subColor, textColor, isFullWidth: true),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color primary, Color subColor, Color textColor, {bool isFullWidth = false}) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primary, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: subColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    return isFullWidth ? SizedBox(width: double.infinity, child: card) : Expanded(child: card);
  }

  Widget _buildAlertsSection(Color primary, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Alertes critiques',
                    style: GoogleFonts.plusJakartaSans(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Tout voir',
                  style: GoogleFonts.plusJakartaSans(
                    color: primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildAlertItem(
            'Véhicule sans documents',
            'Toyota Hiace - RC-1234-A • Entrée refusée',
            Icons.description,
            Colors.red,
          ),
          const SizedBox(height: 12),
          _buildAlertItem(
            'Chauffeur suspendu détecté',
            'Alpha Diallo • Badge invalide au Quai 2',
            Icons.block,
            Colors.amber,
          ),
          const SizedBox(height: 12),
          _buildAlertItem(
            'Quai 4 Congestionné',
            '3 véhicules en attente de déchargement',
            Icons.traffic,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: color.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeparturesSection(Color primary, Color textColor, Color subColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prochains Départs',
            style: GoogleFonts.plusJakartaSans(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDepartureCard(
            'Labé',
            '10:30',
            'Quai N°4',
            'Confirmé',
            '85%',
            'M. Barry',
            '15/15',
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCT5Exmdh1lfaX1fH_JCWdRUr1iDlKe6an7ZXRJxw98NCYnVV8uZcG9rchSdQ7iQ2ei3jqdRM7MWkKlBKzHr3CYUC__axRjFH9invwBCNGJRN9oFgnc-vtysiMneo20kTiw425r1K-uEuSBjPyp4CtG0_6MKPku3ZxYsReTOX_mdkuwlOSHBtMx8f6JBGx1Cp95BQ4hIMtaySI-v83WPdLxVQS73uz0TP18XI3JismZuusvGnhy2goRqzPSyFjwzF-jLwGZsBCOTkJr',
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBhAXTKy1yNYhTkN8RBprqZYSp8EN643bg4m3NKaXpmfjX5Q0TEjQugs8s44F4vxZ-Kx4uCKx-9hCsZZkTGqSEEwcEhhg5feaO6xxqa2CNc8uNhqVC2bESyQFhEwpOQbwqgEXXSxnrpLpDJsH5Fln-Nn09uc1HHhRezLupHPnGkHWu8F55GPNcaGU4G8OzLBmX4jrja9DEqm-ORFT1zW-I6hEHTcWNu1av_umpORDdW8UZXqdGeZumlAW4i3HJa2l0_wvSWWu9ie8RC',
            primary,
            textColor,
            subColor,
          ),
          const SizedBox(height: 16),
          _buildDepartureCard(
            'Kankan',
            '11:45',
            'Quai N°2',
            'En retard',
            '32%',
            'A. Sylla',
            '8/25',
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDCPennKeiMqYaKrgozEqBw7DeBn5ojvgoGwJqYgDebaFFYwzFT92qtOjKb5190wfZbxSejInDakiAwfzJTVjeOQrpeND5a-hcVRKjClECHs2LXsDHHR7yEE_V1Qah74NIxLsHUs5POEQX34OLDkAWf429QJv2kU72B8yEnV560MMgWgIBrML6_HDJ_qcLTMzR_new0R5aZWuop9aPID_0m2GMG2GzKubPgcqI0O1cRvjJKe2h3F5uAISCAdLU9VfHEffbtBxZgjBwv',
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDPigSn9_CYp9nUXwBvtREnxLJgUQ8QyUfG7twqEKpduyhYZQwsT5HIv5OjpVCYAvGeF6XMoiEKYPpqUFPuFGYVQbt7go4JQ2Nm6IjZCx9MYDj_DdSYvsvAf1KtnOQX-i073Pm9APPa-XqJ7IwruPH34s5FJL6vtkkj5CkcfSVR9W5WArdkzbqIGgCdOqnBhPqPudhpykCDWxZaSZQq7LjvOLfDX6Cdf7liyMCVtsyR1F3lUsIEh6LLIKkZI5s80stEm9KskfwE1IF7',
            primary,
            textColor,
            subColor,
            isWarning: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDepartureCard(
    String city,
    String time,
    String quay,
    String status,
    String loading,
    String driver,
    String seats,
    String busImage,
    String driverImage,
    Color primary,
    Color textColor,
    Color subColor, {
    bool isWarning = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.05)),
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
          IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(busImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              city,
                              style: GoogleFonts.plusJakartaSans(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  quay,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Chargement $loading',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: subColor,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isWarning ? Colors.amber.withValues(alpha: 0.1) : primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  color: isWarning ? Colors.amber : primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.schedule, color: subColor, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              time,
                              style: GoogleFonts.plusJakartaSans(
                                color: subColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(driverImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  driver,
                  style: GoogleFonts.plusJakartaSans(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(Icons.group, color: subColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$seats Passagers',
                  style: GoogleFonts.plusJakartaSans(
                    color: subColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.more_vert, color: subColor, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
