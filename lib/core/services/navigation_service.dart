import 'package:flutter/material.dart';
import '../../core/models/user_profile.dart';
import '../../features/dashboard/passenger_dashboard.dart';
import '../../features/dashboard/driver_dashboard.dart';
import '../../features/dashboard/syndicate_dashboard.dart';
import '../../features/dashboard/station_admin_dashboard.dart';

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
