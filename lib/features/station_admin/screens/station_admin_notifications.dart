import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/station_service.dart';

class StationAdminNotifications extends StatefulWidget {
  const StationAdminNotifications({super.key});

  @override
  State<StationAdminNotifications> createState() => _StationAdminNotificationsState();
}

class _StationAdminNotificationsState extends State<StationAdminNotifications> {
  @override
  Widget build(BuildContext context) {
    final Color textPrimary = AppColors.textPrimary;
    final Color textSecondary = AppColors.textSecondary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Activités & Notifications', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: StationService.getAdminNotificationsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return Center(
              child: Text('Aucune activité récente.', style: GoogleFonts.plusJakartaSans(color: textSecondary)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildTimelineItemFromMap(notification, textPrimary, textSecondary);
            },
          );
        },
      ),
    );
  }

  Widget _buildTimelineItemFromMap(Map<String, dynamic> data, Color textTitle, Color textSub) {
    final title = data['title'] ?? 'Notification';
    final message = data['message'] ?? '';
    final createdAt = DateTime.parse(data['created_at']);
    final type = data['type'] ?? 'general';
    
    Color typeColor = Colors.blue;
    if (type == 'departure_validated') typeColor = Colors.green;
    if (type == 'new_booking') typeColor = AppColors.primary;
    if (type == 'new_trip') typeColor = Colors.orange;

    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: typeColor, shape: BoxShape.circle),
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
                      Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: textTitle)),
                      Text('${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}', 
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: textSub)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(message, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: textSub)),
                ],
              ),
            ),
          ),
        ],
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
