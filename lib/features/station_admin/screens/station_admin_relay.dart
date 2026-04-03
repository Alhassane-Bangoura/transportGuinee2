import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/station_service.dart';
import '../../../core/services/auth_service.dart';

class StationAdminRelayScreen extends StatefulWidget {
  const StationAdminRelayScreen({super.key});

  @override
  State<StationAdminRelayScreen> createState() => _StationAdminRelayScreenState();
}

class _StationAdminRelayScreenState extends State<StationAdminRelayScreen> {
  List<Map<String, dynamic>> _inactiveSyndicates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final authResponse = await AuthService.getCurrentProfile();
      final profile = authResponse.data;
      if (profile != null && profile.stationId != null) {
        final syndResponse = await StationService.getStationSyndicates(profile.stationId!);
        if (mounted) {
          setState(() {
            final allSyndicates = syndResponse.data ?? [];
            _inactiveSyndicates = allSyndicates.where((s) => s['is_active'] == false || s['status'] == 'Inactif').toList();
            _isLoading = false;
          });
          if (!syndResponse.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(syndResponse.message)),
            );
          }
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading relay data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Relais Admin / Urgence', 
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_rounded),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _inactiveSyndicates.isEmpty
              ? _buildEmptyState()
              : _buildList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_rounded, size: 80, color: Colors.green.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            Text(
              'Tout est sous contrôle',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tous les syndicats de votre gare sont actuellement actifs. Aucune intervention relais n\'est nécessaire.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.orange.withValues(alpha: 0.1),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Certains syndicats sont inactifs. Vous pouvez superviser leurs opérations temporairement.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[800],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _inactiveSyndicates.length,
            itemBuilder: (context, index) {
              final syndicate = _inactiveSyndicates[index];
              return _buildSyndicateRelayCard(syndicate);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSyndicateRelayCard(Map<String, dynamic> syndicate) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        title: Text(
          syndicate['name'],
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          'Inactif • ${syndicate['driver_count'] ?? 0} chauffeurs orphelins',
          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.red),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.business, color: Colors.red, size: 20),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildRelayAction(
                  'Voir les départs',
                  'Gérer les validations prioritaires',
                  Icons.departure_board,
                  () {
                     // Navigation vers les départs filtrés (à implémenter si besoin d'un écran spécifique)
                  },
                ),
                const Divider(),
                _buildRelayAction(
                  'Contacter les chauffeurs',
                  'Accéder à la liste des contacts',
                  Icons.people,
                  () {
                    // Action
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Action pour marquer comme résolu ou notifier le syndicat
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Prendre le contrôle total', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelayAction(String title, String sub, IconData icon, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(sub, style: GoogleFonts.plusJakartaSans(fontSize: 11)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }
}
