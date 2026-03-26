import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
// Removed unused app_text_styles import

class PassengerTrips extends StatefulWidget {
  const PassengerTrips({super.key});

  @override
  State<PassengerTrips> createState() => _PassengerTripsState();
}

class _PassengerTripsState extends State<PassengerTrips> {
  final TextEditingController _departureController =
      TextEditingController(text: 'Conakry');
  final TextEditingController _arrivalController = TextEditingController();

  @override
  void dispose() {
    _departureController.dispose();
    _arrivalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = AppColors.primary;
    final Color backgroundColor = AppColors.background;
    final Color textSlate900 = AppColors.onBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Header & Search Area
          _buildHeader(primaryColor, textSlate900),

          // Date Filter Scroll
          _buildDateFilter(primaryColor),

          // Results Section
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              children: [
                _buildResultsHeader(primaryColor, textSlate900),
                _buildTripCard(
                  company: 'SOTRA-GUINÉE',
                  classType: 'Standard Class',
                  price: '85.000 GNF',
                  departureTime: '07:30',
                  departureStation: 'Matam',
                  arrivalTime: '14:45',
                  arrivalStation: 'Mamou',
                  seatsLeft: 12,
                  primaryColor: primaryColor,
                  icon: Icons.airport_shuttle,
                ),
                const SizedBox(height: 16),
                _buildTripCard(
                  company: 'GUINÉE EXPRESS',
                  classType: 'VIP Service',
                  price: '120.000 GNF',
                  departureTime: '08:00',
                  departureStation: 'Bambeto',
                  arrivalTime: '18:30',
                  arrivalStation: 'Labé',
                  seatsLeft: 24,
                  primaryColor: primaryColor,
                  icon: Icons.bus_alert,
                ),
                const SizedBox(height: 16),
                _buildTripCard(
                  company: 'KANKAN VOYAGE',
                  classType: 'Nuit Class',
                  price: '150.000 GNF',
                  departureTime: '19:00',
                  departureStation: 'Madina',
                  arrivalTime: '06:00',
                  arrivalStation: 'Kankan',
                  seatsLeft: 4,
                  primaryColor: primaryColor,
                  icon: Icons.airport_shuttle,
                  isLowSeats: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color primaryColor, Color titleColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F6).withValues(alpha: 0.8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.directions_bus, color: primaryColor, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'GuineeTransport',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.notifications, color: primaryColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search Bar Area
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  children: [
                    _buildSearchInput(Icons.location_on, 'Départ (Conakry)',
                        primaryColor, _departureController),
                    Padding(
                      padding: const EdgeInsets.only(left: 36),
                      child: Divider(color: Colors.grey.withValues(alpha: 0.1)),
                    ),
                    _buildSearchInput(Icons.flag, 'Arrivée (Labe, Kankan...)',
                        const Color(0xFF94A3B8), _arrivalController),
                  ],
                ),
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          final temp = _departureController.text;
                          _departureController.text = _arrivalController.text;
                          _arrivalController.text = temp;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.swap_vert,
                            color: Colors.white, size: 18),
                      ),
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

  Widget _buildSearchInput(IconData icon, String hint, Color iconColor,
      TextEditingController controller) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 14, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 48), // Spacing for swap button
      ],
    );
  }

  Widget _buildDateFilter(Color primaryColor) {
    return SizedBox(
      height: 72,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          _buildDateButton("Aujourd'hui", true, primaryColor),
          const SizedBox(width: 12),
          _buildDateButton("Demain", false, primaryColor),
          const SizedBox(width: 12),
          _buildDateButton("Mer. 24 Oct", false, primaryColor),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: const Icon(Icons.calendar_month,
                size: 20, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(String label, bool isActive, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isActive ? primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isActive ? null : Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          color: isActive ? Colors.white : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildResultsHeader(Color primaryColor, Color titleColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Trajets disponibles',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '12 bus trouvés',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard({
    required String company,
    required String classType,
    required String price,
    required String departureTime,
    required String departureStation,
    required String arrivalTime,
    required String arrivalStation,
    required int seatsLeft,
    required Color primaryColor,
    required IconData icon,
    bool isLowSeats = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: primaryColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        classType.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: GoogleFonts.plusJakartaSans(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'par passager',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Timeline
          Row(
            children: [
              _buildTimelinePoint(departureTime, departureStation),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(0, 1),
                        painter: DashedLinePainter(color: const Color(0xFFCBD5E1)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        color: Colors.white,
                        child: Icon(Icons.directions_bus,
                            color: primaryColor, size: 16),
                      ),
                    ],
                  ),
                ),
              ),
              _buildTimelinePoint(arrivalTime, arrivalStation, isEnd: true),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.event_seat,
                      size: 16,
                      color: isLowSeats ? Colors.red : primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    '$seatsLeft sièges restants',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isLowSeats ? Colors.red : primaryColor,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: primaryColor.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: const Size(0, 40), // override global infinity width
                ),
                child: Text('Réserver',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelinePoint(String time, String station,
      {bool isEnd = false}) {
    return Column(
      crossAxisAlignment:
          isEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF0F172A)),
        ),
        Text(
          station,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 11, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width.isInfinite) return; // Sécurité anti-boucle infinie
    
    double dashWidth = 4, dashSpace = 4, startX = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
      
    // Limite de sécurité supplémentaire
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
