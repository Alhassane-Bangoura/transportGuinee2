import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/booking.dart';

class PassengerTicket extends StatelessWidget {
  final Booking booking;

  const PassengerTicket({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Votre Billet', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              booking.status == 'pending' ? Icons.access_time_rounded : Icons.check_circle_rounded, 
              color: booking.status == 'pending' ? Colors.orange : Colors.green, 
              size: 64
            ),
            const SizedBox(height: 16),
            Text(
              booking.status == 'pending' ? 'Réservation en Attente' : 'Réservation Confirmée !', 
              style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
            ),
            const SizedBox(height: 8),
            Text(
              booking.status == 'pending' 
                ? 'Veuillez payer à la gare pour confirmer votre place.' 
                : 'Votre billet a été généré avec succès.', 
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)
            ),
            const SizedBox(height: 32),
            
            // Ticket Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfo('DÉPART', booking.departureCityName ?? 'N/A'),
                            const Icon(Icons.arrow_forward, color: AppColors.primary),
                            _buildInfo('ARRIVÉE', booking.arrivalCityName ?? 'N/A', alignEnd: true),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: (booking.status == 'pending' ? Colors.orange : Colors.green).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: (booking.status == 'pending' ? Colors.orange : Colors.green).withOpacity(0.2)),
                          ),
                          child: Text(
                            booking.status == 'pending' ? 'À PAYER À LA GARE' : 'PAYÉ', 
                            style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: booking.status == 'pending' ? Colors.orange : Colors.green)
                          ),
                        ),
                        const SizedBox(height: 16),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfo('DATE', booking.departureTime != null ? DateFormat('dd MMM yyyy').format(booking.departureTime!) : 'N/A'),
                            _buildInfo('HEURE', booking.departureTime != null ? DateFormat('HH:mm').format(booking.departureTime!) : 'N/A', alignEnd: true),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfo('GARE DÉPART', booking.departureStationName ?? 'N/A'),
                            _buildInfo('GARE ARRIVÉE', booking.arrivalStationName ?? 'N/A', alignEnd: true),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfo('CHAUFFEUR', booking.driverName ?? 'En attente'),
                            if (booking.driverPhone != null)
                              _buildInfo('TÉLÉPHONE', booking.driverPhone!, alignEnd: true)
                            else
                              _buildInfo('STATUT', booking.status.toUpperCase(), alignEnd: true),
                          ],
                        ),
                        if (booking.driverPhone != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfo('STATUT', booking.status.toUpperCase()),
                                const SizedBox(), // Placeholder
                              ],
                            ),
                          ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfo('SIÈGE', booking.seats.toString()),
                            _buildInfo('PRIX', booking.formattedPrice, alignEnd: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Dashed Line
                  Row(
                    children: [
                      const _TicketCutter(isLeft: true),
                      Expanded(
                        child: CustomPaint(
                          painter: _DashedLinePainter(),
                          child: const SizedBox(height: 1),
                        ),
                      ),
                      const _TicketCutter(isLeft: false),
                    ],
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.qr_code_2, size: 150),
                        ),
                        const SizedBox(height: 16),
                        Text('TICKET #${booking.id.substring(0, 8).toUpperCase()}', 
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, letterSpacing: 2)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Téléchargement du ticket en PDF...')));
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('TÉLÉCHARGER'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.share_outlined, color: AppColors.primary),
                    onPressed: () {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Partage du ticket...')));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(String label, String value, {bool alignEnd = false}) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }
}

class _TicketCutter extends StatelessWidget {
  final bool isLeft;
  const _TicketCutter({required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topRight: isLeft ? const Radius.circular(16) : Radius.zero,
          bottomRight: isLeft ? const Radius.circular(16) : Radius.zero,
          topLeft: !isLeft ? const Radius.circular(16) : Radius.zero,
          bottomLeft: !isLeft ? const Radius.circular(16) : Radius.zero,
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    const dashWidth = 5;
    const dashSpace = 4;
    double currentX = 0;
    while (currentX < size.width) {
      canvas.drawLine(Offset(currentX, 0), Offset(currentX + dashWidth, 0), paint);
      currentX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
