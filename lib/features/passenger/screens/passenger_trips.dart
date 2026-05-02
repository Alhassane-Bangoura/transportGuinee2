import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/trip_service.dart';
import '../../../core/models/trip.dart';
import 'passenger_booking.dart';

class PassengerTrips extends StatefulWidget {
  const PassengerTrips({super.key});

  @override
  State<PassengerTrips> createState() => _PassengerTripsState();
}

class _PassengerTripsState extends State<PassengerTrips> {
  final TextEditingController _departureController =
      TextEditingController(text: 'Conakry');
  final TextEditingController _arrivalController = TextEditingController();
  
  List<Trip> _allTrips = [];
  List<Trip> _filteredTrips = [];
  bool _isLoading = true;
  String _sortBy = 'time'; // 'price', 'time', 'duration'

  @override
  void initState() {
    super.initState();
    _fetchTrips();
    _departureController.addListener(_onSearchChanged);
    _arrivalController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _departureController.removeListener(_onSearchChanged);
    _arrivalController.removeListener(_onSearchChanged);
    _departureController.dispose();
    _arrivalController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterAndSortTrips();
  }

  Future<void> _fetchTrips() async {
    setState(() => _isLoading = true);
    final response = await TripService.getUpcomingTrips(limit: 50);
    if (mounted) {
      setState(() {
        _allTrips = response.data ?? [];
        _filterAndSortTrips();
        _isLoading = false;
      });
    }
  }

  void _filterAndSortTrips() {
    final dep = _departureController.text.toLowerCase().trim();
    final arr = _arrivalController.text.toLowerCase().trim();

    List<Trip> filtered = _allTrips.where((trip) {
      final matchDep = dep.isEmpty || (trip.departureCityName.toLowerCase().contains(dep));
      final matchArr = arr.isEmpty || (trip.arrivalCityName.toLowerCase().contains(arr));
      // On peut aussi filtrer par date ici si besoin
      return matchDep && matchArr;
    }).toList();

    // Sorting logic
    switch (_sortBy) {
      case 'price':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'duration':
        filtered.sort((a, b) => (a.estimatedDuration ?? 0).compareTo(b.estimatedDuration ?? 0));
        break;
      case 'time':
      default:
        filtered.sort((a, b) => a.departureTime.compareTo(b.departureTime));
    }

    setState(() {
      _filteredTrips = filtered;
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trier par', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 24),
            _buildSortItem('Heure de départ', Icons.access_time, 'time'),
            _buildSortItem('Prix le plus bas', Icons.payments_outlined, 'price'),
            _buildSortItem('Durée la plus courte', Icons.speed, 'duration'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSortItem(String label, IconData icon, String value) {
    bool isSelected = _sortBy == value;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
      title: Text(label, style: GoogleFonts.plusJakartaSans(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
      )),
      trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
      onTap: () {
        setState(() {
          _sortBy = value;
          _filterAndSortTrips();
        });
        Navigator.pop(context);
      },
    );
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

          // Date Filter Scroll & Sort Button
          Row(
            children: [
              Expanded(child: _buildDateFilter(primaryColor)),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: IconButton(
                  onPressed: _showSortOptions,
                  icon: const Icon(Icons.tune, color: AppColors.primary),
                  tooltip: 'Trier',
                ),
              ),
            ],
          ),

          // Results Section
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _filteredTrips.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text('Aucun trajet trouvé.', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 16)),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchTrips,
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: _filteredTrips.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildResultsHeader(primaryColor, textSlate900, _filteredTrips.length);
                        }
                        final trip = _filteredTrips[index - 1];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildTripCard(
                            context,
                            trip,
                            primaryColor,
                          ),
                        );
                      },
                    ),
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
        color: const Color(0xFFF6F8F6).withOpacity(0.8),
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
                  color: primaryColor.withOpacity(0.1),
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
              border: Border.all(color: primaryColor.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                      child: Divider(color: Colors.grey.withOpacity(0.1)),
                    ),
                    _buildSearchInput(Icons.flag, 'Arrivée (Labe, Kankan...)',
                        AppColors.textHint, _arrivalController),
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
                              color: primaryColor.withOpacity(0.3),
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
                color: AppColors.textHint,
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
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: const Icon(Icons.calendar_month,
                size: 20, color: AppColors.textSecondary),
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
                  color: primaryColor.withOpacity(0.3),
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
          color: isActive ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildResultsHeader(Color primaryColor, Color titleColor, int count) {
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
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count bus trouvés',
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

  Widget _buildTripCard(
    BuildContext context,
    Trip trip,
    Color primaryColor,
  ) {
    bool isLowSeats = trip.availableSeats < 10;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.directions_bus_rounded, color: primaryColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.syndicateName ?? 'Transport Express',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.textHint.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          (trip.vehicleType ?? 'Bus Standard').toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w900,
                          ),
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
                    trip.formattedPrice,
                    style: GoogleFonts.plusJakartaSans(
                      color: primaryColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'GNF / place',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Timeline Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildTimelinePoint(
                    "${trip.departureTime.hour.toString().padLeft(2, '0')}:${trip.departureTime.minute.toString().padLeft(2, '0')}", 
                    trip.departureStationName),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Text(
                          trip.formattedDuration,
                          style: GoogleFonts.plusJakartaSans(
                            color: primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(width: 6, height: 6, decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle)),
                            Expanded(child: Container(height: 1, color: primaryColor.withOpacity(0.2))),
                            Icon(Icons.chevron_right, size: 14, color: primaryColor.withOpacity(0.5)),
                            Expanded(child: Container(height: 1, color: primaryColor.withOpacity(0.2))),
                            Container(width: 6, height: 6, decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: _buildTimelinePoint(
                    trip.estimatedDuration != null 
                        ? "${trip.departureTime.add(Duration(minutes: trip.estimatedDuration!)).hour.toString().padLeft(2, '0')}:${trip.departureTime.add(Duration(minutes: trip.estimatedDuration!)).minute.toString().padLeft(2, '0')}"
                        : "--:--", 
                    trip.arrivalStationName, 
                    isEnd: true),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.event_seat_rounded,
                      size: 18,
                      color: isLowSeats ? AppColors.error : AppColors.success),
                  const SizedBox(width: 8),
                  Text(
                    '${trip.availableSeats} places libres',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isLowSeats ? AppColors.error : AppColors.success,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 150, // Fixe la largeur pour bloquer l'infini demandé par le thème
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PassengerBooking(trip: trip),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(150, 44),
                    maximumSize: const Size(150, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Réserver',
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800, fontSize: 13)),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
                ),
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
              fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
        ),
        Text(
          station,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: isEnd ? TextAlign.right : TextAlign.left,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 11, color: AppColors.textHint, fontWeight: FontWeight.w500),
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
