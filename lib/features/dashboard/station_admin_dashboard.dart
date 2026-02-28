import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StationAdminDashboard extends StatefulWidget {
  const StationAdminDashboard({super.key});

  @override
  State<StationAdminDashboard> createState() => _StationAdminDashboardState();
}

class _StationAdminDashboardState extends State<StationAdminDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _bannerController;

  @override
  void initState() {
    super.initState();
    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF059669);
    const Color accentColor = Color(0xFFF59E0B);
    const Color backgroundDark = Color(0xFF060D06);
    const Color surfaceDark = Color(0xFF0F1A0F);

    return Scaffold(
      backgroundColor: backgroundDark,
      body: Column(
        children: [
          // Scrolling Banner
          _buildScrollingBanner(accentColor),

          // Header
          _buildHeader(primaryColor, accentColor, surfaceDark),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  // Next Departures
                  _buildNextDepartures(primaryColor, accentColor, surfaceDark),

                  // Quays Management
                  _buildQuayManagement(primaryColor, accentColor, surfaceDark),

                  // Incident Reporting
                  _buildIncidentSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(primaryColor, surfaceDark),
    );
  }

  Widget _buildScrollingBanner(Color accent) {
    return Container(
      height: 32,
      color: accent.withOpacity(0.15),
      child: AnimatedBuilder(
        animation: _bannerController,
        builder: (context, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Positioned(
                    left: constraints.maxWidth *
                        (1 - _bannerController.value * 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildBannerItem(Icons.warning,
                            'RETARD : Bus GN-4522-A (Mamou) +15min', accent),
                        const SizedBox(width: 40),
                        _buildBannerItem(
                            Icons.info, 'QUAIS 4 & 5 EN MAINTENANCE', accent),
                        const SizedBox(width: 40),
                        _buildBannerItem(Icons.warning,
                            'TRAFIC DENSE : AXE BAMBÉTO-COSA', accent),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBannerItem(IconData icon, String text, Color accent) {
    return Row(
      children: [
        Icon(icon, color: accent, size: 14),
        const SizedBox(width: 4),
        Text(
          text.toUpperCase(),
          style: GoogleFonts.publicSans(
              color: accent,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1),
        ),
      ],
    );
  }

  Widget _buildHeader(Color primary, Color accent, Color surface) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: surface,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gare Routière de Bambéto',
                      style: GoogleFonts.publicSans(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.grey, size: 12),
                      const SizedBox(width: 4),
                      Text('Conakry, Ratoma',
                          style: GoogleFonts.publicSans(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        shape: BoxShape.circle),
                    child: Icon(Icons.search, color: primary, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primary.withOpacity(0.2)),
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuBu2aIvRuqxn5ITADSIStrczFBRcl3qyMyA3wgZI7FGgwkE8vN_C2nj_sze-FMlO27tdlVCFHAUALQZof8wjKAQp1ExFDoWuArEAzPJw2hF4hB6cO_-jw4vUDYWpYJS6odpfcICWW68gqVzvraZ_31lIYKSkRSEycg5eXkPV_xTUmSsFU8VRtptlWBOy1-hB8Z4a12loPzfa8QO_9EOBLvrr4MWZ4YEm3aspUMuTBwB4SFKnspOretPpieHThozZESIg6DJb5eAvOR5'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildHeaderStat('Départs Actifs', '14', primary, Colors.white),
              const SizedBox(width: 8),
              _buildHeaderStat('Bus en Attente', '06', accent, Colors.white),
              const SizedBox(width: 8),
              _buildHeaderStat(
                  'Quais Libres', '03', const Color(0xFF1E293B), Colors.grey,
                  isBorder: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(
      String label, String value, Color color, Color textColor,
      {bool isBorder = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border:
              isBorder ? Border.all(color: Colors.grey.withOpacity(0.3)) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(),
                style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontSize: 8,
                    fontWeight: FontWeight.bold)),
            Text(value,
                style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _buildNextDepartures(Color primary, Color accent, Color surface) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.departure_board, color: primary, size: 20),
                  const SizedBox(width: 8),
                  Text('Prochains Départs',
                      style: GoogleFonts.publicSans(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Text('VOIR TOUT',
                    style: TextStyle(
                        color: primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDepartureCard('Conakry → Mamou', '14:30', 'Alpha Diallo',
              'GN-4522-A', '28/32', true, primary, surface),
          const SizedBox(height: 12),
          _buildDepartureCard('Conakry → Labé', '15:15', 'Sékou Condé',
              'GN-1109-B', '', false, primary, surface,
              isWaiting: true, tag: 'CONTRÔLE TECHNIQUE', tagColor: accent),
        ],
      ),
    );
  }

  Widget _buildDepartureCard(
      String route,
      String time,
      String driver,
      String plate,
      String passengers,
      bool isActive,
      Color primary,
      Color surface,
      {bool isWaiting = false,
      String? tag,
      Color? tagColor}) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: const DecorationImage(
                          image: NetworkImage(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuCwHAw4QXL2ckdgPmFEQ3SW2gPG4U_8BYYnmC4LjizjUWc6BH9seF7DblxN1H8FMlRe5vwshtrul8jVNVaMHX52H291zCymgoojUYY_-EJRr7Y-0DODUYZM9nAfMHhsbQUkIMHgmkSLaQNoas2cntkq5-K8tYFRDynfkEewezRl9Db1xHsFZkzxhHKBqwfZdvayKQ9KAUOiMASuKKzX3t-HN11Zbtny36nQzwsDFZItVgitRVzfi4AprJ-Y4jPmpms16o8Vl_l2ZDic'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (isActive)
                      Positioned(
                        bottom: -1,
                        right: -1,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: surface, width: 2)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(route,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: isWaiting
                                    ? Colors.white10
                                    : primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(time,
                                style: TextStyle(
                                    color: isWaiting ? Colors.grey : primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                      Text('$driver • $plate',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                      if (tag != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: tagColor?.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4)),
                          child: Text(tag,
                              style: TextStyle(
                                  color: tagColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                      if (passengers.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.people,
                                color: Colors.grey, size: 14),
                            const SizedBox(width: 4),
                            Text(passengers,
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isWaiting ? null : () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isWaiting ? Colors.white10 : primary,
                      foregroundColor: isWaiting ? Colors.grey : Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      disabledBackgroundColor: Colors.white10,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isWaiting)
                          const Icon(Icons.check_circle, size: 20),
                        if (!isWaiting) const SizedBox(width: 8),
                        Text(isWaiting ? 'En attente' : 'Valider Départ',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.more_vert, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuayManagement(Color primary, Color accent, Color surface) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.lan, color: primary, size: 20),
              const SizedBox(width: 8),
              const Text('Gestion des Quais',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _buildQuayItem('Q1', 'OCCUPÉ', primary, Icons.directions_bus),
              _buildQuayItem('Q2', 'LIBRE', Colors.grey, null, isDashed: true),
              _buildQuayItem('Q3', 'OCCUPÉ', primary, Icons.directions_bus),
              _buildQuayItem('Q4', 'MAINT.', accent, Icons.engineering,
                  isWarning: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuayItem(String id, String status, Color color, IconData? icon,
      {bool isDashed = false, bool isWarning = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWarning
            ? color.withOpacity(0.1)
            : (isDashed ? Colors.transparent : Colors.white.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(16),
        border: isDashed
            ? Border.all(
                color: Colors.white24,
                style: BorderStyle
                    .solid) // Simplification car Flutter n'a pas de dashed nativement sans package
            : Border.all(
                color: isWarning
                    ? color.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: isDashed ? Colors.white10 : color,
                    borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center,
                child: Text(id,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
              const SizedBox(width: 12),
              Text(status,
                  style: TextStyle(
                      color: color, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          if (icon != null) Icon(icon, color: color, size: 16),
        ],
      ),
    );
  }

  Widget _buildIncidentSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child:
                      const Icon(Icons.report, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Signaler un Incident',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold)),
                    Text('Retard, Panne, Sécurité'.toUpperCase(),
                        style: TextStyle(
                            color: Colors.red.withOpacity(0.8), fontSize: 8)),
                  ],
                ),
              ],
            ),
            const Icon(Icons.chevron_right, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(Color primary, Color surface) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: surface.withOpacity(0.95),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.dashboard, 'Gare', true, primary),
          _buildNavItem(Icons.lan, 'Quais', false, primary),
          _buildNavItem(
              Icons.notification_important, 'Incidents', false, primary),
          _buildNavItem(Icons.query_stats, 'Stats', false, primary),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, bool isActive, Color primary) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? primary : Colors.grey, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? primary : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
