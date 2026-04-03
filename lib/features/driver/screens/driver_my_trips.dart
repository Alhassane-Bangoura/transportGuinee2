import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Écran des Trajets du Chauffeur
/// Correspond à mes_trajet_chauffeurs.html
class DriverMyTrips extends StatefulWidget {
  const DriverMyTrips({super.key});

  @override
  State<DriverMyTrips> createState() => _DriverMyTripsState();
}

class _DriverMyTripsState extends State<DriverMyTrips> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.primary),
          onPressed: () {},
        ),
        title: Column(
          children: [
            Text(
              'GUINEE TRANSPORT',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'SUIVEZ VOS TRAJETS',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mes Trajets du jour',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '4 trajets',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildTripCard(
              route: 'Conakry → Kindia',
              time: '07:00 AM',
              type: 'Bus VIP',
              passengers: 24,
              imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDaVAZX1jnwQpN4eOKAgkZWnRXVeSU56lbc-SMAQoyB76qyTCKs_MlkGGn5kBFdl-h8ymWPOiPEkuRjRQ11fdxY3yO1S1yX42IAlP4lozc_irBi7WgY4y7h5ottQ_Z0KsJXA_k_MiZzvBYgdm6C9OPvE2wXqjKRI_PGh7Bi45yx0kyLVPyG4XqkWtyYHb3V0rXv9xJwB2g1QKyUE3bit3NKsSeO4bqOrnqBNzFz7_kEV3wfLohCsElBNI9tXfiJj9J7e_avaTpZ-18M',
              status: 'EN COURS',
              statusColor: AppColors.primary,
            ),
            const SizedBox(height: 16),
            _buildTripCard(
              route: 'Kindia → Conakry',
              time: '02:00 PM',
              type: 'Bus VIP',
              passengers: 20,
              imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDq4VDL0470zXGpT9sBH46HEhda1MKiPevxYjKkGHKV9xOwDi50LzQ_bOCAsC5_Uc1lL_NjSNZjxqHT-4OxORMfwR3ESsHrP7KM6Jo1PZsSoyCCLHX9aLvylnGXQ_osISeZaFs7wYUNK-9P4whVtg8dgLDsbQEjUMevurGp0zoUI5CjoX9Nannoz0Gm2ztg5o44sdzYwKlOmBbmYL8Byq0Dqu67ZQbccjNA_OauIcq9W4N56ScLDB5e-FcNDVjFjlv7wVZbnUIAQWdk',
              status: 'PROGRAMMÉE',
              statusColor: AppColors.textSecondary,
              opacity: 0.8,
            ),
            const SizedBox(height: 16),
            _buildTripCard(
              route: 'Conakry → Mamou',
              time: '04:30 PM',
              type: 'Bus Standard',
              passengers: 15,
              imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCX_jfIBjaFFHKQjgUSV82V7-96bSfX0n0SuXLMNqsulJc3TyjJWCNpOI-rJo6jNNfWY-NXpMwSUlq7IX07JeMGqTCTe_lqjdIaDr0Nb4MWrc8oi60XTlO3rMS46sOGgT9CRXWgRIWYmsRqeOGfkqV6RusVSJKQsmPPqN3FJwHsqI1TlFzvbTmTSziXfvJf9uXbld5Lc6BtjS1RogX0rs5_UyaxByOg9xpA-q6gGKLWiKGcnvLKhQtNve2y_qWknzsmLXYrgpKQF8nP',
              status: 'PROGRAMMÉE',
              statusColor: AppColors.textSecondary,
              opacity: 0.8,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTripCard({
    required String route,
    required String time,
    required String type,
    required int passengers,
    required String imgUrl,
    required String status,
    required Color statusColor,
    double opacity = 1.0,
  }) {
    return Opacity(
      opacity: opacity,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(imgUrl, height: 130, width: double.infinity, fit: BoxFit.cover),
                ),
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            route,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                '$time • $type',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$passengers',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'PASSAGERS',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textSecondary,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text('Voir les passagers', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.map, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Accueil', false),
          _buildNavItem(Icons.route, 'Trajets', true),
          _buildNavItem(Icons.group, 'Équipage', false),
          _buildNavItem(Icons.person, 'Profil', false),
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
