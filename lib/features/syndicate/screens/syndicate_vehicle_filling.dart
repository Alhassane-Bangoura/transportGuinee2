import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_assets.dart';

/// Écran de Remplissage des Véhicules pour le Syndicat
/// Correspond à trajets_places_syndicat.html
class SyndicateVehicleFilling extends StatefulWidget {
  const SyndicateVehicleFilling({super.key});

  @override
  State<SyndicateVehicleFilling> createState() => _SyndicateVehicleFillingState();
}

class _SyndicateVehicleFillingState extends State<SyndicateVehicleFilling> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(AppAssets.syndicateProfileAvatar),
          ),
        ),
        title: Text(
          'Azimuth Admin',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Text(
              'GUINEETRANSPORT',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Remplissage des véhicules',
              style: AppTextStyles.headingLarge.copyWith(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24),

            // Route Context Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  _buildRoutePoint('DÉPART', 'Conakry', Icons.location_on),
                  const Expanded(
                    child: Icon(Icons.trending_flat, color: AppColors.textSecondary, size: 24),
                  ),
                  _buildRoutePoint('DESTINATION', 'Labé', Icons.straighten, isEnd: true),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Vehicles ListView (simulated with Column for simplicity in this mockup)
            _buildTripCard(
              driverName: 'Mamadou Diallo',
              driverImg: AppAssets.driverAvatar1,
              time: '08:30 AM',
              period: 'DÉPART MATIN',
              current: 14,
              total: 20,
              progress: 0.7,
            ),
            const SizedBox(height: 16),
            _buildTripCard(
              driverName: 'Ibrahim Sow',
              driverImg: AppAssets.driverAvatar2,
              time: '10:15 AM',
              period: 'DÉPART MATIN',
              current: 19,
              total: 20,
              progress: 0.95,
              isUrgent: true,
            ),
            const SizedBox(height: 32),

            // Secondary Info Section
            Row(
              children: [
                Expanded(child: _buildInfoBox(Icons.analytics, 'Tendance', 'Forte demande le matin.', AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(child: _buildInfoBox(Icons.map, 'N1 Info', 'Circulation fluide vers Labé.', Colors.blue)),
              ],
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildRoutePoint(String label, String city, IconData icon, {bool isEnd = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isEnd) Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: isEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
            Text(city, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          ],
        ),
        if (isEnd) const SizedBox(width: 12),
        if (isEnd) Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
      ],
    );
  }

  Widget _buildTripCard({
    required String driverName,
    required String driverImg,
    required String time,
    required String period,
    required int current,
    required int total,
    required double progress,
    bool isUrgent = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 20, backgroundImage: NetworkImage(driverImg)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CHAUFFEUR', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                      Text(driverName, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: Text(time, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ),
                  const SizedBox(height: 4),
                  Text(period, style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 0.5)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Taux de remplissage', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: '$current', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary)),
                    TextSpan(text: ' / $total places', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(isUrgent ? Colors.red : AppColors.primary),
            ),
          ),
          if (isUrgent) Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('DERNIÈRE PLACE DISPONIBLE', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.red)),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('Voir places', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('Valider', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(IconData icon, String title, String desc, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 4),
          Text(desc, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 90,
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.dashboard, 'Dashboard', false),
          _buildNavItem(Icons.local_shipping, 'Fleet', false),
          _buildNavItem(Icons.route, 'Trips', true),
          _buildNavItem(Icons.person, 'Profile', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? AppColors.primary : AppColors.textSecondary, size: 24),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
