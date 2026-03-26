import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class DriverPassengersPage extends StatefulWidget {
  const DriverPassengersPage({super.key});

  @override
  State<DriverPassengersPage> createState() => _DriverPassengersPageState();
}

class _DriverPassengersPageState extends State<DriverPassengersPage> {
  final List<Map<String, dynamic>> _passengers = [
    {
      'name': 'Mamadou Diallo',
      'initials': 'MD',
      'seat': 'A4',
      'status': 'Confirmé',
      'present': true,
    },
    {
      'name': 'Aminata Camara',
      'initials': 'AC',
      'seat': 'B12',
      'status': 'Confirmé',
      'present': false,
    },
    {
      'name': 'Ibrahima Barry',
      'initials': 'IB',
      'seat': 'C2',
      'status': 'En attente',
      'present': false,
      'isWaiting': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = AppColors.success;
    final Color backgroundColor = AppColors.background;
    final Color textSlate900 = AppColors.textPrimary;
    final Color textSlate500 = AppColors.textSecondary;

    int total = _passengers.length;
    int presents = _passengers.where((p) => p['present'] == true).length;
    int absents = total - presents;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(textSlate900, textSlate500),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 120),
                    children: [
                      _buildTripSummaryCard(primaryColor, textSlate900, textSlate500),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                        child: Text(
                          "LISTE D'APPEL",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: textSlate500,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      ..._passengers.map((p) => _buildPassengerCard(p, primaryColor, textSlate900, textSlate500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildStatsFooter(total, presents, absents, primaryColor),
        ],
      ),
    );
  }

  Widget _buildHeader(Color textColor, Color subColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.arrow_back, color: textColor),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shadowColor: Colors.black.withValues(alpha: 0.1),
              elevation: 2,
              shape: const CircleBorder(),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Passagers',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                'Gérer les passagers du trajet',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: subColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripSummaryCard(Color primary, Color textColor, Color subColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'EN COURS',
                    style: GoogleFonts.plusJakartaSans(
                      color: primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Conakry → Kankan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildIconLabel(Icons.schedule, '08:30', subColor),
                    const SizedBox(width: 16),
                    _buildIconLabel(Icons.group, '12 Passagers', subColor),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              image: const DecorationImage(
                image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCNJAPTs_6Wyzig5-FicWV0sdTWPTlUGjZB_U7soDcL2zx7dhauYtTKMLnxCE9IYnrmd_k3MsUK5pckajYAr2Em3Tc3J63V_tr2lw7pOa83qL3LLte57hz2-8nvM-KCYOaj8MelzAZNjXR3GqrGOAe24Pavo6HKIzmlMVjGeTvDLK8EqX__cKLMSvrMZwiovdRxi1Ueo3ryo_SqRp742dI4mlBedbCEutS_GS-IvPbOwAzacYZrEE4Y9dEfaKN8DoTlt7xzTkIZM9XT'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconLabel(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPassengerCard(Map<String, dynamic> p, Color primary, Color textColor, Color subColor) {
    bool isWaiting = p['isWaiting'] ?? false;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  p['initials'],
                  style: GoogleFonts.plusJakartaSans(
                    color: isWaiting ? const Color(0xFF94A3B8) : primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p['name'],
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: textColor,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Siège: ${p['seat']}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: subColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(width: 4, height: 4, decoration: BoxDecoration(color: subColor.withValues(alpha: 0.3), shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(
                          p['status'],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: isWaiting ? const Color(0xFF94A3B8) : primary,
                            fontWeight: FontWeight.w600,
                            fontStyle: isWaiting ? FontStyle.italic : FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Switch(
                value: p['present'],
                onChanged: (val) => setState(() => p['present'] = val),
                activeThumbColor: Colors.white,
                activeTrackColor: primary,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFE2E8F0),
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF8FAFC)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(Icons.confirmation_number_outlined, size: 14, color: primary),
                    const SizedBox(width: 4),
                    Text(
                      'Voir le ticket',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                p['present'] ? 'Présent' : 'Absent',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsFooter(int total, int presents, int absents, Color primary) {
    return Positioned(
      bottom: 100,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Total', total.toString(), Colors.white),
            Container(width: 1, height: 32, color: const Color(0xFF334155)),
            _buildStatItem('Présents', presents.toString(), primary),
            Container(width: 1, height: 32, color: const Color(0xFF334155)),
            _buildStatItem('Absents', absents.toString(), const Color(0xFFF87171)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: const Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
