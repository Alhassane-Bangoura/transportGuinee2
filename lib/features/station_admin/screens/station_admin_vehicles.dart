import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/station_service.dart';

class StationAdminVehicles extends StatefulWidget {
  const StationAdminVehicles({super.key});

  @override
  State<StationAdminVehicles> createState() => _StationAdminVehiclesState();
}

class _StationAdminVehiclesState extends State<StationAdminVehicles> {
  int _selectedFilterIndex = 0;
  List<Map<String, dynamic>> _vehicles = [];
  bool _isLoading = true;

  final List<String> _filters = ['Tous', 'En attente', 'Remplissage', 'Prêt'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final authResponse = await AuthService.getCurrentProfile();
      final profile = authResponse.data;
      if (profile != null && profile.stationId != null) {
        final vehResponse = await StationService.getStationVehicles(profile.stationId!);
        if (mounted) {
          setState(() {
            _vehicles = vehResponse.data ?? [];
            _isLoading = false;
          });
          if (!vehResponse.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(vehResponse.message)),
            );
          }
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading vehicles: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredVehicles {
    if (_selectedFilterIndex == 0) return _vehicles;
    if (_selectedFilterIndex == 1) return _vehicles.where((v) => v['status'] == 'delayed' || v['status'] == 'en_attente').toList();
    if (_selectedFilterIndex == 2) return _vehicles.where((v) => v['status'] == 'loading' || v['status'] == 'remplissage' || v['status'] == 'scheduled').toList();
    if (_selectedFilterIndex == 3) return _vehicles.where((v) => v['status'] == 'ready' || v['status'] == 'validé').toList();
    return _vehicles;
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
                  children: [
                    if (_filteredVehicles.isEmpty)
                      _buildEmptyState()
                    else
                      ..._filteredVehicles.map((v) => _buildPremiumVehicleCard(v)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.directions_bus, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GUINEE TRANSPORT',
                          style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                        ),
                        Text('SUIVI DE LA FLOTTE EN GARE',
                          style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ],
                ),
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: AppColors.border)),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary, size: 24),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(10),
                      ),
                    ),
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: AppColors.background, width: 2)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Rechercher par numéro de plaque...',
                  hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textHint, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: List.generate(_filters.length, (index) {
            final isSelected = _selectedFilterIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilterIndex = index),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                ),
                child: Text(
                  _filters[index],
                  style: GoogleFonts.plusJakartaSans(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
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
      margin: const EdgeInsets.only(top: 60),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.directions_car_filled_outlined, color: AppColors.textHint, size: 64),
          const SizedBox(height: 20),
          Text('Aucun véhicule trouvé',
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text('Modifiez vos filtres de recherche',
            style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumVehicleCard(Map<String, dynamic> v) {
    String rawStatus = v['status'] ?? 'unknown';
    bool isReady = rawStatus == 'ready' || rawStatus == 'validé';
    bool isLoading = rawStatus == 'loading' || rawStatus == 'remplissage' || rawStatus == 'scheduled';
    bool isDelayed = rawStatus == 'delayed' || rawStatus == 'en_attente';
    bool isDeparted = rawStatus == 'active' || rawStatus == 'parti';

    Color statusColor = AppColors.primary;
    Color statusBgColor = AppColors.primary.withOpacity(0.1);
    String statusLabel = 'INCONNU';
    String actionLabel = 'Gérer';
    IconData actionIcon = Icons.chevron_right_rounded;
    Color actionColor = AppColors.primary;

    if (isReady) {
      statusColor = Colors.green;
      statusBgColor = Colors.green.withOpacity(0.1);
      statusLabel = 'PRÊT';
      actionLabel = 'Confirmer Départ';
      actionIcon = Icons.check_circle_rounded;
      actionColor = Colors.white;
    } else if (isLoading) {
      statusColor = Colors.amber;
      statusBgColor = Colors.amber.withOpacity(0.1);
      statusLabel = 'REMPLISSAGE';
    } else if (isDelayed) {
      statusColor = AppColors.textSecondary;
      statusBgColor = AppColors.surface;
      statusLabel = 'EN ATTENTE';
      actionColor = AppColors.textSecondary;
    } else if (isDeparted) {
      statusColor = Colors.blue;
      statusBgColor = Colors.blue.withOpacity(0.1);
      statusLabel = 'PARTI';
      actionLabel = 'Suivre';
      actionIcon = Icons.map_rounded;
    }

    int maxSeats = v['total_seats'] ?? 15;
    int currentSeats = isReady ? maxSeats : (isLoading ? (maxSeats * 0.8).round() : 0);
    if (isDeparted) currentSeats = maxSeats;
    double progress = currentSeats / maxSeats;
    String plate = v['license_plate'] ?? 'XX-0000-X';
    String dest = "Vers Destination"; // Modify with actual arrival city if available

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            plate,
                            style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dest,
                          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        statusLabel,
                        style: GoogleFonts.plusJakartaSans(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: AppColors.textSecondary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              v['driver_name'] ?? 'Inconnu',
                              style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(isDeparted ? Icons.location_on_rounded : Icons.event_seat_rounded, color: AppColors.textSecondary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            isDeparted ? 'En route' : '$currentSeats / $maxSeats',
                            style: GoogleFonts.plusJakartaSans(color: statusColor, fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.background,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isDeparted ? 'Départ: 07:15' : (isReady ? 'Départ imminent' : 'Position en file: --'),
                  style: GoogleFonts.plusJakartaSans(color: AppColors.textHint, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                isReady
                  ? ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(actionLabel, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800)),
                    )
                  : InkWell(
                      onTap: () {},
                      child: Row(
                        children: [
                          Text(actionLabel, style: GoogleFonts.plusJakartaSans(color: actionColor, fontSize: 14, fontWeight: FontWeight.w800)),
                          const SizedBox(width: 4),
                          Icon(actionIcon, color: actionColor, size: 18),
                        ],
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

