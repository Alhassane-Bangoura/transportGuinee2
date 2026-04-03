import 'package:flutter/material.dart';
import '../../core/models/user_profile.dart';
import '../../features/passenger/screens/passenger_dashboard.dart';
import '../../features/driver/screens/driver_dashboard.dart';
import '../../features/syndicate/screens/syndicate_dashboard.dart';
import '../../features/station_admin/screens/station_admin_dashboard.dart';

class NavigationService {
  static Widget getDashboardForRole(String role, {UserProfile? profile}) {
    // Standardize role comparison based on database keys in handle_new_user trigger
    switch (role.toLowerCase()) {
      case 'passenger':
        return PassengerDashboard(profile: profile);
      case 'driver':
        return DriverDashboard(profile: profile);
      case 'syndicate':
        return SyndicateDashboard(profile: profile);
      case 'station_admin':
        return StationAdminDashboard(profile: profile);
      default:
        // Fallback to passenger if role is unknown
        return PassengerDashboard(profile: profile);
    }
  }
}
