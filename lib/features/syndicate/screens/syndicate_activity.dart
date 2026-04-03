import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_assets.dart';

/// Écran d'Activité du Trajet pour le Syndicat
/// Correspond à actiité_trajet_syndicat.html
class SyndicateActivity extends StatefulWidget {
  const SyndicateActivity({super.key});

  @override
  State<SyndicateActivity> createState() => _SyndicateActivityState();
}

class _SyndicateActivityState extends State<SyndicateActivity> {
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
            backgroundImage: NetworkImage(AppAssets.syndicateActivityAvatar),
          ),
        ),
        title: Text(
          'GuineeTransport',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -1,
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
            // AI Tips Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.lightbulb, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Optimisation IA du planning', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary)),
                        const SizedBox(height: 4),
                        Text(
                          'Le flux passager vers Conakry est en hausse de 15%. Nous recommandons d\'avancer le départ du Sprinter CR-402 de 20 minutes.',
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Page Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SUIVI DES DÉPARTS', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.primary.withValues(alpha: 0.6), letterSpacing: 1.5)),
                    const SizedBox(height: 4),
                    Text('Activité du Trajet', style: AppTextStyles.headingLarge.copyWith(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text('Filtrer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Vehicles Grid (Simulated with Column)
            _buildVehicleCard(
              model: 'Sprinter - Mercedes Benz',
              plate: 'RC-9021-B',
              current: 12,
              total: 15,
              progress: 0.8,
              driverName: 'Moussa Camara',
              driverImg: AppAssets.driverActivityAvatar,
              status: 'PRÊT À PARTIR',
              statusColor: Colors.green,
              imgUrl: AppAssets.vehicleInterior1,
            ),
            const SizedBox(height: 20),
            _buildVehicleCard(
              model: 'Toyota Hiace',
              plate: 'RC-4412-A',
              current: 8,
              total: 18,
              progress: 0.44,
              driverName: 'Ibrahima Diallo',
              driverImg: AppAssets.driverAvatar3,
              status: 'EN ATTENTE',
              statusColor: Colors.amber,
              imgUrl: AppAssets.vehicleInterior2,
            ),

            const SizedBox(height: 48),
            // Summary Stats
            Text('Récapitulatif du jour', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatBox(Icons.done_all, '24', 'VALIDÉS', Colors.blue),
                _buildStatBox(Icons.schedule, '07', 'EN ATTENTE', Colors.amber),
                _buildStatBox(Icons.speed, '92%', 'PONCTUALITÉ', Colors.green),
                _buildStatBox(Icons.payments, '1.2M', 'GNF (RECETTE)', AppColors.primary),
              ],
            ),

            const SizedBox(height: 48),
            // History Section
            Text('Derniers départs validés', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
              child: Column(
                children: [
                  _buildHistoryRow('Sprinter RC-112-C', 'Mamou', '10:45', true),
                  const Divider(height: 1, color: AppColors.border),
                  _buildHistoryRow('Coaster RC-885-A', 'Labé', '09:15', false),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildVehicleCard({
    required String model,
    required String plate,
    required int current,
    required int total,
    required double progress,
    required String driverName,
    required String driverImg,
    required String status,
    required Color statusColor,
    required String imgUrl,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(imgUrl, height: 160, width: double.infinity, fit: BoxFit.cover),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(100)),
                  child: Text(status, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
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
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(model, style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                        Text('Matricule: $plate', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('$current/$total', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
                        Text('SIÈGES', style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: AppColors.background, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 20, backgroundImage: NetworkImage(driverImg)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Chauffeur', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textSecondary)),
                          Text(driverName, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                        ],
                      ),
                      const Spacer(),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.call, color: AppColors.primary)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: status == 'PRÊT À PARTIR' ? AppColors.primary : AppColors.surface,
                      foregroundColor: status == 'PRÊT À PARTIR' ? Colors.white : AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: status == 'PRÊT À PARTIR' ? Colors.transparent : AppColors.border)),
                      elevation: status == 'PRÊT À PARTIR' ? 5 : 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(status == 'PRÊT À PARTIR' ? 'Valider départ' : 'En attente de passagers', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                        const SizedBox(width: 8),
                        Icon(status == 'PRÊT À PARTIR' ? Icons.local_shipping : Icons.group, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const Spacer(),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(String title, String destination, String time, bool isFirst) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.local_shipping, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
              Text('Destination: $destination', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: Text('VALIDÉ', style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.primary)),
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
          _buildNavItem(Icons.dashboard_outlined, 'Dashboard', false),
          _buildNavItem(Icons.local_shipping_outlined, 'Chauffeurs', false),
          _buildNavItem(Icons.route, 'Trajets', true),
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
