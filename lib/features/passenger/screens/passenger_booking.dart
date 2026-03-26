import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/trip.dart';
import 'passenger_payment.dart';

class PassengerBooking extends StatefulWidget {
  final Trip trip;
  const PassengerBooking({super.key, required this.trip});

  @override
  State<PassengerBooking> createState() => _PassengerBookingState();
}

class _PassengerBookingState extends State<PassengerBooking> {
  int _selectedSeat = -1;
  final List<int> _reservedSeats = [3, 8, 12];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Sélection de place', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Column(
        children: [
          _buildSeatLegend(),
          Expanded(child: _buildSeatGrid()),
          _buildSummary(context),
        ],
      ),
    );
  }

  Widget _buildSeatLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem('Libre', Colors.grey[200]!),
          const SizedBox(width: 20),
          _legendItem('Réservé', Colors.grey[400]!),
          const SizedBox(width: 20),
          _legendItem('Sélectionné', AppColors.primary),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 16, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildSeatGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(40),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: 20,
      itemBuilder: (context, index) {
        final seatNum = index + 1;
        bool isReserved = _reservedSeats.contains(seatNum);
        bool isSelected = _selectedSeat == seatNum;

        return GestureDetector(
          onTap: isReserved ? null : () => setState(() => _selectedSeat = seatNum),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : (isReserved ? Colors.grey[400] : Colors.grey[200]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$seatNum',
                style: GoogleFonts.plusJakartaSans(
                  color: isSelected || isReserved ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Place sélectionnée:', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
                Text(_selectedSeat == -1 ? 'Aucune' : 'Place $_selectedSeat', 
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedSeat == -1 ? null : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PassengerPayment(trip: widget.trip, seat: _selectedSeat)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('CONTINUER VERS LE PAIEMENT', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
