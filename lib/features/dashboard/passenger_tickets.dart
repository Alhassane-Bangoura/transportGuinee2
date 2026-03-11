import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PassengerTickets extends StatefulWidget {
  const PassengerTickets({super.key});

  @override
  State<PassengerTickets> createState() => _PassengerTicketsState();
}

class _PassengerTicketsState extends State<PassengerTickets> {
  String _selectedFilter = 'Actifs';

  final List<Map<String, dynamic>> _allTickets = [
    {
      'from': 'Conakry',
      'to': 'Labé',
      'station': 'Gare de Madina',
      'date': '24 Oct 2023',
      'time': '08:00 AM',
      'seat': '12A (Fenêtre)',
      'price': '150.000 GNF',
      'status': 'Confirmé',
      'isActif': true,
    },
    {
      'from': 'Conakry',
      'to': 'Kankan',
      'station': 'Gare de Matam',
      'date': '28 Oct 2023',
      'time': '07:30 AM',
      'seat': '05C (Allée)',
      'price': '200.000 GNF',
      'status': 'Confirmé',
      'isActif': true,
    },
    {
      'from': 'Labé',
      'to': 'Conakry',
      'station': 'Gare Centrale',
      'date': '15 Oct 2023',
      'time': '07:00 AM',
      'seat': '04C (Allée)',
      'price': '150.000 GNF',
      'status': 'Terminé',
      'isActif': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0FBD0F);
    const Color backgroundColor = Color(0xFFF6F8F6);
    const Color textSlate900 = Color(0xFF0F172A);

    final filteredTickets = _allTickets.where((ticket) {
      if (_selectedFilter == 'Actifs') return ticket['isActif'] == true;
      return ticket['isActif'] == false;
    }).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Custom Header
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 8),
            decoration: BoxDecoration(
              color: backgroundColor.withValues(alpha: 0.8),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildIconButton(Icons.arrow_back),
                      Expanded(
                        child: Text(
                          'Mes Billets',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textSlate900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40), // Spacing for balance
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildFilterTabs(primaryColor),
              ],
            ),
          ),
          Expanded(
            child: filteredTickets.isEmpty
                ? _buildEmptyState(textSlate900)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: filteredTickets.length,
                    itemBuilder: (context, index) {
                      final ticket = filteredTickets[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: TicketCard(
                          from: ticket['from'],
                          to: ticket['to'],
                          station: ticket['station'],
                          date: ticket['date'],
                          time: ticket['time'],
                          seat: ticket['seat'],
                          price: ticket['price'],
                          status: ticket['status'],
                          primaryColor: primaryColor,
                          isActif: ticket['isActif'],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
      ),
      child: Center(
        child: Icon(icon, color: const Color(0xFF0F172A), size: 24),
      ),
    );
  }

  Widget _buildFilterTabs(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildTab('Actifs', primaryColor),
            _buildTab('Historique', primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, Color primaryColor) {
    bool isActive = _selectedFilter == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = title),
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isActive ? primaryColor : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.confirmation_number_outlined,
              size: 64, color: textColor.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            'Aucun billet trouvé',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: textColor.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class TicketCard extends StatelessWidget {
  final String from;
  final String to;
  final String station;
  final String date;
  final String time;
  final String seat;
  final String price;
  final String status;
  final Color primaryColor;
  final bool isActif;

  const TicketCard({
    super.key,
    required this.from,
    required this.to,
    required this.station,
    required this.date,
    required this.time,
    required this.seat,
    required this.price,
    required this.status,
    required this.primaryColor,
    required this.isActif,
  });

  @override
  Widget build(BuildContext context) {
    final Color textSlate900 = const Color(0xFF0F172A);
    final Color textSlate500 = const Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          // Section Trajet
          _buildDashedDivider(isTop: true),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('TRAJET'),
                    const SizedBox(height: 4),
                    _buildRouteTitle(textSlate900),
                    Text(
                      station,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: textSlate500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.directions_bus, color: primaryColor, size: 24),
                ),
              ],
            ),
          ),

          // Section Infos (Grisé)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC).withValues(alpha: 0.5),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildInfoItem('DATE', date)),
                    Expanded(child: _buildInfoItem('HEURE', time)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildInfoItem('SIÈGE', seat)),
                    Expanded(
                      child: isActif && price != 'Confirmé'
                          ? _buildInfoItem('PRIX', price)
                          : _buildInfoStatus('STATUT', status, isActif),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Section QR / Action
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              _buildDashedDivider(isTop: false),
              // Cutouts
              Positioned(
                left: -12,
                top: -12,
                child: _buildCircleCutout(),
              ),
              Positioned(
                right: -12,
                top: -12,
                child: _buildCircleCutout(),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: isActif && price == '150.000 GNF' // Only one has QR in mockup
                ? _buildActiveActions(primaryColor)
                : _buildReservationDetails(primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF64748B),
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildRouteTitle(Color textColor) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        children: [
          TextSpan(text: from),
          TextSpan(
            text: ' → ',
            style: TextStyle(color: primaryColor),
          ),
          TextSpan(text: to),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoStatus(String label, String value, bool isActif) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isActif ? primaryColor : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildDashedDivider({required bool isTop}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: CustomPaint(
        painter: DashedLinePainter(
          color: const Color(0xFFE2E8F0),
        ),
        child: Container(height: 1),
      ),
    );
  }

  Widget _buildCircleCutout() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F6), // Matches Background
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
      ),
    );
  }

  Widget _buildActiveActions(Color primary) {
    return Column(
      children: [
        Container(
          width: 128,
          height: 128,
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.5)),
          ),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAyQnwRqRz9CG2Cw1eID561wyjrJ1UxCZDNnVbenc7q3ws0E0Bh0Ek9baEPXYNRlwMMxogDvpRcnRyrYB1rsP2DgCG58Ic3-0KaLhQEzYZOYp95ecwzpHrWAgb-p8TkpB7o4amkUf36RPisXbYAVCB7Z8N1V6GrR8QLkzGiwMzw0vGr3JOO2bfWceEodieR_po-VvlD59PnJ9KyDj2Y7C-edPTMXcuDVY0mDedjgRJsLa78TnOFdb0ulHz5SbqRn6zaHVFraXlP25-Z'),
                fit: BoxFit.cover,
                opacity: 0.8,
              ),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Afficher le Billet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: primary.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReservationDetails(Color primary) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE8F9E8),
          foregroundColor: primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: primary.withValues(alpha: 0.1)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Détails de la Réservation',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width.isInfinite) return; // Sécurité anti-boucle infinie

    double dashWidth = 5, dashSpace = 5, startX = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    
    int maxDashes = 1000;
    int count = 0;
    
    while (startX < size.width && count < maxDashes) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
      count++;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
