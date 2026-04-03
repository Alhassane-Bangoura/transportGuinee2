import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_assets.dart';

/// Écran de Gestion des Chauffeurs pour le Syndicat
/// Correspond à gestion_chauffeurs_syndicat.html
class SyndicateDriverManagement extends StatefulWidget {
  const SyndicateDriverManagement({super.key});

  @override
  State<SyndicateDriverManagement> createState() => _SyndicateDriverManagementState();
}

class _SyndicateDriverManagementState extends State<SyndicateDriverManagement> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(AppAssets.profileAdmin),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AZIMUTH ADMIN',
                  style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 16),
                ),
                Text(
                  'GESTION DES PARTENAIRES',
                  style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestion des Chauffeurs',
              style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Supervisez votre équipe de conducteurs et gérez les affectations de flotte en temps réel.',
              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),

            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  icon: const Icon(Icons.search, color: AppColors.textSecondary),
                  hintText: 'Rechercher un chauffeur...',
                  hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5)),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Stats Grid
            Row(
              children: [
                Expanded(child: _buildStatCard(Icons.group, '42', 'TOTAL', Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(Icons.check_circle, '31', 'ACTIF', Colors.green)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard(Icons.event_busy, '09', 'REPOS', Colors.amber)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(Icons.warning, '02', 'SUSPENDU', Colors.red)),
              ],
            ),
            const SizedBox(height: 40),

            // Driver Grid (Simulated with Column for simplicity in this artifact)
            _buildDriverCard(
              'Moussa Diallo', 
              '+224 620 45 88 12', 
              'Actif', 
              Colors.green, 
              'Renault Kerax 440', 
              'RC-7782-A', 
              'Conakry → Mamou',
              AppAssets.driverAvatar3,
              Icons.local_shipping
            ),
            const SizedBox(height: 20),
            _buildDriverCard(
              'Abdoulaye Sow', 
              '+224 621 12 33 00', 
              'Repos', 
              Colors.amber, 
              'Mercedes Actros', 
              'RC-0912-B', 
              'Dernier trajet: Labé (2j)',
              AppAssets.driverAvatar4,
              Icons.local_shipping,
              isHistory: true
            ),
            const SizedBox(height: 20),
            _buildDriverCard(
              'Mariama Camara', 
              '+224 669 88 11 22', 
              'Actif', 
              Colors.green, 
              'Toyota Coaster', 
              'RC-4456-C', 
              'Conakry → Kindia',
              AppAssets.driverAvatar5,
              Icons.directions_bus
            ),
            
            const SizedBox(height: 100),
          ],
        ),
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

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
              Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(String name, String phone, String status, Color statusColor, String vehicle, String plate, String route, String img, IconData vehicleIcon, {bool isHistory = false}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), image: DecorationImage(image: NetworkImage(img), fit: BoxFit.cover)),
                      ),
                      Positioned(
                        bottom: -2, right: -2,
                        child: Container(width: 16, height: 16, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle, border: Border.all(color: AppColors.surface, width: 3))),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                      Text(phone, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(100)),
                child: Text(status.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.w900, color: statusColor, letterSpacing: 1)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(vehicleIcon, color: AppColors.textSecondary, size: 16),
                    const SizedBox(width: 12),
                    Text(vehicle, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
                Text(plate, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(isHistory ? Icons.history : Icons.route, color: isHistory ? AppColors.textSecondary.withValues(alpha: 0.5) : AppColors.primary, size: 16),
              const SizedBox(width: 12),
              Text(route, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: isHistory ? AppColors.textSecondary : Colors.white)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Modifier', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                child: IconButton(onPressed: () {}, icon: const Icon(Icons.block, color: AppColors.textSecondary, size: 20)),
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
          _buildNavItem(Icons.dashboard_outlined, 'Accueil', false),
          _buildNavItem(Icons.local_shipping, 'Fleet', true),
          _buildNavItem(Icons.route, 'Trajets', false),
          _buildNavItem(Icons.person_outline, 'Profil', false),
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
