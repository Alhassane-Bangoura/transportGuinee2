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
    final Color primaryColor = AppColors.primary;
    final Color textPrimary = AppColors.textPrimary;
    final Color textSecondary = AppColors.textSecondary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Rapports & Analytics', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChartSection('Départs par jour (Semaine)', _buildBarChart(primaryColor), textPrimary),
            const SizedBox(height: 24),
            _buildChartSection('Destinations les plus demandées', _buildPieChart(primaryColor), textPrimary),
            const SizedBox(height: 24),
            _buildSummaryGrid(primaryColor, textPrimary, textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(String title, Widget chart, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 24),
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }

  Widget _buildBarChart(Color color) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 20,
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 12, color: color, width: 16)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 15, color: color, width: 16)]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 8, color: color, width: 16)]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 18, color: color, width: 16)]),
          BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 14, color: color, width: 16)]),
          BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 10, color: color, width: 16)]),
          BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 16, color: color, width: 16)]),
        ],
        titlesData: FlTitlesData(show: false),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildPieChart(Color color) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(value: 40, title: 'Conakry', color: color, radius: 50, titleStyle: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 10)),
          PieChartSectionData(value: 25, title: 'Labé', color: color.withOpacity(0.7), radius: 50, titleStyle: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 10)),
          PieChartSectionData(value: 20, title: 'Mamou', color: color.withOpacity(0.4), radius: 50, titleStyle: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 10)),
          PieChartSectionData(value: 15, title: 'Autres', color: Colors.grey[300]!, radius: 50, titleStyle: GoogleFonts.plusJakartaSans(color: Colors.black, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid(Color primary, Color textTitle, Color textSub) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryItem('Total Passagers', '1 245', Icons.people, primary, textTitle, textSub),
        _buildSummaryItem('Revenus Est.', '62,2M FG', Icons.payments, Colors.green, textTitle, textSub),
        _buildSummaryItem('Taux Occupation', '84%', Icons.trending_up, Colors.orange, textTitle, textSub),
        _buildSummaryItem('Incidents', '0', Icons.report_problem, Colors.red, textTitle, textSub),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color, Color textTitle, Color textSub) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          Icon(icon, color: color, size: 20),
          const Spacer(),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: textSub)),
          Text(value, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: textTitle)),
        ],
      ),
    );
  }
}
