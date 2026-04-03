import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_assets.dart';

/// Écran de Gestion des Départs pour l'Admin de Gare
/// Correspond à gestion_depart_admin.html
class StationAdminDepartureManagement extends StatefulWidget {
  const StationAdminDepartureManagement({super.key});

  @override
  State<StationAdminDepartureManagement> createState() => _StationAdminDepartureManagementState();
}

class _StationAdminDepartureManagementState extends State<StationAdminDepartureManagement> {
  String selectedFilter = 'Tous';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.directions_bus, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GUINEE TRANSPORT',
                  style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 16),
                ),
                Text(
                  'SUPERVISION DES DÉPARTS',
                  style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: AppColors.textSecondary)),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          _buildFilterSection(),
          
          // Departures List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildDepartureCard(
                  'Mamadou Diallo',
                  'Toyota Hiace',
                  'Mamou',
                  '15 / 18',
                  'Prêt à partir',
                  Colors.green,
                  AppAssets.vehiclePreview1,
                  isReady: true,
                  paxAvatars: [
                    AppAssets.passengerAvatar1,
                    AppAssets.passengerAvatar2,
                  ],
                  extraPax: 13
                ),
                const SizedBox(height: 16),
                _buildDepartureCard(
                  'Ibrahima Bah',
                  'Coaster',
                  'Labé',
                  '22 / 30',
                  'Remplissage',
                  Colors.amber,
                  AppAssets.stationAdminHeader,
                  fillProgress: 0.73
                ),
                const SizedBox(height: 16),
                _buildDepartureCard(
                  'Abdoulaye Soumah',
                  'Toyota Hiace',
                  'Kindia',
                  '18 / 18',
                  'Complet',
                  Colors.green,
                  AppAssets.stationAdminPreview,
                  isReady: true,
                  isFull: true
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(top: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildFilterChip('Tous', '12', AppColors.primary, Colors.white),
          const SizedBox(width: 8),
          _buildFilterChip('Prêts', '5', AppColors.surface, AppColors.textSecondary, badgeColor: Colors.green),
          const SizedBox(width: 8),
          _buildFilterChip('Attente', '4', AppColors.surface, AppColors.textSecondary, badgeColor: Colors.amber),
          const SizedBox(width: 8),
          _buildFilterChip('Retard', '3', AppColors.surface, AppColors.textSecondary, badgeColor: Colors.red),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String count, Color bg, Color text, {Color? badgeColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
        border: bg == AppColors.surface ? Border.all(color: AppColors.border) : null,
      ),
      child: Row(
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: text)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: badgeColor?.withValues(alpha: 0.1) ?? Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(100)),
            child: Text(count, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: badgeColor ?? text)),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartureCard(String driver, String vehicle, String dest, String pax, String status, Color statusColor, String img, {bool isReady = false, double? fillProgress, List<String>? paxAvatars, int? extraPax, bool isFull = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100, height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(image: NetworkImage(img), fit: BoxFit.cover),
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(100)),
                    child: Text(status.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 7, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, color: AppColors.primary, size: 14),
                        const SizedBox(width: 6),
                        Text(driver, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.directions_bus, color: AppColors.textSecondary, size: 12),
                        const SizedBox(width: 4),
                        Text(vehicle, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 12),
                        const Icon(Icons.location_on, color: AppColors.primary, size: 12),
                        const SizedBox(width: 4),
                        Text(dest, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('PASSAGERS', style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                  Text(pax, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: isFull ? AppColors.primary : Colors.white)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (paxAvatars != null)
                Row(
                  children: [
                    for (var i = 0; i < paxAvatars.length; i++)
                      Align(widthFactor: 0.7, child: CircleAvatar(radius: 12, backgroundImage: NetworkImage(paxAvatars[i]))),
                    if (extraPax != null)
                      Align(
                        widthFactor: 0.7,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.background,
                          child: Text('+$extraPax', style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                        ),
                      ),
                  ],
                )
              else if (fillProgress != null)
                Expanded(
                  child: Container(
                    height: 6,
                    margin: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(100)),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: fillProgress,
                      child: Container(decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(100))),
                    ),
                  ),
                )
              else if (isFull)
                Row(
                  children: [
                    const Icon(Icons.verified, color: Colors.green, size: 14),
                    const SizedBox(width: 4),
                    Text('COMPLET', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.green)),
                  ],
                ),
              ElevatedButton.icon(
                onPressed: isReady ? () {} : null,
                icon: Icon(isReady ? Icons.check_circle : Icons.hourglass_empty, size: 14),
                label: Text(isReady ? 'Confirmer le départ' : 'En attente', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isReady ? AppColors.primary : AppColors.background,
                  foregroundColor: isReady ? Colors.white : AppColors.textSecondary,
                  elevation: isReady ? 4 : 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
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
          _buildNavItem(Icons.local_shipping, 'Départs', true),
          _buildNavItem(Icons.directions_car, 'Véhicules', false),
          _buildNavItem(Icons.analytics_outlined, 'Rapports', false),
          _buildNavItem(Icons.account_circle_outlined, 'Profil', false),
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
