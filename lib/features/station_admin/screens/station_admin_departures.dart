import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/trip_service.dart';
import '../../../core/models/trip.dart';

class StationAdminDepartures extends StatefulWidget {
  const StationAdminDepartures({super.key});

  @override
  State<StationAdminDepartures> createState() => _StationAdminDeparturesState();
}

class _StationAdminDeparturesState extends State<StationAdminDepartures> {
  int _selectedTab = 0;
  List<Trip> _trips = [];
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
        final trips = await TripService.getUpcomingTrips(
          limit: 20,
          stationId: profile.stationId,
        );
        if (mounted) {
          setState(() {
            _trips = trips;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading departures: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Trip> get _filteredTrips {
    if (_selectedTab == 0) return _trips;
    if (_selectedTab == 1) return _trips.where((t) => t.status == 'loading' || t.status == 'active').toList();
    if (_selectedTab == 2) return _trips.where((t) => t.status == 'scheduled').toList();
    return _trips;
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(primaryColor, textSlate900),
            _buildTabs(primaryColor, textSlate500),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSectionTitle('Départs programmés', "Aujourd'hui", textSlate900, primaryColor),
                    const SizedBox(height: 16),
                    if (_filteredTrips.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Text('Aucun départ trouvé', style: GoogleFonts.plusJakartaSans(color: textSlate500)),
                        ),
                      )
                    else
                      ..._filteredTrips.map((trip) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildDepartureCard(
                          trip,
                          primaryColor,
                          statusColor: trip.status == 'scheduled' ? Colors.amber : primaryColor,
                          isActionPrimary: trip.status == 'scheduled',
                          actionText: trip.status == 'scheduled' ? 'Commencer chargement' : 'Autoriser départ',
                        ),
                      )),
                    const SizedBox(height: 16),
                    _buildSummaryCard(primaryColor, textSlate500),
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
              IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back)),
              Text(
                'Départs',
                style: GoogleFonts.plusJakartaSans(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(Color primary, Color subColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: primary.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          _buildTabItem(0, 'Tous les départs', primary, subColor),
          _buildTabItem(1, 'En chargement', primary, subColor),
          _buildTabItem(2, 'En attente', primary, subColor),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, Color primary, Color subColor) {
    final bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: isSelected ? primary : subColor,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String badge, Color textColor, Color primary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            badge,
            style: GoogleFonts.plusJakartaSans(
              color: primary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDepartureCard(
    Trip trip,
    Color primary, {
    required Color statusColor,
    required bool isActionPrimary,
    required String actionText,
  }) {
    final String route = '${trip.departureCityName} → ${trip.arrivalCityName}';
    final String status = trip.status;
    final String quay = trip.quayNumber?.toString() ?? 'Quai ?';
    final String time = '${trip.departureTime.hour}:${trip.departureTime.minute.toString().padLeft(2, '0')}';
    final String seats = '--/${trip.totalSeats ?? "?"}';
    final String driver = trip.driverId?.substring(0, 5) ?? "N/A";
    final String vehicle = '${trip.vehicleType ?? "Véhicule"} (${trip.licensePlate ?? "---"})';

    return Container(
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
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              route,
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF0F172A),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Color(0xFF64748B), size: 14),
                            const SizedBox(width: 4),
                            Text( quay, style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontSize: 13)),
                            const SizedBox(width: 8),
                            const Text('•', style: TextStyle(color: Color(0xFF64748B))),
                            const SizedBox(width: 8),
                            const Icon(Icons.schedule, color: Color(0xFF64748B), size: 14),
                            const SizedBox(width: 4),
                            Text(time, style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F8F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'SIÈGES',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF64748B),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            seats,
                            style: GoogleFonts.plusJakartaSans(
                              color: isActionPrimary ? primary : const Color(0xFF94A3B8),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.person, color: primary, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('CHAUFFEUR', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontSize: 9, fontWeight: FontWeight.bold)),
                                  Text(driver, style: GoogleFonts.plusJakartaSans(color: const Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.directions_bus, color: primary, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('VÉHICULE', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontSize: 9, fontWeight: FontWeight.bold)),
                                  Text(vehicle, style: GoogleFonts.plusJakartaSans(color: const Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                                ],
                              ),
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
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          String newStatus = trip.status == 'scheduled' ? 'loading' : 'completed';
                          final success = await TripService.updateTripStatus(trip.id, newStatus);
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Statut mis à jour : ${newStatus.toUpperCase()}')),
                            );
                            _loadData();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isActionPrimary ? primary : primary.withValues(alpha: 0.1),
                          foregroundColor: isActionPrimary ? Colors.white : primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isActionPrimary) const Icon(Icons.check_circle, size: 18),
                            if (isActionPrimary) const SizedBox(width: 8),
                            Text(actionText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primary.withValues(alpha: 0.2)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Passagers', style: TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(isActionPrimary ? Icons.cancel_outlined : Icons.delete_outline, color: Colors.red),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withValues(alpha: 0.05),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  Widget _buildSummaryCard(Color primary, Color subColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: 0.1), style: BorderStyle.solid), // Should be dashed
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.trending_up, color: primary, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Résumé d'aujourd'hui",
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF0F172A),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '12 départs effectués • 142 passagers',
                style: GoogleFonts.plusJakartaSans(
                  color: subColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
