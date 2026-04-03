import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_assets.dart';

/// Écran de Rapport d'Activité pour l'Administrateur de Gare
/// Correspond à rapport_activité_admin.html
class StationAdminReport extends StatefulWidget {
  const StationAdminReport({super.key});

  @override
  State<StationAdminReport> createState() => _StationAdminReportState();
}

class _StationAdminReportState extends State<StationAdminReport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.8),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.analytics, color: Colors.white, size: 20),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              'STATISTIQUES ET ANALYSES',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary)),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(AppAssets.reportAdminAvatar),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Key Metrics Row
            Row(
              children: [
                Expanded(child: _buildMetricCard('Passagers', '1,240', '+12%', AppColors.primary, 'pers.', 0.75)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildMetricCard('Revenus', '8.5M', '+5.4%', Colors.green, 'GNF', 0, isTrend: true)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard('Occupation', '88%', 'Stable', AppColors.primary, 'Moyen', 0, isAvatars: true)),
              ],
            ),
            const SizedBox(height: 32),

            // Charts Section
            _buildChartSection(),
            const SizedBox(height: 24),
            _buildPopularDestinations(),

            const SizedBox(height: 32),
            // Detailed Activity Log
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Journal d\'Activité Récent', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                TextButton(onPressed: () {}, child: const Text('Voir tout', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 12),
            _buildActivityLog(),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildMetricCard(String label, String value, String change, Color color, String unit, double progress, {bool isTrend = false, bool isAvatars = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(100)),
                child: Text(change, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: color)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(width: 4),
              Text(unit, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          if (progress > 0) ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: AppColors.background, valueColor: AlwaysStoppedAnimation<Color>(color)),
          ),
          if (isTrend) Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.green, size: 14),
              const SizedBox(width: 4),
              Text('Performance optimale', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.green)),
            ],
          ),
          if (isAvatars) Row(
            children: [
              ...List.generate(3, (i) => Align(
                widthFactor: 0.7,
                child: CircleAvatar(radius: 10, backgroundColor: Colors.grey[400 + (i * 100)]),
              )),
              Align(
                widthFactor: 0.7,
                child: Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: AppColors.surface, width: 2)),
                  child: const Center(child: Text('+12', style: TextStyle(fontSize: 7, color: Colors.white, fontWeight: FontWeight.bold))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Départs par jour', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                child: const Text('Cette semaine', style: TextStyle(fontSize: 10, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar('LUN', 0.6, false),
                _buildBar('MAR', 0.45, false),
                _buildBar('MER', 0.85, true),
                _buildBar('JEU', 0.7, false),
                _buildBar('VEN', 0.95, false),
                _buildBar('SAM', 0.4, false),
                _buildBar('DIM', 0.3, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String day, double height, bool isSelected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: 100 * height,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildPopularDestinations() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Destinations Populaires', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 20),
          _buildDestProgress('Conakry → Mamou', 0.42),
          _buildDestProgress('Conakry → Labé', 0.28),
          _buildDestProgress('Kindia → Boké', 0.18),
          _buildDestProgress('Autres', 0.12, isOther: true),
        ],
      ),
    );
  }

  Widget _buildDestProgress(String label, double progress, {bool isOther = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: isOther ? AppColors.textSecondary : Colors.white)),
              Text('${(progress * 100).toInt()}%', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: isOther ? AppColors.textSecondary : AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: AppColors.background, valueColor: AlwaysStoppedAnimation<Color>(isOther ? AppColors.border : AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLog() {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          _buildLogHeader(),
          _buildLogRow('08:45', 'CKY - LAB #004', 'Sprinter 15 places', '15 / 15', 'DÉPART CONFIRMÉ', Colors.green, '750,000'),
          _buildLogRow('09:12', 'CKY - MAM #012', 'Coaster 30 places', '28 / 30', 'EMBARQUEMENT', Colors.amber, '1,400,000'),
          _buildLogRow('09:30', 'CKY - BOK #008', 'Sprinter 15 places', '4 / 15', 'PLANIFIÉ', AppColors.textSecondary, '200,000'),
        ],
      ),
    );
  }

  Widget _buildLogHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Row(
        children: [
          const Expanded(flex: 1, child: Text('HEURE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textSecondary))),
          const Expanded(flex: 3, child: Text('TRAJET / BUS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textSecondary))),
          const Expanded(flex: 2, child: Text('STATUT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textSecondary))),
          const Expanded(flex: 2, child: Text('REVENU', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textSecondary))),
        ],
      ),
    );
  }

  Widget _buildLogRow(String time, String route, String bus, String pax, String status, Color statusColor, String revenue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(time, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          Expanded(flex: 3, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(route, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
              Text(bus, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            ],
          )),
          Expanded(flex: 2, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(status, style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: statusColor), textAlign: TextAlign.center),
          )),
          Expanded(flex: 2, child: Text('$revenue GNF', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white), textAlign: TextAlign.right)),
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
          _buildNavItem(Icons.directions_bus_outlined, 'Trajets', false),
          _buildNavItem(Icons.bar_chart, 'Rapports', true),
          _buildNavItem(Icons.person_outline, 'Staff', false),
          _buildNavItem(Icons.settings_outlined, 'Réglages', false),
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
