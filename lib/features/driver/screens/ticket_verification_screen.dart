import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/models/booking.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/booking_service.dart';

class TicketVerificationScreen extends StatefulWidget {
  final String bookingId;

  const TicketVerificationScreen({super.key, required this.bookingId});

  @override
  State<TicketVerificationScreen> createState() => _TicketVerificationScreenState();
}

class _TicketVerificationScreenState extends State<TicketVerificationScreen> {
  bool _isLoading = true;
  Booking? _booking;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    final response = await BookingService.getBookingById(widget.bookingId);
    if (mounted) {
      setState(() {
        if (response.isSuccess) {
          _booking = response.data;
        } else {
          _error = response.message;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _validatePresence() async {
    if (_booking == null) return;
    setState(() => _isLoading = true);
    final response = await BookingService.confirmPassengerPresence(_booking!.id);
    if (mounted) {
      if (response.isSuccess) {
        _loadBooking();
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_error != null || _booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vérification')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(_error ?? 'Erreur inconnue', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    final b = _booking!;
    final bool isConfirmed = b.status == 'confirmed' || b.status == 'used';
    final bool isCancelled = b.status == 'cancelled';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('VÉRIFICATION BILLET', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isCancelled ? Colors.red.withOpacity(0.1) : (isConfirmed ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: isCancelled ? Colors.red.withOpacity(0.3) : (isConfirmed ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3))),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCancelled ? Icons.cancel_rounded : (isConfirmed ? Icons.verified_rounded : Icons.pending_rounded),
                    size: 20,
                    color: isCancelled ? Colors.red : (isConfirmed ? Colors.green : Colors.orange),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isCancelled ? 'BILLET ANNULÉ' : (isConfirmed ? 'BILLET VALIDE' : 'PAIEMENT EN ATTENTE'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isCancelled ? Colors.red : (isConfirmed ? Colors.green : Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Official Ticket Details
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                children: [
                  // Passenger Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white,
                          backgroundImage: (b.passengerAvatarUrl != null && b.passengerAvatarUrl!.isNotEmpty)
                              ? NetworkImage(b.passengerAvatarUrl!)
                              : null,
                          child: (b.passengerAvatarUrl == null || b.passengerAvatarUrl!.isEmpty)
                              ? const Icon(Icons.person_rounded, color: AppColors.primary, size: 32)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PASSAGER',
                                style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                b.passengerName ?? 'Non renseigné',
                                style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                              ),
                              Text(
                                b.passengerPhone ?? 'Pas de numéro',
                                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Ticket Info
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildInfoRow('ITINÉRAIRE', '${b.departureCityName} → ${b.arrivalCityName}', isBold: true),
                        const Divider(height: 32),
                        _buildInfoRow('DATE DÉPART', b.departureTime != null ? DateFormat('dd MMM yyyy à HH:mm', 'fr_FR').format(b.departureTime!) : 'N/A'),
                        const SizedBox(height: 16),
                        _buildInfoRow('RÉSERVÉ LE', DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(b.createdAt)),
                        const SizedBox(height: 16),
                        _buildInfoRow('PLACES', '${b.seats} Siège(s)'),
                        const SizedBox(height: 16),
                        _buildInfoRow('PRIX TOTAL', b.formattedPrice, color: AppColors.primary, isBold: true),
                        const Divider(height: 32),
                        
                        // Driver & Vehicle Section
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              backgroundImage: (b.driverAvatarUrl != null && b.driverAvatarUrl!.isNotEmpty)
                                  ? NetworkImage(b.driverAvatarUrl!)
                                  : null,
                              child: (b.driverAvatarUrl == null || b.driverAvatarUrl!.isEmpty)
                                  ? const Icon(Icons.person_rounded, color: AppColors.primary, size: 20)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CHAUFFEUR',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                                  ),
                                  Text(
                                    b.driverName ?? 'En attente',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'VÉHICULE',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                                ),
                                Text(
                                  b.vehiclePlate ?? 'N/A',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        _buildInfoRow('PAIEMENT', _formatPaymentMethod(b.paymentMethod)),
                        const SizedBox(height: 16),
                        _buildInfoRow('RÉFÉRENCE', b.id.substring(0, 8).toUpperCase(), isMonospaced: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),

            if (!isConfirmed && !isCancelled)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _validatePresence,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('VALIDER LA PRÉSENCE & PAIEMENT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            
            if (isConfirmed)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Passager vérifié et autorisé à bord.',
                        style: GoogleFonts.plusJakartaSans(color: Colors.green, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('FERMER LA VÉRIFICATION', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false, bool isMonospaced = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: isMonospaced 
              ? GoogleFonts.robotoMono(fontSize: 14, fontWeight: FontWeight.bold, color: color ?? AppColors.textPrimary)
              : GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
                  color: color ?? AppColors.textPrimary,
                ),
          ),
        ),
      ],
    );
  }

  String _formatPaymentMethod(String? method) {
    if (method == null) return 'N/A';
    if (method.contains('at_station')) return 'À LA GARE (ESPÈCES)';
    if (method.contains('orange')) return 'ORANGE MONEY';
    if (method.contains('momo')) return 'MTN MOMO';
    return method.toUpperCase();
  }
}

