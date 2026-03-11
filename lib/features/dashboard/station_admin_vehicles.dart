import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StationAdminVehicles extends StatefulWidget {
  const StationAdminVehicles({super.key});

  @override
  State<StationAdminVehicles> createState() => _StationAdminVehiclesState();
}

class _StationAdminVehiclesState extends State<StationAdminVehicles> {
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
                  _buildVehicleCard(
                    'Bus Mercedes (GN-1234)',
                    'En attente',
                    'Mamadou Diallo',
                    'CNTG',
                    '55 places',
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBsiWaf_n37F41gFWuegzGlcj44XjEjFWIVDqFRpja6SoVsh5xSwCI3yaxRF5WSpT1bYx7IjnrixtQWeN0odTOERpV9XDYo22zM9yoZSB7T8dUCn7tdO_LDYdFEsnIN_07Vf99LxBcLyN2lu7l8gGeR-jGeX8JwjTXXFd8cNDq1PGFiLmKKXLI6c4Om-7tRQ1kjX6q8EDPlS7ifmVJO99xRoyS6rYa9PdUcYtY_8a07b-bM2zPzEEagzVJSMXWbJ-OhjPO1c_EHi69B',
                    primaryColor,
                    statusColor: Colors.amber,
                  ),
                  const SizedBox(height: 16),
                  _buildVehicleCard(
                    'Minibus Toyota (GN-5678)',
                    'En chargement',
                    'Alpha Bah',
                    'USTG',
                    '18 places',
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBmih9vdfgyuxaAIBO4AucPiprhabZMcw5lt9nEA0SD4TUFXTHBKi1CJCrlnBZWx3HaTB2eJofXFpKCkm19_AsnUBBPFvr2WnkseDQ_c1zUDITrmSQv1Tmjx3PSr4PnbrYfO6XmuANUjkDfupTr5iu8EcYI-Ze15KQ7WYZADK0V3p9cHHcvkljkU6cfmTJsesAUxymdxA4avdGtvdCuod_CKYOgau2ER-a-Jv3I9QCeIiRO-7lDWjFJPaQhRVewLMBnpuX6b2MGxyzP',
                    primaryColor,
                    statusColor: Colors.blue,
                  ),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back)),
              Text(
                'Véhicules de la gare',
                style: GoogleFonts.plusJakartaSans(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        ],
      ),
    );
  }

  Widget _buildTabs(Color primary, Color subColor) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildTabItem(0, 'Tous', primary, subColor),
            const SizedBox(width: 24),
            _buildTabItem(1, 'En attente', primary, subColor),
            const SizedBox(width: 24),
            _buildTabItem(2, 'En chargement', primary, subColor),
            const SizedBox(width: 24),
            _buildTabItem(3, 'En trajet', primary, subColor),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String label, Color primary, Color subColor) {
    final bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: isSelected ? primary : subColor,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(
    String name,
    String status,
    String driver,
    String syndicate,
    String seats,
    String image,
    Color primary, {
    required Color statusColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.1)),
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
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.person, driver, primary),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.groups, 'Syndicat: $syndicate', primary),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.airline_seat_recline_normal, seats, primary),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.visibility, size: 18),
                            const SizedBox(width: 8),
                            const Text('Détails', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF64748B).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.block, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.verified_user, color: primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color primary) {
    return Row(
      children: [
        Icon(icon, color: primary, size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF64748B),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
