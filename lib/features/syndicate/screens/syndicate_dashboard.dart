import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../../core/models/user_profile.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'syndicate_drivers.dart';
import 'syndicate_add_driver.dart';
import 'syndicate_trips.dart';
import 'syndicate_profile.dart';
import 'syndicate_driver_management.dart';
import 'syndicate_activity.dart';
import 'syndicate_vehicle_filling.dart';
import '../../assistant/screens/assistant_screen.dart';
import '../../../core/widgets/premium_bottom_nav_bar.dart';

class SyndicateDashboard extends StatefulWidget {
  final UserProfile? profile;
  const SyndicateDashboard({super.key, this.profile});

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
    if (widget.profile != null) {
      _profile = widget.profile;
      _isLoadingProfile = false;
    } else {
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    final response = await AuthService.getCurrentProfile();
    if (mounted) {
      setState(() {
        _profile = response.data;
        _isLoadingProfile = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final Color primaryColor = AppColors.primary;
    final Color backgroundColor = AppColors.background;
    final Color textSlate900 = AppColors.textPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(primaryColor, textSlate900),
          const SyndicateDriversPage(),
          const SyndicateAddDriverPage(),
          const SyndicateTripsPage(),
          SyndicateProfilePage(profile: _profile, onRefresh: _loadProfile),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PremiumBottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                if (index < 2) {
                  _currentIndex = index;
                } else {
                  _currentIndex = index + 1;
                }
              });
            },
            centerButton: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: AppColors.surface, width: 4),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _currentIndex = 2),
                  borderRadius: BorderRadius.circular(28),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
                ),
              ),
            ),
            items: [
              NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard'),
              NavItem(icon: Icons.group_outlined, label: 'Chauffeurs'),
              NavItem(icon: Icons.route_outlined, label: 'Trajets'),
              NavItem(icon: Icons.person_outline, label: 'Profil'),
            ],
          ),
          if (_currentIndex == 0) _buildFloatingAssistantBar(),
        ],
      ),
    );
  }

  Widget _buildFloatingAssistantBar() {
    return Positioned(
      bottom: 100, // Adjusted to be above bottom nav
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Comment puis-je vous aider ?',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.mic_none_rounded, color: AppColors.textSecondary),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceVariant,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () {
                    final role = _profile?.role.toUpperCase() ?? 'SYNDICAT';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AssistantScreen(userRole: role),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent(Color primary, Color textColor) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverHeader(primary, textColor),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 180), // Extra bottom padding for assistant bar
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildStatsSection(primary),
              const SizedBox(height: 32),
              _buildDailyDepartures(primary, textColor),
              const SizedBox(height: 32),
              _buildPriorityAlerts(primary, textColor),
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
      backgroundColor: AppColors.background.withOpacity(0.8),
      surfaceTintColor: Colors.transparent,
      expandedHeight: 100,
      toolbarHeight: 80,
      automaticallyImplyLeading: false,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: FlexibleSpaceBar(
            background: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'GUINEE TRANSPORT',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Organisation intelligente des trajets',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            textStyle: const TextStyle(height: 1.5),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildHeaderButton(Icons.notifications_outlined),
                        const SizedBox(width: 12),
                        _buildHeaderButton(Icons.search_rounded),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon, color: AppColors.primary, size: 22),
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _buildStatsSection(Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Statistiques de la flotte',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SyndicateDriverManagement()),
                );
              },
              child: _buildMiniStatCard('Chauffeurs actifs', '124', '+12%', true, Icons.group_rounded),
            ),
            _buildMiniStatCard('Véhicules dispo', '86', '+5%', true, Icons.directions_bus_rounded),
            _buildMiniStatCard("Départs aujourd'hui", '42', '+18%', true, Icons.schedule_rounded),
            _buildMiniStatCard('Places réservées', '310', '+25%', true, Icons.airline_seat_recline_normal_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStatCard(String label, String value, String trend, bool isPositive, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppColors.primary.withOpacity(0.5), size: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trend,
                  style: GoogleFonts.plusJakartaSans(
                    color: isPositive ? Colors.green : Colors.red,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyDepartures(Color primary, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.departure_board_outlined, color: AppColors.accent, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Départs du jour",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SyndicateActivity()),
                );
              },
              child: Text(
                'Voir tout',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSyndicateTripCard(
          driverName: 'Moussa Barry',
          driverMeta: 'Permis: Cat. D • Exp: 8 ans',
          initials: 'MB',
          vehicle: 'Toyota Coaster (AG-442-CX)',
          departureTime: '14:30',
          seats: '4 / 22',
          isAtCapacity: true,
        ),
        const SizedBox(height: 12),
        _buildSyndicateTripCard(
          driverName: 'Alpha Diallo',
          driverMeta: 'Permis: Cat. C • Exp: 12 ans',
          initials: 'AD',
          vehicle: 'Renault Master (CK-112-ZZ)',
          departureTime: '15:15',
          seats: '12 / 18',
          isAtCapacity: false,
        ),
      ],
    );
  }

  Widget _buildSyndicateTripCard({
    required String driverName,
    required String driverMeta,
    required String initials,
    required String vehicle,
    required String departureTime,
    required String seats,
    required bool isAtCapacity,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driverName,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        driverMeta,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTripDetailItem('VÉHICULE', vehicle),
                    ),
                    Expanded(
                      child: _buildTripDetailItem('DÉPART', departureTime, isEmphasized: true),
                    ),
                    Expanded(
                      child: _buildTripDetailItem('PLACES', seats, 
                        dotColor: isAtCapacity ? AppColors.accent : Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SyndicateVehicleFilling()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Valider départ',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13),
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

  Widget _buildTripDetailItem(String label, String value, {bool isEmphasized = false, Color? dotColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: AppColors.textHint,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            if (dotColor != null) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: isEmphasized ? FontWeight.w900 : FontWeight.w700,
                  color: isEmphasized ? AppColors.primary : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityAlerts(Color primary, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.accent, size: 20),
            const SizedBox(width: 8),
            Text(
              'Alertes prioritaires',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.accent.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active_rounded, color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Retard détecté - Moussa Barry',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Départ prévu pour 14:30 non validé.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
            ],
          ),
        ),
      ],
    );
  }
}
