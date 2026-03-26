import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class DriverTripsPage extends StatefulWidget {
  const DriverTripsPage({super.key});

  @override
  State<DriverTripsPage> createState() => _DriverTripsPageState();
}

class _DriverTripsPageState extends State<DriverTripsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = AppColors.success;
    final Color backgroundColor = AppColors.background;
    final Color textSlate900 = AppColors.textPrimary;
    final Color textSlate500 = AppColors.textSecondary;
    final Color textSlate400 = AppColors.textHint;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(textSlate900, textSlate500),
            _buildTabs(primaryColor, textSlate500),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTripsList(primaryColor, textSlate900, textSlate500, textSlate400),
                  const Center(child: Text('Prochains trajets')),
                  const Center(child: Text('Historique')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color textColor, Color subColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back, color: textColor),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Mes trajets',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              'Gérer et consulter vos trajets en temps réel',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: subColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(Color primary, Color subColor) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x1A16A34A))),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: primary,
        unselectedLabelColor: subColor,
        indicatorColor: primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        tabs: const [
          Tab(text: "Trajets du jour"),
          Tab(text: "Prochains trajets"),
          Tab(text: "Historique"),
        ],
      ),
    );
  }

  Widget _buildTripsList(Color primary, Color textColor, Color subColor, Color slate400) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildActiveTripCard(primary, textColor, subColor),
        const SizedBox(height: 16),
        _buildFutureTripCard(
          id: '#GT-3102',
          route: 'Mamou → Labé',
          time: 'Demain • 07:00',
          passengers: '08/15',
          primary: primary,
          textColor: textColor,
          subColor: subColor,
        ),
        const SizedBox(height: 16),
        _buildFutureTripCard(
          id: '#GT-3105',
          route: 'Conakry → Boké',
          time: 'Mercredi 24 Oct • 09:30',
          passengers: '02/15',
          primary: primary,
          textColor: textColor,
          subColor: subColor,
          isPlaceholder: true,
        ),
      ],
    );
  }

  Widget _buildActiveTripCard(Color primary, Color textColor, Color subColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.1)),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPulseDot(primary),
                      const SizedBox(width: 6),
                      Text(
                        'EN COURS',
                        style: GoogleFonts.plusJakartaSans(
                          color: primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'ID: #GT-2849',
                  style: GoogleFonts.plusJakartaSans(
                    color: subColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF8FAFC)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Icon(Icons.radio_button_checked, color: primary, size: 20),
                        Container(width: 1, height: 32, color: const Color(0xFFF1F5F9)),
                        const Icon(Icons.location_on, color: Color(0xFF94A3B8), size: 20),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLocationInfo('Départ', 'Conakry, Gare de Madina', subColor, textColor),
                          const SizedBox(height: 16),
                          _buildLocationInfo('Destination', 'Kankan, Centre-ville', subColor, textColor),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(height: 1, color: Color(0xFFF8FAFC)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildTripMetaItem(Icons.schedule, 'DÉPART PRÉVU', 'Aujourd\'hui, 08:30', subColor, textColor),
                    const Spacer(),
                    _buildTripMetaItem(Icons.group, 'PASSAGERS', '12 / 15 réservés', subColor, textColor),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    shadowColor: primary.withValues(alpha: 0.2),
                  ).copyWith(
                    elevation: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.pressed) ? 0 : 4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.navigation, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Démarrer le trajet',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          side: BorderSide.none,
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          foregroundColor: const Color(0xFF334155),
                        ),
                        child: Text('Passagers', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          side: BorderSide.none,
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          foregroundColor: const Color(0xFF334155),
                        ),
                        child: Text('Détails', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
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

  Widget _buildPulseDot(Color color) {
    return ScaleTransition(
      scale: Tween(begin: 0.8, end: 1.2).animate(_pulseController),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 4,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(String label, String value, Color labelColor, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(fontSize: 10, color: labelColor, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(fontSize: 16, color: valueColor, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTripMetaItem(IconData icon, String label, String value, Color labelColor, Color valueColor) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF94A3B8), size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(fontSize: 9, color: labelColor, fontWeight: FontWeight.w700, letterSpacing: 0.5),
            ),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: valueColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFutureTripCard({
    required String id,
    required String route,
    required String time,
    required String passengers,
    required Color primary,
    required Color textColor,
    required Color subColor,
    bool isPlaceholder = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Opacity(
        opacity: 0.9,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'PRÉVU',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF64748B),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  Text(
                    'ID: $id',
                    style: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(route, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 14, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 4),
                              Text(time, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: subColor, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Passagers', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                          Text(passengers, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: primary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (isPlaceholder)
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        foregroundColor: const Color(0xFF475569),
                      ),
                      child: Text('Voir les détails', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              minimumSize: const Size(0, 44),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              foregroundColor: const Color(0xFF475569),
                            ),
                            child: Text('Voir les passagers', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              minimumSize: const Size(0, 44),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              foregroundColor: const Color(0xFF475569),
                            ),
                            child: Text('Modifier', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
