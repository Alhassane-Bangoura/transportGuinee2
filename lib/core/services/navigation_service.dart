import 'package:flutter/material.dart';
import '../../core/models/user_profile.dart';
import '../../features/passenger/screens/passenger_dashboard.dart';
import '../../features/driver/screens/driver_dashboard.dart';
import '../../features/syndicate/screens/syndicate_dashboard.dart';
import '../../features/station_admin/screens/station_admin_dashboard.dart';

class NavigationService {
  static Widget getDashboardForRole(String role, {UserProfile? profile}) {
    switch (role.toUpperCase()) {
      case 'PASSENGER':
      case 'PASSAGER':
        return PassengerDashboard(profile: profile);
      case 'DRIVER':
      case 'CHAUFFEUR':
        return DriverDashboard(profile: profile);
      case 'SYNDICATE':
      case 'SYNDICAT':
        return const SyndicateDashboard();
      case 'STATION_ADMIN':
      case 'GARE':
        return const StationAdminDashboard();
      default:
        return PassengerDashboard(profile: profile);
    }
  }
}
