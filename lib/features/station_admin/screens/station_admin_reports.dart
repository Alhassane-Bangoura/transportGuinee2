import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';

class StationAdminReports extends StatefulWidget {
  const StationAdminReports({super.key});

  @override
  State<StationAdminReports> createState() => _StationAdminReportsState();
}

class _StationAdminReportsState extends State<StationAdminReports> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildPremiumHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildKeyMetrics(),
                    const SizedBox(height: 24),
                    _buildChartSection(),
                    const SizedBox(height: 24),
                    _buildPopularDestinations(),
                    const SizedBox(height: 24),
                    _buildActivityLog(),
                    const SizedBox(height: 80), // To make room for bottom nav if necessary
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('GUINEE TRANSPORT',
                    style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  ),
                  Text('STATISTIQUES ET ANALYSES',
                    style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
                  ),
                ],
              ),
            ],
          ),
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: AppColors.border)),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary, size: 24),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(10),
                ),
              ),
              Positioned(
                top: 8, right: 8,
                child: Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: AppColors.background, width: 2)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildKeyMetrics() {
    return Column(
      children: [
        _buildMetricCard(
          title: "Passagers aujourd'hui",
          value: "1 240",
          unit: "pers.",
          trend: "+12%",
          trendUp: true,
          bottomWidget: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: 0.75,
              minHeight: 6,
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildMetricCard(
          title: "Chiffre d'affaires",
          value: "8.5M",
          unit: "GNF",
          trend: "+5.4%",
          trendUp: true,
          bottomWidget: Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              Text("Performance optimale", style: GoogleFonts.plusJakartaSans(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildMetricCard(
          title: "Taux d'occupation",
          value: "88%",
          unit: "Moyen",
          trend: "Stable",
          trendUp: null, // neutral
          bottomWidget: Row(
            children: [
              _buildAvatarStack(),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: Text("+12", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800)),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarStack() {
    return SizedBox(
      width: 60,
      height: 24,
      child: Stack(
        children: [
          Positioned(left: 0, child: _buildAvatarLayer(Colors.grey[200]!)),
          Positioned(left: 15, child: _buildAvatarLayer(Colors.grey[300]!)),
          Positioned(left: 30, child: _buildAvatarLayer(Colors.grey[400]!)),
        ],
      ),
    );
  }

  Widget _buildAvatarLayer(Color color) {
    return Container(
      width: 24, height: 24,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
    );
  }

  Widget _buildMetricCard({required String title, required String value, required String unit, required String trend, required bool? trendUp, required Widget bottomWidget}) {
    Color trendBgColor;
    Color trendTextColor;
    if (trendUp == true) {
      trendBgColor = Colors.green.withOpacity(0.1);
      trendTextColor = Colors.green;
    } else if (trendUp == false) {
      trendBgColor = Colors.red.withOpacity(0.1);
      trendTextColor = Colors.red;
    } else {
      trendBgColor = AppColors.primary.withOpacity(0.1);
      trendTextColor = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: trendBgColor, borderRadius: BorderRadius.circular(100)),
                child: Text(trend, style: GoogleFonts.plusJakartaSans(color: trendTextColor, fontSize: 10, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
              const SizedBox(width: 8),
              Text(unit, style: GoogleFonts.plusJakartaSans(color: AppColors.textHint, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 16),
          bottomWidget,
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Départs par jour", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                child: Text("Cette semaine", style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 20,
                barGroups: [
                  _makeBarData(0, 12, AppColors.primary.withOpacity(0.4)),
                  _makeBarData(1, 9, AppColors.primary.withOpacity(0.4)),
                  _makeBarData(2, 17, AppColors.primary),
                  _makeBarData(3, 14, AppColors.primary.withOpacity(0.4)),
                  _makeBarData(4, 19, AppColors.primary.withOpacity(0.4)),
                  _makeBarData(5, 8, Colors.green.withOpacity(0.6)),
                  _makeBarData(6, 6, Colors.green.withOpacity(0.6)),
                ],
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(color: AppColors.textHint, fontWeight: FontWeight.bold, fontSize: 10);
                        Widget text;
                        switch (value.toInt()) {
                          case 0: text = const Text('LUN', style: style); break;
                          case 1: text = const Text('MAR', style: style); break;
                          case 2: text = const Text('MER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)); break;
                          case 3: text = const Text('JEU', style: style); break;
                          case 4: text = const Text('VEN', style: style); break;
                          case 5: text = const Text('SAM', style: style); break;
                          case 6: text = const Text('DIM', style: style); break;
                          default: text = const Text('', style: style); break;
                        }
                        return SideTitleWidget(axisSide: meta.axisSide, child: text);
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 32,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ],
    );
  }

  Widget _buildPopularDestinations() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Destinations Populaires", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          _buildDestinationItem("Conakry → Mamou", 42, AppColors.primary),
          const SizedBox(height: 16),
          _buildDestinationItem("Conakry → Labé", 28, AppColors.primary.withOpacity(0.7)),
          const SizedBox(height: 16),
          _buildDestinationItem("Kindia → Boké", 18, AppColors.primary.withOpacity(0.4)),
          const SizedBox(height: 16),
          _buildDestinationItem("Autres", 12, AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildDestinationItem(String title, int percent, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
            Text("$percent%", style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 8,
            backgroundColor: AppColors.background,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityLog() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Journal d'Activité Récent", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                Text("Voir tout", style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.background.withOpacity(0.5)),
              columnSpacing: 24,
              horizontalMargin: 20,
              dividerThickness: 1,
              columns: [
                DataColumn(label: Text('Heure', style: GoogleFonts.plusJakartaSans(color: AppColors.textHint, fontSize: 11, fontWeight: FontWeight.w800))),
                DataColumn(label: Text('Trajet / Bus', style: GoogleFonts.plusJakartaSans(color: AppColors.textHint, fontSize: 11, fontWeight: FontWeight.w800))),
                DataColumn(label: Text('Passagers', style: GoogleFonts.plusJakartaSans(color: AppColors.textHint, fontSize: 11, fontWeight: FontWeight.w800))),
                DataColumn(label: Text('Statut', style: GoogleFonts.plusJakartaSans(color: AppColors.textHint, fontSize: 11, fontWeight: FontWeight.w800))),
                DataColumn(label: Text('Revenu', style: GoogleFonts.plusJakartaSans(color: AppColors.textHint, fontSize: 11, fontWeight: FontWeight.w800))),
              ],
              rows: [
                _buildLogItem('08:45', 'CKY - LAB #004', 'Sprinter 15', '15 / 15', 'DÉPART CONFIRMÉ', Colors.green, '750,000 GNF'),
                _buildLogItem('09:12', 'CKY - MAM #012', 'Coaster 30', '28 / 30', 'EN EMBARQUEMENT', Colors.amber, '1,400,000 GNF'),
                _buildLogItem('09:30', 'CKY - BOK #008', 'Sprinter 15', '4 / 15', 'PLANIFIÉ', AppColors.textHint, '200,000 GNF'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildLogItem(String time, String bus, String type, String pax, String status, Color statusColor, String revenue) {
    return DataRow(
      cells: [
        DataCell(Text(time, style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 13))),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(bus, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              Text(type, style: GoogleFonts.plusJakartaSans(color: AppColors.textHint, fontSize: 11)),
            ],
          ),
        ),
        DataCell(Text(pax, style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
            child: Text(status, style: GoogleFonts.plusJakartaSans(color: statusColor, fontSize: 9, fontWeight: FontWeight.w900)),
          ),
        ),
        DataCell(Text(revenue, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800))),
      ],
    );
  }
}

