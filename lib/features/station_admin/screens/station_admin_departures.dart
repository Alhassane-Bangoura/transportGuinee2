import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/trip_service.dart';
import '../../../core/models/trip.dart';
import '../../../core/constants/app_assets.dart';

class StationAdminDepartures extends StatefulWidget {
  const StationAdminDepartures({super.key});

  @override
  State<StationAdminDepartures> createState() => _StationAdminDeparturesState();
}

class _StationAdminDeparturesState extends State<StationAdminDepartures> {
  int _selectedFilterIndex = 0;
  List<Trip> _trips = [];
  bool _isLoading = true;

  final List<String> _filters = ['Tous les départs', 'Prêts', 'En attente', 'En retard'];

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
        final trips = await TripService.getUpcomingTrips(
          limit: 20,
          stationId: profile.stationId,
        );
        if (mounted) {
          setState(() {
            _trips = trips.data ?? [];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading departures: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Trip> get _filteredTrips {
    if (_selectedFilterIndex == 0) return _trips;
    if (_selectedFilterIndex == 1) return _trips.where((t) => t.status == 'ready' || t.status == 'validé' || t.status == 'active').toList();
    if (_selectedFilterIndex == 2) return _trips.where((t) => t.status == 'scheduled' || t.status == 'loading' || t.status == 'remplissage').toList();
    if (_selectedFilterIndex == 3) return _trips.where((t) => t.status == 'delayed').toList();
    return _trips;
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPremiumHeader(),
            _buildFilterChips(),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                onRefresh: _loadData,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    if (_filteredTrips.isEmpty)
                      _buildEmptyState()
                    else
                      ..._filteredTrips.map((trip) => _buildPremiumDepartureCard(trip)),
                    const SizedBox(height: 80), // Space for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: Border(bottom: BorderSide(color: AppColors.primary.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.directions_bus, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GUINEE TRANSPORT',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'SUPERVISION DES DÉPARTS',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              _buildHeaderButton(Icons.notifications_outlined, hasBadge: true),
              const SizedBox(width: 10),
              _buildHeaderButton(Icons.search_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, {bool hasBadge = false}) {
    return Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          ),
          child: IconButton(
            onPressed: () {},
            icon: Icon(icon, color: AppColors.primary, size: 20),
            padding: EdgeInsets.zero,
          ),
        ),
        if (hasBadge)
          Positioned(
            top: 8, right: 8,
            child: Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(_filters.length, (index) {
            final isSelected = _selectedFilterIndex == index;
            int count = 0;
            Color badgeBg = isSelected ? Colors.white.withOpacity(0.2) : AppColors.surface;
            Color badgeText = isSelected ? Colors.white : AppColors.textSecondary;

            if (index == 0) { count = _trips.length; }
            else if (index == 1) { count = _trips.where((t) => t.status == 'ready' || t.status == 'validé' || t.status == 'active').length; if (!isSelected) { badgeBg = Colors.green.withOpacity(0.1); badgeText = Colors.green; } }
            else if (index == 2) { count = _trips.where((t) => t.status == 'scheduled' || t.status == 'loading' || t.status == 'remplissage').length; if (!isSelected) { badgeBg = Colors.amber.withOpacity(0.1); badgeText = Colors.amber; } }
            else if (index == 3) { count = _trips.where((t) => t.status == 'delayed').length; if (!isSelected) { badgeBg = Colors.red.withOpacity(0.1); badgeText = Colors.red; } }

            return GestureDetector(
              onTap: () => setState(() => _selectedFilterIndex = index),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                  boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))] : [],
                ),
                child: Row(
                  children: [
                    Text(
                      _filters[index],
                      style: GoogleFonts.plusJakartaSans(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(100)),
                      child: Text(
                        count.toString(),
                        style: GoogleFonts.plusJakartaSans(
                          color: badgeText,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), shape: BoxShape.circle),
            child: Icon(Icons.inbox_outlined, color: AppColors.primary.withOpacity(0.3), size: 64),
          ),
          const SizedBox(height: 24),
          Text('Aucun départ disponible',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text('Essayez de changer de filtre ou de rafraîchir la liste.',
            style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumDepartureCard(Trip trip) {
    bool isReady = trip.status == 'ready' || trip.status == 'validé' || trip.status == 'active';
    Color statusColor = isReady ? Colors.green : Colors.amber;
    String statusText = isReady ? 'PRÊT À PARTIR' : 'REMPLISSAGE';
    int maxSeats = trip.totalSeats ?? 18;
    int currentSeats = (maxSeats * 0.8).round(); // Mock for visual parity

    String carImage = AppAssets.vehiclePreview1;
    if (!isReady) carImage = AppAssets.stationAdminHeader;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                  image: DecorationImage(image: NetworkImage(carImage), fit: BoxFit.cover),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          statusText,
                          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.person, color: AppColors.primary, size: 12),
                              ),
                              const SizedBox(width: 8),
                              Text('Info Chauffeur', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('PASSAGERS', style: GoogleFonts.plusJakartaSans(color: AppColors.textHint, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 1)),
                              Text('$currentSeats / $maxSeats', style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.primary, size: 14),
                          const SizedBox(width: 4),
                          Text(trip.arrivalCityName, style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (isReady) ...[
                             const Icon(Icons.check_circle, color: Colors.green, size: 16),
                             const SizedBox(width: 4),
                             Text('COMPLET', style: GoogleFonts.plusJakartaSans(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w900)),
                          ] else ...[
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: LinearProgressIndicator(
                                  value: currentSeats / maxSeats,
                                  backgroundColor: AppColors.background,
                                  color: Colors.amber,
                                  minHeight: 4,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          ElevatedButton(
                            onPressed: isReady ? () {} : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.background,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: Row(
                              children: [
                                Icon(isReady ? Icons.check_circle_outline : Icons.hourglass_top, size: 14),
                                const SizedBox(width: 6),
                                Text(isReady ? 'Confirmer' : 'En attente', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerAvatar(String url) {
    return Container(
      width: 24, height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 2),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.only(bottom: 24, top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.primary.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.local_shipping, 'Départs', isActive: true),
          _navItem(Icons.directions_bus, 'Véhicules', isActive: false),
          _navItem(Icons.analytics, 'Rapports', isActive: false),
          _navItem(Icons.account_circle, 'Profil', isActive: false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, {required bool isActive}) {
    final color = isActive ? AppColors.primary : AppColors.textHint;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: color,
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
