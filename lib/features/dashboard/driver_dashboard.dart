import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  final List<Map<String, dynamic>> _passengers = [
    {'id': '01', 'name': 'Amadou Barry', 'ticket': '#GT-882', 'checked': true},
    {
      'id': '02',
      'name': 'Mariama Sylla',
      'ticket': '#GT-883',
      'checked': false
    },
    {'id': '03', 'name': 'Ibrahima Sow', 'ticket': '#GT-884', 'checked': false},
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0FBD0F);
    const Color backgroundColor = Color(0xFFF6F8F6);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 48, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(primaryColor),

            // Active Trip Section
            _buildActiveTrip(primaryColor),

            // Earnings Summary
            _buildEarningsSummary(primaryColor),

            // Passenger Checklist
            _buildPassengerChecklist(primaryColor),

            // Documents Section
            _buildDocumentsSection(primaryColor),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(primaryColor),
    );
  }

  Widget _buildHeader(Color primary) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primary, width: 2),
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuANJT8fs8s6TupWOrCamae6daNeq4dMLeEA4wu6aymGaWhaCUA9JKBAwPQLhlgfWUOe6THWLxWyqso3IvsnJO_ToI9QjHgttK-wgSoDa6Ed3czwFStF-Nm7pFtJWlIx8snzpzLq_bmd6bbQPO1wiJ8p1hZmuFtMS_JeeB83Ju9mMgOgeGBmrKQChCH7M_CmzJHRr6PJwA7dUCIODsNgkle7h06O05t2XFqBCx49j2xRU2ETB-P3qM7fFLq4CUcKb-ujsNaK1tw3XNc-'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                            color: primary, shape: BoxShape.circle),
                        child: const Icon(Icons.verified,
                            color: Colors.white, size: 10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mamadou Diallo',
                    style: GoogleFonts.publicSans(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.grey, size: 14),
                      Text(
                        ' Conakry, Guinée',
                        style: GoogleFonts.publicSans(
                            fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black12)),
            child: const Icon(Icons.notifications_none, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTrip(Color primary) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trajet du jour',
              style: GoogleFonts.publicSans(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuD1UVO08aPtt11pmM4844Od4exvkouGfTFroHQT8ZwO_9098BacvLIh6PXZ5s-dFKOYn4Bgp5-06VnHCyTRy3UNYLimU7egHPcgFlImeMgX2x3NT0Fmkwog3o1Wkd3pfn2g03xowPcwSEJ5Lf_R-31_lI7aFqolT5pGXyolG67obNskWe3GkHGhnC5_sH36oqMF0q7zD71MxwZHP6OS702mM2TuSgOo7E_SnXPGO1zdaSKXIaVBQRVoWXL7Wr3PzOtywl4UD_uHXyOi',
                      height: 128,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.6)
                              ]),
                        ),
                      ),
                    ),
                    const Positioned(
                      bottom: 12,
                      left: 16,
                      child: Text('Conakry → Kankan',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTripInfo(Icons.schedule, 'Départ: 08:00'),
                              const SizedBox(height: 4),
                              _buildTripInfo(Icons.group, 'Passagers: 12/15'),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('STATUT',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                              Text('Prêt',
                                  style: TextStyle(
                                      color: primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow),
                              SizedBox(width: 8),
                              Text('Démarrer trajet',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  Widget _buildEarningsSummary(Color primary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Revenus',
                  style: GoogleFonts.publicSans(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Détails',
                  style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildEarningCard(
                      'AUJOURD\'HUI', '450k GNF', primary, true)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildEarningCard(
                      'CETTE SEMAINE', '2.8M GNF', primary, false)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 128,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(0.5, primary.withOpacity(0.2)),
                _buildBar(0.75, primary.withOpacity(0.2)),
                _buildBar(0.66, primary.withOpacity(0.2)),
                _buildBar(0.33, primary.withOpacity(0.2)),
                _buildBar(0.85, primary.withOpacity(0.4)),
                _buildBar(1.0, primary),
                _buildBar(0.25, Colors.grey.withOpacity(0.2)),
              ]
                  .map((e) => Expanded(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: e)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double heightFactor, Color color) {
    return Container(
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      height: 100 * heightFactor,
    );
  }

  Widget _buildEarningCard(
      String label, String value, Color primary, bool isHighlight) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlight ? primary.withOpacity(0.1) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isHighlight ? primary.withOpacity(0.2) : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: isHighlight ? primary : Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPassengerChecklist(Color primary) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Liste des Passagers',
              style: GoogleFonts.publicSans(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ..._passengers.map((p) => _buildPassengerItem(p, primary)).toList(),
          const SizedBox(height: 12),
          Center(
              child: Text('Voir tous les passagers (12)',
                  style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildPassengerItem(Map<String, dynamic> passenger, Color primary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(passenger['id'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(passenger['name'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(passenger['ticket'],
                      style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ],
          ),
          Checkbox(
            value: passenger['checked'],
            onChanged: (v) => setState(() => passenger['checked'] = v ?? false),
            activeColor: primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(Color primary) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mes Documents',
              style: GoogleFonts.publicSans(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                _buildDocItem(Icons.badge, 'Permis de conduire', 'Validé',
                    primary, Colors.green),
                const Divider(height: 1),
                _buildDocItem(Icons.description, 'Assurance Véhicule',
                    'Expire bientôt', primary, Colors.orange),
                const Divider(height: 1),
                _buildDocItem(Icons.minor_crash, 'Contrôle Technique', 'Validé',
                    primary, Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocItem(IconData icon, String title, String status,
      Color primary, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: primary, size: 20),
              const SizedBox(width: 12),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 14)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)),
            child: Text(status,
                style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(Color primary) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border(top: BorderSide(color: Colors.black.withOpacity(0.05)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.directions_bus, 'Trajets', true, primary),
          _buildNavItem(
              Icons.account_balance_wallet, 'Revenus', false, primary),
          _buildNavItem(Icons.person, 'Profil', false, primary),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, bool isActive, Color primary) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? primary : Colors.grey),
        Text(label,
            style: TextStyle(
                color: isActive ? primary : Colors.grey,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500)),
      ],
    );
  }
}
