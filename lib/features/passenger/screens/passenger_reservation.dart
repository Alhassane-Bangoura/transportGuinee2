import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/models/trip.dart';
import 'passenger_payment.dart';

/// Écran de Réservation (Choix du siège) pour le Passager
/// Correspond à reservation_passager.html
class PassengerReservation extends StatefulWidget {
  const PassengerReservation({super.key});

  @override
  State<PassengerReservation> createState() => _PassengerReservationState();
}

class _PassengerReservationState extends State<PassengerReservation> {
  int? selectedSeat = 5; // Default from reference

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Choix du siège',
          style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(12.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: const NetworkImage(AppAssets.reservationHeader),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Journey Info Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TRAJET', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                      Text('Conakry → Mamou', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('DATE & HEURE', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                      Text('24 Oct, 08:30', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Legend
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLegendItem(AppColors.surface, 'Libre', border: AppColors.border),
                  _buildLegendItem(AppColors.primary, 'Sélectionné'),
                  _buildLegendItem(AppColors.border, 'Occupé'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bus Map
            _buildBusGrid(),
            const SizedBox(height: 24),

            // AI Assistant Suggestion
            _buildAISuggestion(),
            const SizedBox(height: 24),

            // Price Summary
            _buildPriceSummary(),
            const SizedBox(height: 24),

            // Action Button
            ElevatedButton(
              onPressed: () {
                final dummyTrip = Trip(
                  id: 'dummy',
                  routeId: 'dummy',
                  departureTime: DateTime.now(),
                  availableSeats: 10,
                  price: 150000.0,
                  status: 'scheduled',
                  departureCityName: 'Conakry',
                  arrivalCityName: 'Kamsar',
                  departureStationName: 'Gare Routière',
                  arrivalStationName: 'Gare d\'arrivée',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PassengerPayment(
                      trip: dummyTrip,
                      seat: selectedSeat ?? 0,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 8,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Confirmer la réservation', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {Color? border}) {
    return Row(
      children: [
        Container(width: 16, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4), border: border != null ? Border.all(color: border) : null)),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildBusGrid() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(32), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          // Front Decor
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, style: BorderStyle.none))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.settings, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 8),
                Text('AVANT DU VÉHICULE', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 2)),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Seat Grid (Rows based on reference)
          ...List.generate(7, (rowIndex) {
            if (rowIndex == 4) { // Exit row
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('SORTIE', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.border, letterSpacing: 3)),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSeat(rowIndex * 3 + 1),
                  const SizedBox(width: 12),
                  _buildSeat(rowIndex * 3 + 2),
                  const SizedBox(width: 48), // Aisle
                  _buildSeat(rowIndex * 3 + 3),
                ],
              ),
            );
          }),

          // Rear Decor
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border, style: BorderStyle.solid))),
            child: Center(
              child: Text('ARRIÈRE DU VÉHICULE', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.border, letterSpacing: 2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeat(int number) {
    bool isSelected = selectedSeat == number;
    bool isOccupied = [3, 7, 8, 18].contains(number);
    bool isPremium = number == 12;

    return GestureDetector(
      onTap: isOccupied ? null : () => setState(() => selectedSeat = number),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : (isOccupied ? AppColors.border : AppColors.surface),
          borderRadius: BorderRadius.circular(12),
          border: isPremium ? Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 2, style: BorderStyle.none) : Border.all(color: AppColors.border),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
        ),
        child: Center(
          child: isPremium 
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, size: 10, color: AppColors.primary),
                  Text('$number', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : AppColors.primary)),
                ],
              )
            : Text('$number', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : (isOccupied ? AppColors.textHint : AppColors.textPrimary))),
        ),
      ),
    );
  }

  Widget _buildAISuggestion() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(Icons.smart_toy, color: Colors.white.withValues(alpha: 0.1), size: 120),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text('AI Assistant', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white.withValues(alpha: 0.9), height: 1.5),
                  children: const [
                    TextSpan(text: '"Le '),
                    TextSpan(text: 'siège 12', style: TextStyle(fontWeight: FontWeight.w900, decoration: TextDecoration.underline)),
                    TextSpan(text: ' est situé à l\'avant avec plus d\'espace pour les jambes ! C\'est le choix idéal pour un long voyage vers Mamou."'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => setState(() => selectedSeat = 12),
                  style: TextButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.2), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text('CHOISIR LE SIÈGE 12', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(32), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RÉCAPITULATIF', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          _buildPriceRow('Siège sélectionné ($selectedSeat)', '45,000 GNF'),
          const SizedBox(height: 12),
          _buildPriceRow('Frais de service', '2,500 GNF'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AppColors.border),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              Text('47,500 GNF', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      ],
    );
  }
}
