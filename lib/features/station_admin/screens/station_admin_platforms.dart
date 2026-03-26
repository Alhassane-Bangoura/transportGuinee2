import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/station_service.dart';

class StationAdminPlatforms extends StatefulWidget {
  const StationAdminPlatforms({super.key});

  @override
  State<StationAdminPlatforms> createState() => _StationAdminPlatformsState();
}

class _StationAdminPlatformsState extends State<StationAdminPlatforms> {
  int _selectedTab = 0;
  List<Map<String, dynamic>> _platforms = [];
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
        final platforms = await StationService.getStationPlatforms(profile.stationId!);
        if (mounted) {
          setState(() {
            _platforms = platforms;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading platforms: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredPlatforms {
    if (_selectedTab == 0) return _platforms;
    if (_selectedTab == 1) return _platforms.where((p) => p['isOccupied']).toList();
    if (_selectedTab == 2) return _platforms.where((p) => !p['isOccupied']).toList();
    return _platforms;
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
                    _buildSectionTitle('Liste des Quais actifs', 'Actualisé à l\'instant', textSlate900, textSlate500),
                    const SizedBox(height: 16),
                    if (_filteredPlatforms.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Text('Aucun quai configuré', style: GoogleFonts.plusJakartaSans(color: textSlate500)),
                        ),
                      )
                    else
                      ..._filteredPlatforms.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildPlatformCard(
                          p['number'],
                          p['status'],
                          p['destination'],
                          null,
                          null,
                          primaryColor,
                          textColor: p['isOccupied'] ? Colors.red : const Color(0xFF10B981),
                          isOccupied: p['isOccupied'],
                        ),
                      )),
                    const SizedBox(height: 16),
                    _buildAddPlatformCard(primaryColor),
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
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.menu, color: primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Gestion des Quais',
              style: GoogleFonts.plusJakartaSans(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(Color primary, Color subColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primary.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            _buildTabItem(0, 'Tous', _platforms.length.toString(), primary, subColor),
            _buildTabItem(1, 'Occupés', _platforms.where((p) => p['isOccupied']).length.toString(), primary, subColor),
            _buildTabItem(2, 'Libres', _platforms.where((p) => !p['isOccupied']).length.toString(), primary, subColor),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String label, String? count, Color primary, Color subColor) {
    final bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: isSelected ? primary : subColor,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count,
                    style: GoogleFonts.plusJakartaSans(
                      color: primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle, Color textColor, Color subColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            color: subColor,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformCard(
    String id,
    String status,
    String destination,
    String? departure,
    String? image,
    Color primary, {
    required Color textColor,
    required bool isOccupied,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF64748B).withValues(alpha: 0.1)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isOccupied ? primary.withValues(alpha: 0.1) : const Color(0xFF64748B).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isOccupied ? Icons.train : Icons.meeting_room,
                      color: isOccupied ? primary : const Color(0xFF64748B).withValues(alpha: 0.4),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            id,
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
                              color: textColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: GoogleFonts.plusJakartaSans(
                                color: textColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        isOccupied ? 'Destination: $destination' : 'Dernière destination: $destination',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF64748B).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit, color: Color(0xFF64748B), size: 18),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                  ),
                ],
              ),
            ],
          ),
          if (image != null) ...[
            const SizedBox(height: 12),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(image),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.2),
                    BlendMode.darken,
                  ),
                ),
              ),
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.schedule, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Départ prévu: $departure',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddPlatformCard(Color primary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: 0.2), width: 2), // Should be dashed if possible
      ),
      child: Column(
        children: [
          Icon(Icons.add_circle, color: primary.withValues(alpha: 0.6), size: 32),
          const SizedBox(height: 8),
          Text(
            'Ajouter un nouveau quai',
            style: GoogleFonts.plusJakartaSans(
              color: primary.withValues(alpha: 0.6),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
