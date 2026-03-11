import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StationAdminPlatforms extends StatefulWidget {
  const StationAdminPlatforms({super.key});

  @override
  State<StationAdminPlatforms> createState() => _StationAdminPlatformsState();
}

class _StationAdminPlatformsState extends State<StationAdminPlatforms> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF16A249);
    const Color backgroundColor = Color(0xFFF6F8F7);
    const Color textSlate900 = Color(0xFF0F172A);
    const Color textSlate500 = Color(0xFF64748B);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(primaryColor, textSlate900),
            _buildTabs(primaryColor, textSlate500),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionTitle('Liste des Quais actifs', 'Actualisé il y a 2m', textSlate900, textSlate500),
                  const SizedBox(height: 16),
                  _buildPlatformCard(
                    'Quai 1',
                    'OCCUPÉ',
                    'Mamou',
                    '14:45',
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuD7_UawWnZmFGWyHC0t7njZIux0e2Wesu5neJG8J4993ZBWMVi6I1APyW9iu_7YEt55hYsvXMVAg4V6xrz_K3URRKzibe3nqZPyZ5iHHTYX1VmvUZxzi8RU8jH9XwITM9jCOFRNNXSmQ6PlxOvNvBBubPO0Xzq02ihZsVzX2Gq1fu4raAPE8ToZJPx5F_yPaypc2P3WItlNolos2nsMEYIQAhuNfylKl5g_SLZ4XgbYaZL0l08WcskxnUMQ0fPYQx9eOYFJhQWRxLeo',
                    primaryColor,
                    textColor: Colors.red,
                    isOccupied: true,
                  ),
                  const SizedBox(height: 16),
                  _buildPlatformCard(
                    'Quai 2',
                    'LIBRE',
                    'Labé',
                    null,
                    null,
                    primaryColor,
                    textColor: const Color(0xFF10B981),
                    isOccupied: false,
                  ),
                  const SizedBox(height: 16),
                  _buildPlatformCard(
                    'Quai 3',
                    'LIBRE',
                    'Kankan',
                    null,
                    null,
                    primaryColor,
                    textColor: const Color(0xFF10B981),
                    isOccupied: false,
                  ),
                  const SizedBox(height: 16),
                  _buildAddPlatformCard(primaryColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color primary, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: primary.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.menu, color: primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Gestion des Quais',
              style: GoogleFonts.plusJakartaSans(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(Color primary, Color subColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primary.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            _buildTabItem(0, 'Tous', '3', primary, subColor),
            _buildTabItem(1, 'Occupés', null, primary, subColor),
            _buildTabItem(2, 'Libres', null, primary, subColor),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String label, String? count, Color primary, Color subColor) {
    final bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: isSelected ? primary : subColor,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count,
                    style: GoogleFonts.plusJakartaSans(
                      color: primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle, Color textColor, Color subColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            color: subColor,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformCard(
    String id,
    String status,
    String destination,
    String? departure,
    String? image,
    Color primary, {
    required Color textColor,
    required bool isOccupied,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF64748B).withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isOccupied ? primary.withValues(alpha: 0.1) : const Color(0xFF64748B).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isOccupied ? Icons.train : Icons.meeting_room,
                      color: isOccupied ? primary : const Color(0xFF64748B).withValues(alpha: 0.4),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            id,
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF0F172A),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: textColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: GoogleFonts.plusJakartaSans(
                                color: textColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        isOccupied ? 'Destination: $destination' : 'Dernière destination: $destination',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF64748B).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit, color: Color(0xFF64748B), size: 18),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                  ),
                ],
              ),
            ],
          ),
          if (image != null) ...[
            const SizedBox(height: 12),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(image),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.2),
                    BlendMode.darken,
                  ),
                ),
              ),
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.schedule, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Départ prévu: $departure',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddPlatformCard(Color primary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: 0.2), width: 2), // Should be dashed if possible
      ),
      child: Column(
        children: [
          Icon(Icons.add_circle, color: primary.withValues(alpha: 0.6), size: 32),
          const SizedBox(height: 8),
          Text(
            'Ajouter un nouveau quai',
            style: GoogleFonts.plusJakartaSans(
              color: primary.withValues(alpha: 0.6),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
