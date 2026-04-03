import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/station_service.dart';
import '../../../core/services/trip_service.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/models/trip.dart';
import 'station_admin_unassigned_drivers.dart';
import 'station_admin_relay.dart';
import 'station_admin_departure_management.dart';
import 'station_admin_vehicle_tracking.dart';
import 'station_admin_ai_assistant.dart';

class StationAdminHome extends StatefulWidget {
  const StationAdminHome({super.key});

  @override
  State<StationAdminHome> createState() => _StationAdminHomeState();
}

class _StationAdminHomeState extends State<StationAdminHome> {
  UserProfile? _profile;
  List<Trip> _upcomingTrips = [];
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
      final response = await AuthService.getCurrentProfile();
      final profile = response.data;
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
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildPremiumHeader(),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 180),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (_inactiveSyndicateCount > 0) ...[
                      _buildRelayAlert(),
                      const SizedBox(height: 24),
                    ],
                    _buildStatsGrid(),
                    const SizedBox(height: 32),
                    _buildAIAssistantCard(),
                    const SizedBox(height: 48),
                    _buildSectionHeader('PROCHAINS DÉPARTS'),
                    const SizedBox(height: 16),
                    ...(_upcomingTrips.isEmpty 
                      ? [_buildEmptyState('Aucun départ prévu')] 
                      : _upcomingTrips.map((trip) => _buildDepartureCard(trip))),
                    const SizedBox(height: 48),
                    _buildSectionHeader('ACTIONS RAPIDES'),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                  ]),
                ),
              ),
            ],
          ),
          _buildFloatingAssistantBar(),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.background.withOpacity(0.9),
      expandedHeight: 120,
      toolbarHeight: 90,
      automaticallyImplyLeading: false,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: FlexibleSpaceBar(
            background: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 12, offset: const Offset(0, 4)
                              )
                            ],
                          ),
                          child: const Icon(Icons.directions_bus, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('GUINEE TRANSPORT',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.primary,
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text('Gérez l\'activité de votre gare',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildHeaderButton(Icons.notifications_outlined, hasBadge: true),
                        const SizedBox(width: 12),
                        _buildHeaderButton(Icons.account_circle_outlined),
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

  Widget _buildHeaderButton(IconData icon, {bool hasBadge = false}) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: IconButton(
            onPressed: () {},
            icon: Icon(icon, color: AppColors.primary, size: 20),
            style: IconButton.styleFrom(padding: const EdgeInsets.all(12)),
          ),
        ),
        if (hasBadge)
          Positioned(
            top: 10, right: 10,
            child: Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StationAdminDepartureManagement()),
            );
          },
          child: Row(
            children: [
              Text('Voir tout', 
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primary, 
                  fontSize: 13, 
                  fontWeight: FontWeight.w700
                )
              ),
              const Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StationAdminVehicleTracking()),
            );
          },
          child: _buildStatCard('Véhicules présents', _driverCount.toString(), Icons.local_shipping_rounded, AppColors.primary),
        ),
        _buildStatCard('Départs aujourd\'hui', _departureCount.toString(), Icons.departure_board_rounded, Colors.teal),
        _buildStatCard('Passagers attente', _unassignedCount.toString(), Icons.groups_rounded, Colors.amber),
        _buildStatCard('Places disponibles', '34', Icons.airline_seat_recline_normal_rounded, Colors.blue),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20, offset: const Offset(0, 10)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.withOpacity(0.7), size: 24),
          const Spacer(),
          Text(value,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAssistantCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 30, offset: const Offset(0, 15)
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20, right: -20,
            child: Icon(Icons.smart_toy, size: 140, color: Colors.white.withOpacity(0.08)),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                    const SizedBox(width: 10),
                    Text('ASSISTANT INTELLIGENT',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Aujourd'hui, la gare a enregistré $_departureCount départs. La destination la plus fréquentée est Conakry. Trois véhicules sont actuellement en attente de passagers finaux pour un départ imminent.",
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 15,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartureCard(Trip trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.location_on, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip.arrivalCityName,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: Colors.white,
                  ),
                ),
                Text('Chauffeur: ${trip.driverId?.substring(0, 8) ?? "En attente"}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${trip.departureTime.hour}:${trip.departureTime.minute.toString().padLeft(2, '0')}',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              _buildStatusBadge(trip.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = AppColors.textSecondary;
    if (status.toLowerCase().contains('prêt') || status.toLowerCase().contains('ready')) color = Colors.green;
    if (status.toLowerCase().contains('remplissage') || status.toLowerCase().contains('filling')) color = Colors.amber;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(status.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton('Nouveau Départ', Icons.add_circle_rounded, AppColors.primary, Colors.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton('Enreg. Passager', Icons.person_add_rounded, AppColors.surface, AppColors.primary, hasBorder: true),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color bgColor, Color textColor, {bool hasBorder = false}) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: hasBorder ? Border.all(color: AppColors.primary.withOpacity(0.2), width: 2) : null,
        boxShadow: bgColor == AppColors.primary
          ? [BoxShadow(color: bgColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]
          : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 10),
              Text(label,
                style: GoogleFonts.plusJakartaSans(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingAssistantBar() {
    return Positioned(
      bottom: 24, left: 20, right: 20,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 10))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text('Posez une question sur la gare...',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const StationAdminAIAssistant()));
              },
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              style: IconButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.all(12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelayAlert() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StationAdminRelayScreen())),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.error.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Attention : Relais Nécessaire',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: AppColors.error,
                    ),
                  ),
                  Text('$_inactiveSyndicateCount syndicat(s) inactif(s). Prenez le relais.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.error, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, color: AppColors.textHint, size: 50),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
