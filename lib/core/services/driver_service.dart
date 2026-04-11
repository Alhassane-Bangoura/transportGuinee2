import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import 'auth_service.dart';

class DriverService {
  static final _supabase = Supabase.instance.client;

  /// Cherche un chauffeur par son numéro de téléphone ou email
  static Future<UserProfile?> searchDriver(String query) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .or('phone.eq.$query,email.eq.$query')
          .eq('role', 'driver')
          .maybeSingle();

      if (response == null) return null;
      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error searching driver: $e');
      return null;
    }
  }

  /// Assigne un chauffeur au syndicat actuel après validation hiérarchique
  static Future<bool> assignDriverToSyndicate(UserProfile driver) async {
    try {
      final response = await AuthService.getCurrentProfile();
      if (!response.isSuccess || response.data == null || response.data!.role != 'syndicate') {
        throw Exception('Seuls les syndicats peuvent ajouter des chauffeurs.');
      }
      
      final currentUser = response.data!;

      // 1. Vérification de la station (GARE)
      if (driver.stationId != currentUser.stationId) {
        throw Exception('Ce chauffeur appartient à une autre gare (${driver.stationId}). Isolation stricte activée.');
      }

      // 2. Vérification du trajet (TRAJET)
      // On récupère les routes gérées par le syndicat depuis ses metadata (ou table syndicate_routes si dispo)
      final List<dynamic> managedRoutes = currentUser.metadata?['managed_route_ids'] ?? [];
      if (driver.routeId == null || !managedRoutes.contains(driver.routeId)) {
        throw Exception('Le trajet du chauffeur (${driver.routeId}) n\'est pas géré par votre syndicat.');
      }

      // 3. Assignation
      await _supabase.from('profiles').update({
        'syndicate_id': currentUser.id,
      }).eq('id', driver.id);

      return true;
    } catch (e) {
      print('Error assigning driver: $e');
      rethrow;
    }
  }

  /// Récupère la liste des chauffeurs rattachés au syndicat actuel
  static Future<List<Map<String, dynamic>>> getSyndicateDrivers() async {
    try {
      final response = await AuthService.getCurrentProfile();
      if (!response.isSuccess || response.data == null) return [];
      
      final currentUser = response.data!;

      final data = await _supabase
          .from('profiles')
          .select()
          .eq('role', 'driver')
          .contains('metadata', {'syndicate_id': currentUser.id});

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error fetching drivers: $e');
      return [];
    }
  }
  /// Récupère le véhicule assigné à un chauffeur
  static Future<Map<String, dynamic>?> getDriverVehicle(String driverId) async {
    try {
      final response = await _supabase
          .from('vehicles')
          .select()
          .eq('driver_id', driverId)
          .maybeSingle();
      return response;
    } catch (e) {
      print('Error fetching driver vehicle: $e');
      return null;
    }
  }
}
