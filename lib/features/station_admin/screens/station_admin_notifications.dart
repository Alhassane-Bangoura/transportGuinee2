import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class StationAdminNotifications extends StatefulWidget {
  const StationAdminNotifications({super.key});

  @override
  State<StationAdminNotifications> createState() => _StationAdminNotificationsState();
}

class _StationAdminNotificationsState extends State<StationAdminNotifications> {
  final List<Map<String, dynamic>> _activities = [
    {
      'title': 'Départ Validé',
      'subtitle': 'Syndicat Labé a validé le véhicule GN-2456 vers Conakry',
      'time': 'Il y a 2 min',
      'icon': Icons.check_circle,
      'color': Colors.green,
      'status': 'Confirmé',
    },
    {
      'title': 'Nouveau Chauffeur',
      'subtitle': 'Alpha Bah a enregistré son véhicule (Minibus Toyota)',
      'time': 'Il y a 15 min',
      'icon': Icons.person_add,
      'color': Colors.blue,
      'status': 'Enregistré',
    },
    {
      'title': 'Véhicule Complet',
      'subtitle': 'Le Bus Mercedes vers Kindia est désormais complet',
      'time': 'Il y a 45 min',
      'icon': Icons.people,
      'color': Colors.orange,
      'status': 'Prêt',
    },
    {
      'title': 'Réservation Passager',
      'subtitle': 'Un passager a réservé 2 places pour Mamou',
      'time': 'Il y a 1h',
      'icon': Icons.bookmark,
      'color': AppColors.primary,
      'status': 'En cours',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = AppColors.primary;
    final Color textPrimary = AppColors.textPrimary;
    final Color textSecondary = AppColors.textSecondary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Activités & Notifications', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          final activity = _activities[index];
          return _buildTimelineItem(activity, primaryColor, textPrimary, textSecondary);
        },
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> activity, Color primary, Color textTitle, Color textSub) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: activity['color'], shape: BoxShape.circle),
              ),
              Expanded(
                child: Container(width: 2, color: Colors.grey[200]),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(activity['title'], style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: textTitle)),
                      Text(activity['time'], style: GoogleFonts.plusJakartaSans(fontSize: 12, color: textSub)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(activity['subtitle'], style: GoogleFonts.plusJakartaSans(fontSize: 13, color: textSub)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: activity['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      activity['status'],
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: activity['color']),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
