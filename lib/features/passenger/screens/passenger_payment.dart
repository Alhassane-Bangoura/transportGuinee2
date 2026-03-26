import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/trip.dart';

class PassengerPayment extends StatefulWidget {
  final Trip trip;
  final int seat;
  const PassengerPayment({super.key, required this.trip, required this.seat});

  @override
  State<PassengerPayment> createState() => _PassengerPaymentState();
}

class _PassengerPaymentState extends State<PassengerPayment> {
  String _selectedMethod = 'orange';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Paiement', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAmountCard(),
            const SizedBox(height: 32),
            Text('Méthode de paiement', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildPaymentOption('orange', 'Orange Money', 'https://upload.wikimedia.org/wikipedia/commons/c/c8/Orange_logo.svg'), // Placeholder image logic
            const SizedBox(height: 12),
            _buildPaymentOption('momo', 'MTN MoMo', 'https://upload.wikimedia.org/wikipedia/commons/9/93/MTN_Logo.svg'),
            const SizedBox(height: 12),
            _buildPaymentOption('card', 'Carte Bancaire', null, icon: Icons.credit_card),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _showSuccessDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text('PAYER ${widget.trip.price.toStringAsFixed(0)} FG', 
                  style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Text('Montant à payer', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text('${widget.trip.price.toStringAsFixed(0)} FG', 
              style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.primary)),
          const Divider(height: 32),
          _buildSummaryRow('Trajet', widget.trip.arrivalCityName),
          const SizedBox(height: 8),
          _buildSummaryRow('Place', 'Siège ${widget.seat}'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
        Text(value, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPaymentOption(String id, String name, String? logoUrl, {IconData? icon}) {
    bool isSelected = _selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            if (icon != null) Icon(icon, color: Colors.blue) else const Icon(Icons.account_balance_wallet, color: Colors.orange),
            const SizedBox(width: 16),
            Text(name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            Text('Paiement Réussi !', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Votre billet a été généré avec succès.', 
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('RETOUR À L\'ACCUEIL'),
            ),
          ],
        ),
      ),
    );
  }
}
