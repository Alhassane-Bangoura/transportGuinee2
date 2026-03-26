import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/station_service.dart';
import '../../../core/services/trip_service.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/models/trip.dart';
import 'station_admin_unassigned_drivers.dart';
import 'station_admin_relay.dart';

class StationAdminHome extends StatefulWidget {
  const StationAdminHome({super.key});

  @override
  State<StationAdminHome> createState() => _StationAdminHomeState();
}

class _StationAdminHomeState extends State<StationAdminHome> {
  UserProfile? _profile;
  List<Trip> _upcomingTrips = [];
  int _syndicateCount = 0;
  int _driverCount = 0;
  int _departureCount = 0;
  int _unassignedCount = 0;
  int _inactiveSyndicateCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final profile = await AuthService.getCurrentProfile();
      if (profile != null && profile.stationId != null) {
        final stationId = profile.stationId!;
        final results = await Future.wait([
          StationService.getSyndicateCount(stationId),
          StationService.getDriverCount(stationId),
          StationService.getDepartureCount(stationId),
          TripService.getUpcomingTrips(limit: 5, stationId: stationId),
          StationService.getUnassignedDriverCount(stationId),
          StationService.getInactiveSyndicateCount(stationId),
        ]);
        
        if (mounted) {
          setState(() {
            _profile = profile;
            _syndicateCount = results[0] as int;
            _driverCount = results[1] as int;
            _departureCount = results[2] as int;
            _upcomingTrips = results[3] as List<Trip>;
            _unassignedCount = results[4] as int;
            _inactiveSyndicateCount = results[5] as int;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading station admin home data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final Color primaryColor = AppColors.primary;
    final Color backgroundColor = AppColors.background;
    final Color textSlate900 = AppColors.textPrimary;
    final Color textSlate500 = AppColors.textSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: Column(
                children: [
                  _buildHeader(primaryColor, textSlate900),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWelcomeSection(textSlate900, textSlate500),
                          if (_inactiveSyndicateCount > 0) _buildRelayAlert(primaryColor),
                          _buildStatsGrid(primaryColor, textSlate900, textSlate500),
                          _buildSectionTitle('Véhicules Prêts à Partir', textSlate900),
                          _buildDeparturesList(primaryColor, textSlate900, textSlate500),
                          _buildRecentNotifications(primaryColor, textSlate900, textSlate500),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(Color titleColor, Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bonjour, ${_profile?.firstName ?? "Admin"}',
            style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: titleColor),
          ),
          Text(
            'Voici l’activité de votre gare aujourd’hui.',
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: subColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildStatsGrid(Color primary, Color textTitle, Color textSub) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
        children: [
          _build3DStatCard('Véhicules', _driverCount.toString(), Icons.directions_bus, Colors.blue, textTitle, textSub),
          _build3DStatCard('Départs', _departureCount.toString(), Icons.departure_board, Colors.green, textTitle, textSub),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StationAdminUnassignedDrivers()),
            ),
            child: _build3DStatCard('En Attente', _unassignedCount.toString(), Icons.hourglass_empty, Colors.orange, textTitle, textSub),
          ),
          _build3DStatCard('Notifications', '12', Icons.notifications_active, Colors.red, textTitle, textSub),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StationAdminRelayScreen()),
            ),
            child: _build3DStatCard('Relais Admin', _inactiveSyndicateCount.toString(), Icons.shield_rounded, Colors.red, textTitle, textSub),
          ),
        ],
      ),
    );
  }

  Widget _build3DStatCard(String label, String value, IconData icon, Color color, Color textTitle, Color textSub) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
          BoxShadow(color: Colors.white.withOpacity(0.8), blurRadius: 1, offset: const Offset(-2, -2)),
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(5, 5)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Icon(icon, size: 80, color: color.withOpacity(0.05)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 24),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: textTitle)),
                    Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: textSub, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
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
        color: Colors.white,
        border: Border(bottom: BorderSide(color: primary.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.directions_bus, color: primary, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _profile?.metadata?['station_name'] ?? 'Ma Gare',
                    style: GoogleFonts.plusJakartaSans(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: primary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        _profile?.metadata?['city_name'] ?? 'Guinée',
                        style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_outlined),
            color: const Color(0xFF64748B),
          ),
        ],
      ),
    );
  }

  Widget _buildDeparturesList(Color primary, Color textColor, Color subColor) {
    if (_upcomingTrips.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text('Aucun départ prévu', style: GoogleFonts.plusJakartaSans(color: subColor)),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _upcomingTrips.length,
      itemBuilder: (context, index) {
        final trip = _upcomingTrips[index];
        return _buildDepartureCard(trip, primary, textColor, subColor);
      },
    );
  }

  Widget _buildDepartureCard(Trip trip, Color primary, Color textColor, Color subColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.departure_board, color: primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip.arrivalCityName, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                Text('${trip.departureTime.hour}:${trip.departureTime.minute.toString().padLeft(2, '0')} • Quai ${trip.quayNumber ?? "?"}', 
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: subColor)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(trip.status.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentNotifications(Color primary, Color textTitle, Color textSub) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Notifications Récentes', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: textTitle)),
              TextButton(onPressed: () {}, child: Text('Voir tout', style: GoogleFonts.plusJakartaSans(color: primary, fontSize: 13))),
            ],
          ),
          _buildNotificationItem('Départ Validé', 'Syndicat Labé a validé le véhicule GN-2456', 'Il y a 2m', Colors.green, textTitle, textSub),
          const SizedBox(height: 12),
          _buildNotificationItem('Véhicule Complet', 'Le Bus Mercedes (Kindia) est complet', 'Il y a 45m', Colors.orange, textTitle, textSub),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String title, String sub, String time, Color color, Color textTitle, Color textSub) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.notifications, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14, color: textTitle)),
                Text(sub, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: textSub)),
              ],
            ),
          ),
          Text(time, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: textSub)),
        ],
      ),
    );
  }

  Widget _buildRelayAlert(Color primary) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StationAdminRelayScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFEF2F2), Color(0xFFFFF1F2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attention : Relais Nécessaire',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF991B1B)),
                  ),
                  Text(
                    '$_inactiveSyndicateCount syndicat(s) inactif(s). Prenez le relais pour assurer les départs.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFFB91C1C)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 14),
          ],
        ),
      ),
    );
  }
}
