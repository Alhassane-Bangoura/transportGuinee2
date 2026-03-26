import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/trip.dart';
import 'passenger_booking.dart';

class PassengerTripDetail extends StatelessWidget {
  final Trip trip;
  const PassengerTripDetail({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTripInfo(),
                  const SizedBox(height: 32),
                  _buildAmenitiesSection(),
                  const SizedBox(height: 32),
                  _buildPolicySection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomBar(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=800',
              fit: BoxFit.cover,
            ),
            Container(color: Colors.black.withOpacity(0.3)),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildTripInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Détails du voyage',
          style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '${trip.departureCityName} → ${trip.arrivalCityName}',
          style: GoogleFonts.plusJakartaSans(fontSize: 16, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        _buildDetailRow(Icons.schedule, 'Départ: ${trip.departureTime.hour}:${trip.departureTime.minute.toString().padLeft(2, '0')}'),
        const SizedBox(height: 12),
        _buildDetailRow(Icons.place, 'Gare: ${trip.departureStationName ?? "Gare Routière"}'),
        const SizedBox(height: 12),
        _buildDetailRow(Icons.directions_bus, 'Véhicule: ${trip.vehicleType ?? "Toyota Hiace"}'),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Services à bord', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildAmenityChip(Icons.ac_unit, 'Climatisation'),
            _buildAmenityChip(Icons.usb, 'Prise USB'),
            _buildAmenityChip(Icons.wifi, 'Wi-Fi'),
          ],
        ),
      ],
    );
  }

  Widget _buildAmenityChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildPolicySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Politique d\'annulation', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(
          'Remboursement à 100% si annulé 24h avant le départ. 50% entre 24h et 6h.',
          style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 12)),
              Text('${trip.price.toStringAsFixed(0)} FG', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary)),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PassengerBooking(trip: trip)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('RÉSERVER', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
