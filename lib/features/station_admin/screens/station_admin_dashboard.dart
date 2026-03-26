import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import 'station_admin_home.dart';
import 'station_admin_platforms.dart';
import 'station_admin_departures.dart';
import 'station_admin_vehicles.dart';
import 'station_admin_syndicates.dart';
import 'station_admin_profile.dart';
import '../../assistant/screens/assistant_screen.dart';

class StationAdminDashboard extends StatefulWidget {
  const StationAdminDashboard({super.key});

  @override
  State<StationAdminDashboard> createState() => _StationAdminDashboardState();
}

class _StationAdminDashboardState extends State<StationAdminDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const StationAdminHome(),
    const StationAdminPlatforms(),
    const StationAdminVehicles(),
    const StationAdminDepartures(),
    const StationAdminSyndicates(),
    const StationAdminProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = AppColors.primary;
    final Color textSlate400 = AppColors.textHint;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          border: const Border(top: BorderSide(color: Color(0xFFF1F5F9))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard, 'Dashboard', primaryColor, textSlate400),
                _buildNavItem(1, Icons.layers, 'Quais', primaryColor, textSlate400),
                _buildNavItem(2, Icons.directions_bus, 'Véhicules', primaryColor, textSlate400),
                _buildNavItem(3, Icons.departure_board, 'Départs', primaryColor, textSlate400),
                _buildNavItem(4, Icons.business, 'Syndicats', primaryColor, textSlate400),
                _buildNavItem(5, Icons.person, 'Profil', primaryColor, textSlate400),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AssistantScreen(userRole: 'ADMIN_GARE'),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.smart_toy, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, Color primary, Color inactiveColor) {
    final bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? primary : inactiveColor,
            size: 24,
            fill: isSelected ? 1 : 0,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: isSelected ? primary : inactiveColor,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
