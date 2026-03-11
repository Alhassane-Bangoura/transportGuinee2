import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'passenger_tickets.dart';
import 'passenger_trips.dart';
import 'passenger_profile.dart';
import '../../core/models/user_profile.dart';
import '../../core/services/auth_service.dart';

class PassengerDashboard extends StatefulWidget {
  final UserProfile? profile;
  const PassengerDashboard({super.key, this.profile});

  @override
  State<PassengerDashboard> createState() => _PassengerDashboardState();
}

class _PassengerDashboardState extends State<PassengerDashboard> {
  int _selectedIndex = 0;
  UserProfile? _profile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    if (widget.profile != null) {
      _profile = widget.profile;
      _isLoadingProfile = false;
    } else {
      _loadProfile();
    }
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
          child: CircularProgressIndicator(color: Color(0xFF0FBD0F)),
        ),
      );
    }
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    const Color textSlate400 = Color(0xFF94A3B8);

    final List<Widget> pages = [
      PassengerHomeContent(profile: _profile),
      const PassengerTickets(),
      const PassengerTrips(),
      PassengerProfile(profile: _profile),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: _buildBottomNav(primaryColor, textSlate400),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBottomNav(Color primary, Color inactiveColor) {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
              Icons.home_filled, 'Accueil', 0, primary, inactiveColor),
          _buildNavItem(
              Icons.confirmation_number, 'Billets', 1, primary, inactiveColor),
          _buildNavItem(Icons.route, 'Trajets', 2, primary, inactiveColor),
          _buildNavItem(Icons.person, 'Profil', 3, primary, inactiveColor),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, int index, Color primary, Color inactive) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? primary : inactive, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: isActive ? primary : inactive,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PassengerHomeContent extends StatelessWidget {
  final UserProfile? profile;
  const PassengerHomeContent({super.key, this.profile});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0FBD0F);
    const Color accentColor = Color(0xFFF59E0B);
    const Color textSlate900 = Color(0xFF0F172A);
    const Color textSlate500 = Color(0xFF64748B);
    const Color textSlate400 = Color(0xFF94A3B8);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _buildHeader(primaryColor, textSlate900, textSlate500),

          // Quick Search Section
          _buildQuickSearch(
              primaryColor, accentColor, textSlate400, textSlate500),

          // Prochain voyage Section
          _buildNextTrip(primaryColor, accentColor, textSlate900),

          // Accès Rapide Billet
          _buildQRPreview(primaryColor, textSlate900, textSlate500),

          // Historique Section
          _buildHistory(primaryColor, accentColor, textSlate900, textSlate500),

          // Wallet Section
          _buildWallet(primaryColor, textSlate900, textSlate500),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader(Color primary, Color titleColor, Color subtitleColor) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 60, bottom: 20),
      decoration: const BoxDecoration(
        color: Color(0xFFF6F8F6),
        border: Border(bottom: BorderSide(color: Color(0x1A0FBD0F))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x330FBD0F), width: 2),
                  image: const DecorationImage(
                    image: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAOwh4TP7z-10u-NPZ6kttlxfqQL43_oXTuU_HARTERhktjrg56O4ScMqp2Lq8FSC-iuiIpHP6JAF4FQirliWiCrw7X--mSCIangvdcUzjKYGw8C3wJmat4NESUADyuLp8Lxx_fnRE-94IXjvjlfKdT0zNbeMZzgpryGYrlX-DV4pvtFmtgq5_Evxc3-YGom3qxh5wLW2f48LpjLZ8pQgxZW5YQUicggx4sBST80TwYp5xPcwN14L0ELC_RfBW9LfXbJET7eteyih22'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.fullName ?? 'Utilisateur',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: primary, size: 14),
                      Text(
                        ' Conakry, Guinée',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: [
                Icon(Icons.notifications, color: primary, size: 24),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: const Color(0xFFF6F8F6), width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSearch(
      Color primary, Color accent, Color labelColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RECHERCHE RAPIDE',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF94A3B8),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            _buildSearchInput(Icons.trip_origin, 'Départ (ex: Conakry)',
                const Color(0x0F0FBD0F), primary),
            const SizedBox(height: 12),
            _buildSearchInput(Icons.location_on, 'Destination (ex: Mamou)',
                const Color(0x0F0FBD0F), accent),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSearchInput(Icons.calendar_month, 'Date',
                      const Color(0x0F0FBD0F), const Color(0xFF94A3B8)),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 48,
                  width: 60,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchInput(
      IconData icon, String hint, Color bgColor, Color iconColor) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Text(
            hint,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextTrip(Color primary, Color accent, Color titleColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prochain voyage',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              Text(
                'Voir tout',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, const Color(0xFF047857)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTripPoint('Départ', 'Conakry', 'Gare de Bambeto'),
                    Column(
                      children: [
                        const Icon(Icons.directions_bus,
                            color: Color(0xFFF59E0B), size: 24),
                        const SizedBox(height: 4),
                        Container(
                            width: 48,
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.3)),
                      ],
                    ),
                    _buildTripPoint('Arrivée', 'Mamou', 'Centre Ville',
                        isRight: true),
                  ],
                ),
                const SizedBox(height: 16),
                Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildTripInfo('DATE & HEURE', '24 Oct, 08:30'),
                        const SizedBox(width: 20),
                        _buildTripInfo('SIÈGE', 'B12'),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.confirmation_number,
                              color: primary, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Voir billet',
                            style: GoogleFonts.plusJakartaSans(
                              color: primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
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

  Widget _buildTripPoint(String label, String city, String sub,
      {bool isRight = false}) {
    return Column(
      crossAxisAlignment:
          isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          city,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Text(
          sub,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
        ),
      ],
    );
  }

  Widget _buildTripInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500)),
        Text(value,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildQRPreview(Color primary, Color titleColor, Color subtitleColor) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: primary.withValues(alpha: 0.1),
              width: 2,
              style: BorderStyle.solid),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.qr_code_2,
                  color: Color(0xFF94A3B8), size: 40),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Accès Rapide Billet',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: titleColor)),
                  Text(
                      'Scannez ce code à l\'embarquement pour gagner du temps.',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, color: subtitleColor)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: primary),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory(
      Color primary, Color accent, Color titleColor, Color subtitleColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Historique',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: titleColor)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('3 Voyages ce mois',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: accent,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildHistoryItem('Conakry → Labé', '12 Oct 2023 • Terminé',
              '85 000 GNF', primary, accent, 4),
          const SizedBox(height: 12),
          _buildHistoryItem('Kankan → Conakry', '05 Oct 2023 • Terminé',
              '120 000 GNF', primary, accent, 5),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.receipt_long, size: 18),
              label: const Text('Mes voyages'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: BorderSide(color: primary.withValues(alpha: 0.2)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String route, String date, String price,
      Color primary, Color accent, int rating) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.history, color: primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(route,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, fontWeight: FontWeight.bold)),
                Text(date,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 10, color: const Color(0xFF94A3B8))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: List.generate(
                    5,
                    (index) => Icon(Icons.star,
                        size: 12,
                        color:
                            index < rating ? accent : const Color(0xFFCBD5E1))),
              ),
              Text(price,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWallet(Color primary, Color titleColor, Color subtitleColor) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet,
                        color: primary, size: 20),
                    const SizedBox(width: 8),
                    Text('Solde Portefeuille',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: primary.withValues(alpha: 0.3))),
                  child: Text('Recharger',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: primary,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '245 000 ',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'GNF',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      color: primary,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Utilisez votre solde pour des réservations instantanées.',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 10, color: const Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }
}
