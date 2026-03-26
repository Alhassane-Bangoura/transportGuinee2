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
  int _selectedTab = 0;
  List<Map<String, dynamic>> _vehicles = [];
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
        final vehicles = await StationService.getStationVehicles(profile.stationId!);
        if (mounted) {
          setState(() {
            _vehicles = vehicles;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading vehicles: $e');
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
                    if (_vehicles.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Text('Aucun véhicule trouvé', style: GoogleFonts.plusJakartaSans(color: textSlate500)),
                        ),
                      )
                    else
                      ..._vehicles.map((v) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildVehicleCard(
                          '${v['type']} (${v['license_plate']})',
                          v['status'],
                          v['driver_name'],
                          'Assigné', // Placeholder for syndicate/assignment
                          '${v['total_seats']} places',
                          'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=400',
                          primaryColor,
                          statusColor: v['status'] == 'scheduled' ? Colors.amber : primaryColor,
                        ),
                      )),
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
        color: Colors.white,
        border: Border(bottom: BorderSide(color: primary.withValues(alpha: 0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back)),
              Text(
                'Véhicules de la gare',
                style: GoogleFonts.plusJakartaSans(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        ],
      ),
    );
  }

  Widget _buildTabs(Color primary, Color subColor) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildTabItem(0, 'Tous', primary, subColor),
            const SizedBox(width: 24),
            _buildTabItem(1, 'En attente', primary, subColor),
            const SizedBox(width: 24),
            _buildTabItem(2, 'En chargement', primary, subColor),
            const SizedBox(width: 24),
            _buildTabItem(3, 'En trajet', primary, subColor),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String label, Color primary, Color subColor) {
    final bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: isSelected ? primary : subColor,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(
    String name,
    String status,
    String driver,
    String syndicate,
    String seats,
    String image,
    Color primary, {
    required Color statusColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.1)),
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
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                const SizedBox(height: 12),
                _buildInfoRow(Icons.person, driver, primary),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.groups, 'Syndicat: $syndicate', primary),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.airline_seat_recline_normal, seats, primary),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.visibility, size: 18),
                            const SizedBox(width: 8),
                            const Text('Détails', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF64748B).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.block, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.verified_user, color: primary),
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

  Widget _buildInfoRow(IconData icon, String text, Color primary) {
    return Row(
      children: [
        Icon(icon, color: primary, size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF64748B),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
