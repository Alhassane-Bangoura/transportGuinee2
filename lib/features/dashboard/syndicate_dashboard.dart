import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/user_profile.dart';
import '../../core/services/auth_service.dart';
import 'syndicate_drivers.dart';
import 'syndicate_add_driver.dart';
import 'syndicate_trips.dart';
import 'syndicate_profile.dart';

class SyndicateDashboard extends StatefulWidget {
  const SyndicateDashboard({super.key});

  @override
  State<SyndicateDashboard> createState() => _SyndicateDashboardState();
}

class _SyndicateDashboardState extends State<SyndicateDashboard> {
  UserProfile? _profile;
  bool _isLoadingProfile = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
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
          child: CircularProgressIndicator(color: Color(0xFF16A249)),
        ),
      );
    }

    const Color primaryColor = Color(0xFF16A249);
    const Color backgroundColor = Color(0xFFF6F8F7);
    const Color textSlate900 = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(primaryColor, textSlate900),
          const SyndicateDriversPage(),
          const SyndicateAddDriverPage(),
          const SyndicateTripsPage(),
          const SyndicateProfilePage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(primaryColor),
    );
  }

  Widget _buildHomeContent(Color primary, Color textColor) {
    const Color subColor = Color(0xFF64748B);
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(primary, textColor),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDashboardSummary(textColor, subColor),
                  _buildStatsGrid(primary),
                  _buildPriorityAlerts(primary, textColor),
                  _buildManagedRoutes(primary, textColor, subColor),
                ],
              ),
            ),
          ),
        ],
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
                  color: primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_shipping, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _profile?.fullName ?? 'Syndicat Transport Conakry',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: primary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Conakry',
                      style: GoogleFonts.plusJakartaSans(
                        color: primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildIconBtn(Icons.notifications_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardSummary(Color textColor, Color subColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tableau de bord',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            "Aujourd'hui, Conakry",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: subColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Color primary) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
        children: [
          _buildStatCard('Total Chauffeurs', '1,240', '+2%', primary, Icons.trending_up),
          _buildStatCard('Chauffeurs Actifs', '850', '+5%', primary, Icons.trending_up),
          _buildStatCard('Départs', '320', '-1%', Colors.red, Icons.trending_down),
          _buildStatCard('Passagers', '4,500', '+12%', primary, Icons.trending_up),
          _buildRevenueCard('Revenus (GNF)', '12.5M', '+8%', primary),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String trend, Color color, IconData trendIcon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(trendIcon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(trend,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(String label, String value, String trend, Color primary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.trending_up, size: 12, color: primary),
              const SizedBox(width: 4),
              Text(trend,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: primary, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityAlerts(Color primary, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Alertes prioritaires',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              Text('3 NOUVELLES',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 10, fontWeight: FontWeight.w800, color: primary, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 16),
          _buildAlertRow(
            Icons.priority_high,
            'Licence expirée',
            'Mamadou Diallo - Toyota Hiace AG-234',
            Colors.red,
          ),
          const SizedBox(height: 12),
          _buildAlertRow(
            Icons.description,
            'Assurance expirée',
            'Abdoulaye Barry - Renault Master TK-091',
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildAlertRow(
            Icons.person_off,
            'Chauffeur suspendu',
            'Ousmane Sylla - Suspension temporaire (7j)',
            const Color(0xFF64748B),
            action: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildAlertRow(IconData icon, String title, String desc, Color color, {String action = 'Gérer'}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, fontWeight: FontWeight.bold, color: color.withValues(alpha: 0.8))),
                Text(desc,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: color.withValues(alpha: 0.6))),
              ],
            ),
          ),
          Text(
            action,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color.withValues(alpha: 0.8),
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagedRoutes(Color primary, Color textColor, Color subColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lignes de transport gérées',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 16),
          _buildRouteCard('Conakry', 'Mamou', '45 départs/j', '850/j', 0.85, primary),
          const SizedBox(height: 12),
          _buildRouteCard('Conakry', 'Labé', '28 départs/j', '520/j', 0.92, primary),
          const SizedBox(height: 12),
          _buildRouteCard('Conakry', 'Kankan', '18 départs/j', '340/j', 0.78, primary),
        ],
      ),
    );
  }

  Widget _buildRouteCard(String from, String to, String trips, String passengers, double progress, Color primary) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
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
          Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, primary.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(from, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.east, color: Colors.white, size: 16),
                ),
                Text(to, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildRouteMetric('Trajets', trips)),
                    Expanded(child: _buildRouteMetric('Passagers', passengers)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Taux de remplissage',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B))),
                    Text('${(progress * 100).toInt()}%',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: primary)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B))),
        Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildIconBtn(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9).withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: Center(child: Icon(icon, color: const Color(0xFF475569), size: 18)),
    );
  }

  Widget _buildBottomNav(Color primary) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFF1F5F9))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Accueil', 0, primary),
          _buildNavItem(Icons.badge, 'Chauffeurs', 1, primary),
          _buildAddBtn(primary),
          _buildNavItem(Icons.route, 'Trajets', 3, primary),
          _buildNavItem(Icons.account_circle, 'Profil', 4, primary),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, Color primary) {
    final bool isActive = _currentIndex == index;
    final Color color = isActive ? primary : const Color(0xFF94A3B8);
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  color: color, fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildAddBtn(Color primary) {
    return InkWell(
      onTap: () => setState(() => _currentIndex = 2),
      child: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }
}
