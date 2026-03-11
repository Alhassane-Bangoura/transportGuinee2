import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SyndicateDriversPage extends StatelessWidget {
  const SyndicateDriversPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF16A249);
    const Color backgroundColor = Color(0xFFF6F8F7);
    const Color textSlate900 = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(primaryColor, textSlate900),
            _buildFilters(primaryColor),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildDriverCard(
                    'Jean Dupont',
                    'CH-8829',
                    'Nord-Sud (Quartier A)',
                    'ACTIF',
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBKrYeJ94YZ_568WSHB8Cz6WPtE3S_SrnPLpnuKYngEcSl0t2_naYeVTW7O29BnSlcWKKlL5ipxiLI5jmRp6NuQBjAmxjg5j3uWZyqX_DVScDc0811QXyfgE2SeGhs2T0Gdfodjid0z3vDt3o77UB-FbIOeokWUT7NEXb6_ak5TKZG6G3SA-pLttOQqApARlaDGr3lJJdwxRLnndJDUVu1eizB-h0GtPEvWOc-bShXAQniEoE_E7zxvhRvNg55tCT4JS7tkG91mKFtH',
                    primaryColor,
                    true,
                  ),
                  const SizedBox(height: 16),
                  _buildDriverCard(
                    'Marc Lavoine',
                    'CH-4210',
                    'Express Est-Ouest',
                    'SUSPENDU',
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCi1fPFIki_GlEm20wcw-S_W36Pih73bT6Mofzz2edSrWR4dbgTZEjsJ-d18Be-_sVvVDqzXZluIoBLNEO-wJGD6MYrchJ4EbOX-Nr1JcaoK8qdIZ_Tn6GxEJekD7R9GRd36hmZjOp1LKFEwrHt3vpvv2ceFHIYzgVIfxIrwXOT_sEFUejVIMw3wn8g-eJ-EDb9_uRtw0UJG9h32LzIyX5j8i8kqv75Jx0z3H7WBVoAY2Owlhoh_okfpyoUAyCpLAEsvCobJXgEJAmN',
                    const Color(0xFF94748B),
                    false,
                  ),
                  const SizedBox(height: 16),
                  _buildDriverCard(
                    'Sarah Cohen',
                    'CH-9901',
                    'Circulaire Centre-Ville',
                    'ACTIF',
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCN5QD2K6DVlqlI0HAw_hKm2a_h4vPrUJhjv7MCcBfyhgPH7bL8XnJVyM-h_uy-T7gzSIN1ZDHJ9IfzRPo5-duBT2TrSRRAq-_AbaM-gV81i7WK0TUNKQcXPgRWkTV_zYagbuP297zaepvktEZBhmCaIaGt6FFECFRTsQPzc5nBxv5ZarkLYjLj_9phuxOZlPo6dBFMTXgL2_bkuIhv5-6lwXjaqZZ-ndfvz5cSsBYyjVm99dfGuxqLnSLR0hgyglV1QXmbPyhBLBbH',
                    primaryColor,
                    true,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.arrow_back, color: primary),
              ),
              Text(
                'Chauffeurs du syndicat',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search, color: primary),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(Color primary) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('Tous', true, primary),
          const SizedBox(width: 12),
          _buildFilterChip('Actifs', false, primary),
          const SizedBox(width: 12),
          _buildFilterChip('Suspendus', false, primary),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive, Color primary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? primary : primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: primary.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          color: isActive ? Colors.white : primary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDriverCard(String name, String id, String line, String status,
      String img, Color statusColor, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF16A249).withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  img,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  color: isActive ? null : Colors.grey,
                  colorBlendMode: isActive ? null : BlendMode.saturation,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF16A249).withValues(alpha: 0.1)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status,
                            style: GoogleFonts.plusJakartaSans(
                              color: isActive
                                  ? const Color(0xFF16A249)
                                  : Colors.grey[600],
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          'ID: $id',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF94A3B8),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.route,
                            size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(
                          'Ligne: $line',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionBtn(
                  Icons.person,
                  'Voir profil',
                  const Color(0xFF16A249).withValues(alpha: 0.1),
                  const Color(0xFF16A249),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: isActive
                    ? _buildActionBtn(
                        Icons.block,
                        'Suspendre',
                        const Color(0xFFF1F5F9),
                        const Color(0xFF64748B),
                      )
                    : _buildActionBtn(
                        Icons.check_circle,
                        'Activer',
                        const Color(0xFF16A249),
                        Colors.white,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(
      IconData icon, String label, Color bgColor, Color textColor) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
