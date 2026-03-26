import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/trip.dart';
import '../../../core/services/trip_service.dart';
import 'passenger_trip_detail.dart';

class PassengerSearchResults extends StatefulWidget {
  final String from;
  final String to;
  final DateTime date;
  final int passengers;

  const PassengerSearchResults({
    super.key,
    required this.from,
    required this.to,
    required this.date,
    required this.passengers,
  });

  @override
  State<PassengerSearchResults> createState() => _PassengerSearchResultsState();
}

class _PassengerSearchResultsState extends State<PassengerSearchResults> {
  List<Trip> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  Future<void> _fetchResults() async {
    try {
      final trips = await TripService.searchTrips(
        departureCityName: widget.from,
        arrivalCityName: widget.to,
        date: widget.date,
      );
      if (mounted) {
        setState(() {
          _results = trips;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error searching trips: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.from} → ${widget.to}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${widget.date.day}/${widget.date.month} • ${widget.passengers} passager(s)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    return _buildTripCard(_results[index]);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(
            'Aucun trajet disponible',
            style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez une autre date ou destination.',
            style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(Trip trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PassengerTripDetail(trip: trip)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${trip.departureTime.hour}:${trip.departureTime.minStr}',
                          style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(trip.departureCityName, style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                    const Icon(Icons.arrow_forward, color: AppColors.primary, size: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Estimé',
                          style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(trip.arrivalCityName, style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.directions_bus, size: 16, color: AppColors.textHint),
                        const SizedBox(width: 8),
                        Text(
                          trip.vehicleType ?? 'Bus Standard',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Text(
                      '${trip.price.toStringAsFixed(0)} FG',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension TripExt on DateTime {
  String get minStr => minute.toString().padLeft(2, '0');
}
