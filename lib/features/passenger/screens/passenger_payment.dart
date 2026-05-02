import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import 'passenger_ticket_view.dart';
import '../../../core/models/trip.dart';
import '../../../core/models/wallet_transaction.dart';
import '../../../core/services/booking_service.dart';
import '../../../core/services/wallet_service.dart';
import '../../../core/constants/app_assets.dart';
import 'package:uuid/uuid.dart';
import 'passenger_dashboard.dart';
import '../../../core/services/auth_service.dart';

/// Écran de Paiement pour le Passager
/// Correspond à paiement_passager.html
class PassengerPayment extends StatefulWidget {
  final Trip trip;
  final int seat;

  const PassengerPayment({super.key, required this.trip, required this.seat});

  @override
  State<PassengerPayment> createState() => _PassengerPaymentState();
}

class _PassengerPaymentState extends State<PassengerPayment> {
  String selectedMethod = 'orange';
  bool _isProcessing = false;

  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Paiement Sécurisé',
          style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(12.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(AppAssets.profileAdmin),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // AI Assistant Tip
            _buildAITip(),
            const SizedBox(height: 24),

            // Booking Summary
            _buildSummaryCard(),
            const SizedBox(height: 32),

            // Payment Methods
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Mode de paiement', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ),
            const SizedBox(height: 16),
            _buildPaymentMethod('orange', 'Orange Money', 'Paiement instantané via code USSD', const Color(0xFFFF7900), 'ORANGE'),
            const SizedBox(height: 12),
            _buildPaymentMethod('mtn', 'MTN MoMo', 'Sécurisé et rapide avec MTN Mobile', const Color(0xFFFFCC00), 'MTN', textColor: const Color(0xFF004F9E)),
            const SizedBox(height: 12),
            _buildPaymentMethod('at_station', 'Paiement à la Gare', 'Réservez et payez au comptoir (Test)', AppColors.primary, 'GARE', icon: Icons.store_mall_directory),
            const SizedBox(height: 12),
            _buildPaymentMethod('card', 'Carte Bancaire', 'Visa, Mastercard, Maestro', const Color(0xFF0F172A), null, icon: Icons.credit_card),
            
            const SizedBox(height: 24),
            
            // Phone Number Input (Mandatory based on request)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.phone_android, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text('Numéro de téléphone', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'ex: 622 00 00 00',
                      hintStyle: const TextStyle(color: AppColors.textHint),
                      prefixText: '+224 ',
                      prefixStyle: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Ce numéro sera utilisé pour confirmer la transaction.', 
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
                ],
              ),
            ),

            const SizedBox(height: 32),
            // Trust Badges
            _buildTrustBadges(),
            
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomSheet: _buildBottomBar(),
    );
  }

  Widget _buildAITip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ASSISTANT AI', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(
                  'Votre paiement est 100% sécurisé. Nous utilisons un cryptage de bout en bout pour protéger vos données.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(32), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Résumé du trajet', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(100), border: Border.all(color: Colors.green.withOpacity(0.2))),
                child: Text('CONFIRMÉ', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.green)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTimeline(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: AppColors.border),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.event_available, color: AppColors.textSecondary, size: 18),
                    const SizedBox(width: 8),
                    Text('${widget.trip.departureTime.day}/${widget.trip.departureTime.month}/${widget.trip.departureTime.year}', 
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    const SizedBox(width: 16),
                    const Icon(Icons.person_outline, color: AppColors.textSecondary, size: 18),
                    const SizedBox(width: 4),
                    Text('1 Adulte', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Text('${widget.trip.price.toStringAsFixed(0)} GNF', 
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Frais de service (AI)', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              Text('2 500 GNF', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.border, thickness: 0.5),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total à payer', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              Text('${(widget.trip.price + 2500).toStringAsFixed(0)} GNF', 
                style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: [
        _buildTimelineStep('${widget.trip.departureTime.hour}:${widget.trip.departureTime.minute.toString().padLeft(2, '0')}', widget.trip.departureCityName, true),
        const SizedBox(height: 4),
        Align(alignment: Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(left: 7), width: 1, height: 20, color: AppColors.border)),
        const SizedBox(height: 4),
        _buildTimelineStep('--:--', widget.trip.arrivalCityName, false),
      ],
    );
  }

  Widget _buildTimelineStep(String time, String loc, bool isStart) {
    return Row(
      children: [
        Container(
          width: 16, height: 16,
          decoration: BoxDecoration(
            color: isStart ? AppColors.primary : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${isStart ? "DÉPART" : "ARRIVÉE"} • $time', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
            Text(loc, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethod(String id, String title, String subtitle, Color color, String? logoText, {IconData? icon, Color? textColor}) {
    bool isSelected = selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => selectedMethod = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
              child: Center(
                child: icon != null 
                  ? Icon(icon, color: Colors.white) 
                  : Text(logoText ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: textColor ?? Colors.white)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildBadge(Icons.lock_outline, 'Secure SSL'),
        _buildBadge(Icons.verified_user_outlined, 'PCI Compliant'),
        _buildBadge(Icons.shield_outlined, 'Fraud Protect'),
      ],
    );
  }

  Widget _buildBadge(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 6),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TOTAL À PAYER', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
              Text('${(widget.trip.price + 2500).toStringAsFixed(0)} GNF', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary)),
            ],
          ),
          _isProcessing
              ? const CircularProgressIndicator(color: AppColors.primary)
              : ElevatedButton(
                  onPressed: _handlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 54), // Empêche le bug "largeur infinie" du thème global
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Indispensable pour empêcher la ligne de s'étendre
                    children: [
                      Text('PAYER MAINTENANT', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13)),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Future<void> _handlePayment() async {
    // Le numéro n'est pas strictement requis pour le paiement à la gare en mode TEST
    if (selectedMethod != 'at_station' && _phoneController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un numéro de téléphone valide.')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    
    // Génération de la clé d'idempotence UNIQUE pour cette tentative (persiste si on retry l'appel)
    final String idempotencyKey = const Uuid().v4();

    try {
      final response = await BookingService.createBooking(
        tripId: widget.trip.id,
        seats: 1,
        totalPrice: widget.trip.price + 2500,
        fromCity: widget.trip.departureCityName,
        toCity: widget.trip.arrivalCityName,
        departureDate: widget.trip.departureTime,
        paymentMethod: selectedMethod,
        idempotencyKey: idempotencyKey,
      );

      if (response.isSuccess && response.data != null) {
        // Enregistrer la transaction dans le portefeuille
        final transaction = WalletTransaction(
          id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
          userId: Supabase.instance.client.auth.currentUser?.id ?? '',
          amount: -widget.trip.price,
          type: TransactionType.payment,
          method: selectedMethod == 'orange' ? 'Orange Money' : 'MTN MoMo',
          description: 'Paiement trajet ${widget.trip.departureCityName} - ${widget.trip.arrivalCityName}',
          createdAt: DateTime.now(),
          fromCity: widget.trip.departureCityName,
          toCity: widget.trip.arrivalCityName,
        );
        await WalletService().addTransaction(transaction);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PassengerTicket(booking: response.data!),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message ?? 'Erreur lors de la réservation.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle, color: Colors.green, size: 64),
                ),
                const SizedBox(height: 24),
                Text('Paiement Réussi !', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                Text(
                  'Votre billet a été généré avec succès. Vous le trouverez dans votre historique de voyage.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const PassengerDashboard(initialIndex: 2),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text('VOIR MES BILLETS', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Billet téléchargé avec succès ! (Format PDF)'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.download, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text('TÉLÉCHARGER LE TICKET', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppColors.primary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
