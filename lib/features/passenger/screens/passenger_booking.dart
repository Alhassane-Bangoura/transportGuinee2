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
  final List<int> _reservedSeats = [3, 7, 8, 18]; // Matching HTML disabled seats
  final int _recommendedSeat = 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildJourneyBanner(),
              const SizedBox(height: 24),
              _buildSeatLegend(),
              const SizedBox(height: 24),
              _buildBusMap(),
              const SizedBox(height: 32),
              if (_selectedSeat == -1) _buildAIAssistantCard(),
              if (_selectedSeat != -1) _buildPriceSummary(),
              const SizedBox(height: 24),
              if (_selectedSeat != -1) _buildConfirmButton(),
              const SizedBox(height: 40), // Safe area margin
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Choix du siège', 
        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary)),
      backgroundColor: AppColors.surface.withOpacity(0.9),
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      centerTitle: false,
    );
  }

  Widget _buildJourneyBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TRAJET', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text('${widget.trip.departureCityName} → ${widget.trip.arrivalCityName}', 
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('DATE & HEURE', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text('24 Oct, 08:30', // Or integrate dynamic widget.trip.departureTime here
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSeatLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem('Libre', AppColors.background, border: AppColors.border),
          _legendItem('Sélectionné', AppColors.primary),
          _legendItem('Occupé', AppColors.surfaceVariant),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color, {Color? border}) {
    return Row(
      children: [
        Container(
          width: 16, height: 16,
          decoration: BoxDecoration(
            color: color, 
            borderRadius: BorderRadius.circular(4),
            border: border != null ? Border.all(color: border) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildBusMap() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            offset: const Offset(0, 10),
            blurRadius: 20,
          )
        ],
      ),
      child: Column(
        children: [
          // Front Decor
          Container(
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.drive_eta, color: AppColors.textSecondary, size: 18),
                const SizedBox(width: 8),
                Text('AVANT DU VÉHICULE', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Seats Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                _buildSeatRow([1, 2], [3]),
                const SizedBox(height: 16),
                _buildSeatRow([4, 5], [6]),
                const SizedBox(height: 16),
                _buildSeatRow([7, 8], [9]),
                const SizedBox(height: 16),
                _buildSeatRow([10, 11], [12]),
                const SizedBox(height: 24),
                // Exit Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text('SORTIE', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2, color: AppColors.primary)),
                      ),
                    ),
                    const Expanded(flex: 1, child: SizedBox()), // Aisle
                    const Expanded(flex: 1, child: SizedBox()), // Placeholder for remaining alignment
                  ],
                ),
                const SizedBox(height: 24),
                _buildSeatRow([13, 14], [15]),
                const SizedBox(height: 16),
                _buildSeatRow([16, 17], [18]),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Rear Decor
          Container(
            height: 48,
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            alignment: Alignment.center,
            child: Text('ARRIÈRE DU VÉHICULE', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatRow(List<int> leftSeats, List<int> rightSeats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: leftSeats.map((s) => Padding(padding: const EdgeInsets.only(right: 12), child: _buildSeatTarget(s))).toList(),
        ),
        // Central Aisle created via MainAxisAlignment.spaceBetween
        Row(
          mainAxisSize: MainAxisSize.min,
          children: rightSeats.map((s) => _buildSeatTarget(s)).toList(),
        ),
      ],
    );
  }

  Widget _buildSeatTarget(int seatNum) {
    bool isReserved = _reservedSeats.contains(seatNum);
    bool isSelected = _selectedSeat == seatNum;
    bool isRecommended = seatNum == _recommendedSeat;

    Color bgColor;
    Color borderColor;
    Color textColor;
    
    if (isReserved) {
      bgColor = AppColors.surfaceVariant;
      borderColor = Colors.transparent;
      textColor = AppColors.textHint;
    } else if (isSelected) {
      bgColor = AppColors.primary;
      borderColor = AppColors.primary;
      textColor = Colors.white;
    } else if (isRecommended) {
      bgColor = Colors.blue.withOpacity(0.05);
      borderColor = Colors.blue.withOpacity(0.4);
      textColor = AppColors.primary;
    } else {
      bgColor = AppColors.background;
      borderColor = AppColors.border;
      textColor = AppColors.textPrimary;
    }

    return GestureDetector(
      onTap: isReserved ? null : () => setState(() => _selectedSeat = seatNum),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isSelected || isRecommended ? 2 : 1,
          ),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Center(
          child: isRecommended && !isSelected
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: AppColors.primary, size: 14),
                    Text('$seatNum', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                  ],
                )
              : Text('$seatNum', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
        ),
      ),
    );
  }

  Widget _buildAIAssistantCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A), // Deep Premium Blue matching HTML reference
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8), 
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), 
                child: const Icon(Icons.smart_toy, color: Colors.blueAccent)
              ),
              const SizedBox(width: 12),
              Text('AI Assistant', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '"Le siège $_recommendedSeat est situé à l\'avant avec plus d\'espace pour les jambes ! C\'est le choix idéal pour un long voyage vers ${widget.trip.arrivalCityName}."',
            style: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _selectedSeat = _recommendedSeat),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('CHOISIR LE SIÈGE $_recommendedSeat', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    final double serviceFee = 2500;
    final double total = widget.trip.price + serviceFee;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Récapitulatif', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Siège sélectionné ($_selectedSeat)', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              Text('${widget.trip.price.toStringAsFixed(0)} GNF', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Frais de service', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              Text('${serviceFee.toStringAsFixed(0)} GNF', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textPrimary)),
              Text('${total.toStringAsFixed(0)} GNF', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PassengerPayment(
              trip: widget.trip,
              seat: _selectedSeat,
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 10,
        shadowColor: AppColors.primary.withOpacity(0.4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Confirmer la réservation', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(width: 12),
          const Icon(Icons.arrow_forward),
        ],
      ),
    );
  }
}

