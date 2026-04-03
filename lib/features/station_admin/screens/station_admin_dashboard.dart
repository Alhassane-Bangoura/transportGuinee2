import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import 'station_admin_home.dart';
import 'station_admin_platforms.dart';
import 'station_admin_departures.dart';
import 'station_admin_vehicles.dart';
import 'station_admin_syndicates.dart';
import 'station_admin_profile.dart';
import 'station_admin_ai_assistant.dart';
import '../../../core/widgets/premium_bottom_nav_bar.dart';

import '../../../core/models/user_profile.dart';

class StationAdminDashboard extends StatefulWidget {
  final UserProfile? profile;
  const StationAdminDashboard({super.key, this.profile});

  @override
  State<StationAdminDashboard> createState() => _StationAdminDashboardState();
}

class _StationAdminDashboardState extends State<StationAdminDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const StationAdminHome(),
    const StationAdminPlatforms(),
    const StationAdminVehicles(),
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
      extendBody: true,
      bottomNavigationBar: PremiumBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          NavItem(icon: Icons.dashboard_outlined, label: 'Accueil'),
          NavItem(icon: Icons.layers_outlined, label: 'Quais'),
          NavItem(icon: Icons.directions_bus_outlined, label: 'Bus'),
          NavItem(icon: Icons.business_outlined, label: 'Syndicats'),
          NavItem(icon: Icons.person_outline, label: 'Profil'),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StationAdminAIAssistant(),
                    ),
                  );
                },
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.smart_toy, color: AppColors.onPrimary),
              ),
            )
          : null,
    );
  }
}
