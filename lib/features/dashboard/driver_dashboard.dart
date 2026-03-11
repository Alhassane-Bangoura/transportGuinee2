import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../core/models/user_profile.dart';
import '../../core/services/auth_service.dart';
import 'driver_trips.dart';
import 'driver_passengers.dart';
import 'driver_profile.dart';

class DriverDashboard extends StatefulWidget {
  final UserProfile? profile;
  const DriverDashboard({super.key, this.profile});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard>
    with SingleTickerProviderStateMixin {
  UserProfile? _profile;
  bool _isLoadingProfile = true;
  late AnimationController _pulseController;
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _passengers = [
    {
      'name': 'Amadou Diallo',
      'initials': 'AD',
      'seat': '04',
      'ticket': '#GT-2309',
      'checked': true
    },
    {
      'name': 'Mariama Sylla',
      'initials': 'MS',
      'seat': '07',
      'ticket': '#GT-2311',
      'checked': false
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    if (widget.profile != null) {
      _profile = widget.profile;
      _isLoadingProfile = false;
    } else {
      _loadProfile();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService.getCurrentProfile();
    if (mounted) {
      setState(() {
        _profile = profile;
        _isLoadingProfile = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF16A34A)),
        ),
      );
    }

    const Color primaryColor = Color(0xFF16A34A);
    const Color backgroundColor = Color(0xFFF6F8F6);
    const Color textSlate900 = Color(0xFF0F172A);
    const Color textSlate500 = Color(0xFF64748B);
    const Color textSlate400 = Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              _buildHomeContent(primaryColor, textSlate900, textSlate500, textSlate400),
              const DriverTripsPage(),
              const DriverPassengersPage(),
              const DriverProfilePage(),
            ],
          ),
          _buildBottomNav(primaryColor, textSlate400),
        ],
      ),
    );
  }

  Widget _buildHomeContent(Color primaryColor, Color textSlate900, Color textSlate500, Color textSlate400) {
    return CustomScrollView(
      slivers: [
        _buildSliverHeader(primaryColor, textSlate900),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildSectionHeader('Trajet du jour', trailing: 'Détails'),
              const SizedBox(height: 12),
              _buildDailyTripCard(primaryColor),
              const SizedBox(height: 24),
              _buildSectionHeader('Revenus', trailing: 'Mise à jour à 10:45'),
              const SizedBox(height: 12),
              _buildEarningsCard(primaryColor, textSlate900, textSlate500, textSlate400),
              const SizedBox(height: 24),
              _buildSectionHeader('Liste du trajet actuel', trailing: '12 Présents'),
              const SizedBox(height: 12),
              _buildPassengerList(primaryColor, textSlate900, textSlate500),
              const SizedBox(height: 24),
              _buildSectionHeader('Documents véhicule'),
              const SizedBox(height: 12),
              _buildDocumentsList(primaryColor, textSlate900),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverHeader(Color primary, Color textColor) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      expandedHeight: 80,
      toolbarHeight: 80,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primary.withValues(alpha: 0.2), width: 2),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuDxKIVW39uOtjCNB1YK819pchfOjkMs6IE9C6Iw0X1OYHHbV93UuQUpzOP7THVT2IFxJ1NVf8b7UUUlGmXLgTYgx6KloCtAZWasjALzZn_lk5oStYOxzg1WhlF6N24jyLk048iaw6bKZH0ww0_dPEuyQUrBxBWhP83tv46JvDu9t_paG9LTqHqb-1psNz24q8WPZM0DyAZEesuZh3p0XhPzYHpPkiu7IHql1j3RIb_RSrtwyRUzBG86Og6PGb_okXfLmnZ6jWozAGPk',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _profile?.fullName ?? 'Moussa Camara',
                        style: GoogleFonts.plusJakartaSans(
                            color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Conakry, Guinée',
                            style: GoogleFonts.plusJakartaSans(
                                color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Text(
                      'En ligne',
                      style: GoogleFonts.plusJakartaSans(
                        color: primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    ScaleTransition(
                      scale: Tween(begin: 0.8, end: 1.2).animate(_pulseController),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: trailing.startsWith('Mise') ? FontWeight.w500 : FontWeight.bold,
              color: trailing.startsWith('Mise') ? const Color(0xFF64748B) : const Color(0xFF16A34A),
            ),
          ),
      ],
    );
  }

  Widget _buildDailyTripCard(Color primary) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDqx3H4FO-CWIFaL0QYPCXAMkGq5weyYKPgjEq-6aGUGnOWUOKfY2EmqcT8R54WztdS8OquQ2k6SJ2IXwFAwp-tjV8dzRLxTHZtCLNqpCf-M9YQscYeLGFnbqa3cEPYsyslew6Vmo3D36WZ6fb-_jXSQqshcvozNr7XFHvcNo3HDDZJdVRP2Qs28dStUNPrNNIH2lCZwr4IzfMpng7SS4hfb-w5P9K160WDqu66bDzgfxFxVN8JCYqOaHr3pDQTNBXiXmTQV3_o2UH9',
                  height: 128,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PROCHAIN DÉPART',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Conakry → Labé',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildTripInfoItem(Icons.schedule_rounded, 'DÉPART', '08:00'),
                    const SizedBox(width: 24),
                    _buildTripInfoItem(Icons.group_rounded, 'PASSAGERS', '12 / 15'),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: primary, size: 16),
                      const SizedBox(width: 8),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF0F172A),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            const TextSpan(text: 'Statut : '),
                            TextSpan(
                              text: 'Prêt au départ',
                              style: TextStyle(color: primary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            'Démarrer trajet',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF0F172A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            'Voir passagers',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF64748B), size: 18),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF94A3B8),
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF0F172A),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEarningsCard(Color primary, Color textColor, Color subColor, Color barColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Aujourd'hui",
                style: GoogleFonts.plusJakartaSans(
                  color: subColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "450.000 GNF",
                style: GoogleFonts.plusJakartaSans(
                  color: primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Simplified Bar Chart
          SizedBox(
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(0.4, primary.withValues(alpha: 0.2)),
                _buildBar(0.6, primary.withValues(alpha: 0.2)),
                _buildBar(0.3, primary.withValues(alpha: 0.2)),
                _buildBar(0.8, primary.withValues(alpha: 0.2)),
                _buildBar(0.5, primary.withValues(alpha: 0.2)),
                _buildBar(0.9, primary.withValues(alpha: 0.2)),
                _buildBar(0.7, primary),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cette semaine',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '2.8M GNF',
                      style: GoogleFonts.plusJakartaSans(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ce mois',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '10.5M GNF',
                      style: GoogleFonts.plusJakartaSans(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double heightFactor, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          height: 60 * heightFactor,
        ),
      ),
    );
  }

  Widget _buildPassengerList(Color primary, Color textColor, Color subColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          ..._passengers.map((p) => _buildPassengerRow(p, primary, textColor, subColor)),
          InkWell(
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Voir les 10 autres',
                    style: GoogleFonts.plusJakartaSans(
                      color: primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.expand_more_rounded, color: primary, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerRow(Map<String, dynamic> p, Color primary, Color textColor, Color subColor) {
    bool isLast = _passengers.last == p;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Opacity(
        opacity: p['checked'] ? 1.0 : 0.7,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    p['initials'],
                    style: GoogleFonts.plusJakartaSans(
                      color: p['checked'] ? primary : const Color(0xFF94A3B8),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p['name'],
                      style: GoogleFonts.plusJakartaSans(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Siège ${p['seat']} • Ticket ${p['ticket']}',
                      style: GoogleFonts.plusJakartaSans(
                        color: subColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Icon(
              p['checked'] ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: p['checked'] ? primary : const Color(0xFFE2E8F0),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsList(Color primary, Color textColor) {
    return Column(
      children: [
        _buildDocumentItem(Icons.badge_outlined, 'Permis de conduire', 'VÉRIFIÉ',
            const Color(0xFFF0FDF4), const Color(0xFF166534), primary),
        const SizedBox(height: 12),
        _buildDocumentItem(Icons.description_outlined, 'Assurance véhicule', 'EN ATTENTE',
            const Color(0xFFFFF7ED), const Color(0xFF9A3412), const Color(0xFFEA580C)),
        const SizedBox(height: 12),
        _buildDocumentItem(Icons.warning_amber_rounded, 'Carte technique', 'EXPIRÉ',
            const Color(0xFFFEF2F2), const Color(0xFF991B1B), const Color(0xFFDC2626),
            hasBorder: true),
      ],
    );
  }

  Widget _buildDocumentItem(
      IconData icon, String title, String status, Color bg, Color textCol, Color iconCol,
      {bool hasBorder = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hasBorder ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconCol.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconCol, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: GoogleFonts.plusJakartaSans(
                color: textCol,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(Color primary, Color inactive) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            padding: const EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(Icons.home_rounded, 'Accueil', _currentIndex == 0, 0),
                _buildNavItem(Icons.route_rounded, 'Trajets', _currentIndex == 1, 1),
                _buildNavItem(Icons.group_rounded, 'Passagers', _currentIndex == 2, 2),
                _buildNavItem(Icons.person_rounded, 'Profil', _currentIndex == 3, 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, int index) {
    final Color color = isActive ? const Color(0xFF16A34A) : const Color(0xFF94A3B8);
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? color.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
