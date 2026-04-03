import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';

class SyndicateDriversPage extends StatefulWidget {
  const SyndicateDriversPage({super.key});

  @override
  State<SyndicateDriversPage> createState() => _SyndicateDriversPageState();
}

class _SyndicateDriversPageState extends State<SyndicateDriversPage> {

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = AppColors.background;
    const Color subColor = AppColors.textSecondary;
    final Color primaryColor = AppColors.primary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          _buildPremiumHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              children: [
                _buildStatsGrid(primaryColor),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('LISTE DES CHAUFFEURS', style: GoogleFonts.plusJakartaSans(color: subColor, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                    IconButton(onPressed: () {}, icon: Icon(Icons.filter_list_rounded, color: primaryColor, size: 20)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildModernDriverCard(
                  'Moussa Diallo',
                  '+224 620 45 88 12',
                  'Renault Kerax 440',
                  'RC-7782-A',
                  'Conakry → Mamou',
                  'ACTIF',
                  Colors.green,
                  AppAssets.driverAvatar,
                ),
                const SizedBox(height: 16),
                _buildModernDriverCard(
                  'Abdoulaye Sow',
                  '+224 621 12 33 00',
                  'Mercedes Actros',
                  'RC-0912-B',
                  'Repos (Dernier: Labé)',
                  'REPOS',
                  Colors.amber,
                  AppAssets.profilePlaceholder,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {},
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 36),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AZIMUTH ADMIN', style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.5)),
                  Text('GESTION DES PARTENAIRES', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                ],
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 2)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.network(AppAssets.profileAdmin, fit: BoxFit.cover),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Color primary) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildStatCard('TOTAL', '42', Icons.group_outlined, primary),
        _buildStatCard('ACTIFS', '31', Icons.check_circle_outline_rounded, Colors.green),
        _buildStatCard('REPOS', '09', Icons.nightlight_round, Colors.amber),
        _buildStatCard('SUSPENDU', '02', Icons.warning_amber_rounded, Colors.red),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
              Text(label, style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernDriverCard(String name, String phone, String vehicle, String plate, String route, String status, Color statusColor, String img) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(image: NetworkImage(img), fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 18, height: 18,
                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle, border: Border.all(color: AppColors.surface, width: 3)),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text(status, style: GoogleFonts.plusJakartaSans(color: statusColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                        ),
                      ],
                    ),
                    Text(phone, style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.background.withOpacity(0.5), borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined, color: AppColors.textSecondary, size: 16),
                    const SizedBox(width: 8),
                    Text(vehicle, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
                Text(plate, style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.route_outlined, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text(route, style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
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
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('MODIFIER', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1)),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.block_rounded, color: Colors.red, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

