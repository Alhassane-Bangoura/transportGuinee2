import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class DriverPassengersPage extends StatefulWidget {
  const DriverPassengersPage({super.key});

  @override
  State<DriverPassengersPage> createState() => _DriverPassengersPageState();
}

class _DriverPassengersPageState extends State<DriverPassengersPage> {
  final List<Map<String, dynamic>> _passengers = [
    {
      'name': 'Mamadou Diallo',
      'initials': 'MD',
      'seat': 'A4',
      'status': 'Confirmé',
      'present': true,
    },
    {
      'name': 'Aminata Camara',
      'initials': 'AC',
      'seat': 'B12',
      'status': 'Confirmé',
      'present': false,
    },
    {
      'name': 'Ibrahima Barry',
      'initials': 'IB',
      'seat': 'C2',
      'status': 'En attente',
      'present': false,
      'isWaiting': true,
    },
  ];


  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = AppColors.background;
    final Color textColor = AppColors.textPrimary;
    final Color subColor = AppColors.textSecondary;
    final Color primaryColor = AppColors.primary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          _buildPremiumHeader(),
          _buildTripSummarySection(primaryColor, textColor),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _passengers.length,
              itemBuilder: (context, index) {
                final p = _passengers[index];
                return _buildModernPassengerCard(p, primaryColor, textColor, subColor);
              },
            ),
          ),
          _buildFloatingContactAll(primaryColor),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          ),
          Column(
            children: [
              Text(
                'GUINEE TRANSPORT',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'LISTE DES PASSAGERS',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(width: 48), // Spacer
        ],
      ),
    );
  }

  Widget _buildTripSummarySection(Color primary, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.05),
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TRAJET', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                  Text('Conakry → Mamou', style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 16)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('DATE', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                  Text('24 Oct. 2023', style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 16)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(20)),
                child: Text('BUS G-204', style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text('14/20 CONFIRMÉS', style: GoogleFonts.plusJakartaSans(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernPassengerCard(Map<String, dynamic> p, Color primary, Color textColor, Color subColor) {
    bool isPresent = p['present'];
    String name = p['name'];
    String seat = p['seat'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPresent ? AppColors.success.withValues(alpha: 0.05) : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isPresent ? AppColors.success.withValues(alpha: 0.2) : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(isPresent ? 
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAT4LLefTVEgZQ3uKz9NJcyvmPo2QwlPPJKEoxtmpLV4HVTxpLqbE1KhWAG_8FIieuvPFYhcBXylyOZ57MxAUYCIwZ4DVu2IT354WQ_frjmABiD0pe2_O6Ahl4JHzkSykVml9-QQEJeQMgG3i1sUBMoyz3MGhMwK-38EAYEAoggZTSWQYXrhFngoLhAVea8Y68ZEfNewcTXw-ILq7mhoJRiyYncuoHmaXPqPRVh5GXNpkv2hyMEZ8eACRNMr-42blc_hlHCPH2vhXie' :
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAhB-Tt1AoI7CUWD6y3UZb8xHBcR15nMpyfwv84ZdoBSHIplOP4gNDZMvVy_lFsaCoVMsELl6jDLSdGtlHsqiYPSqdskp2VrUhzIw4CM2mlgbGEO_OvZBvkpoTa4yd0zbXJdEXguG80IkPujjxTMiJgQ91-uCvRGIESeGpaV9PoRwI4oUv8ts2hgQeYWJTX_na0cSWffSoJHuKu_IGAxxOFH3XghbAQqVORrQhEy51uNmGFobfzayQKPgFv7I_HPquVhBRBvdvgcMVg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name, style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(6)),
                          child: Text(seat, style: GoogleFonts.plusJakartaSans(color: primary, fontWeight: FontWeight.w900, fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text('+224 622 00 00 00', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => p['present'] = !isPresent),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: isPresent ? AppColors.success.withValues(alpha: 0.1) : AppColors.success,
                      borderRadius: BorderRadius.circular(14),
                      border: isPresent ? Border.all(color: AppColors.success.withValues(alpha: 0.3)) : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isPresent ? Icons.verified_rounded : Icons.check_circle_outline, color: isPresent ? AppColors.success : Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isPresent ? 'DÉJÀ PRÉSENT' : 'CONFIRMER PRÉSENCE',
                          style: GoogleFonts.plusJakartaSans(color: isPresent ? AppColors.success : Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.chat_bubble_outline_rounded, color: primary, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingContactAll(Color primary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.textPrimary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text('CONTACTER TOUS LES PASSAGERS', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}
