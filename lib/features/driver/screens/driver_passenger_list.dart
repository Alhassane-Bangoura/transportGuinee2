import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/booking_service.dart';
import '../../../core/utils/app_response.dart';

class DriverPassengerList extends StatefulWidget {
  final String tripId;
  const DriverPassengerList({super.key, required this.tripId});

  @override
  State<DriverPassengerList> createState() => _DriverPassengerListState();
}

class _DriverPassengerListState extends State<DriverPassengerList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'GUINEE TRANSPORT',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'LISTE DES PASSAGERS',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Trip Info Summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TRAJET', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.5)),
                        const SizedBox(height: 6),
                        Text('Conakry → Mamou', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('DATE', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.5)),
                        const SizedBox(height: 6),
                        Text('24 Oct. 2023', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildSummaryBadge('BUS G-204', AppColors.primary.withValues(alpha: 0.1), AppColors.primary),
                    const SizedBox(width: 10),
                    _buildSummaryBadge('14/20 CONFIRMÉS', AppColors.success.withValues(alpha: 0.1), AppColors.success),
                  ],
                ),
              ],
            ),
          ),

          // Main Content: Passenger List
          Expanded(
            child: FutureBuilder<AppResponse<List<Map<String, dynamic>>>>(
              future: BookingService.getTripPassengers(widget.tripId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                
                final response = snapshot.data;
                if (response == null || !response.isSuccess || response.data == null || response.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_off_rounded, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text('Aucun passager pour le moment.',
                          style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }

                final bookings = response.data!;
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  itemCount: bookings.length + 1,
                  itemBuilder: (context, index) {
                    if (index == bookings.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ouverture SMS...')));
                          },
                          icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                          label: const Text('Contacter tous les passagers'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.textPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                        ),
                      );
                    }

                    final booking = bookings[index];
                    final profile = booking['profiles'];
                    final tickets = booking['tickets'] as List<dynamic>? ?? [];
                    final ticket = tickets.isNotEmpty ? tickets.first : null;
                    final bool isConfirmed = ticket != null && ticket['status'] == 'used';

                    return _buildPassengerCard(
                      name: profile != null ? profile['full_name'] : 'Passager Inconnu',
                      seat: '${booking['seats']} Place(s)',
                      phone: profile != null ? profile['phone'] ?? 'Non renseigné' : '',
                      imgUrl: 'https://ui-avatars.com/api/?name=${profile != null ? profile['full_name'] : 'P'}&background=random',
                      isConfirmed: isConfirmed,
                      onConfirm: () async {
                        if (ticket != null) {
                          final res = await BookingService.validateTicket(ticket['id']);
                          if (res.isSuccess) {
                            setState(() {}); 
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Présence confirmée !')));
                          }
                        }
                      }
                    );
                  },
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: textColor, letterSpacing: 0.5)),
    );
  }

  Widget _buildPassengerCard({
    required String name,
    required String seat,
    required String phone,
    required String imgUrl,
    required bool isConfirmed,
    VoidCallback? onConfirm,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                ),
                child: CircleAvatar(radius: 28, backgroundImage: NetworkImage(imgUrl), backgroundColor: AppColors.background),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name, 
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16, 
                            fontWeight: FontWeight.w800, 
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          )
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                          ),
                          child: Text(seat, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.phone_rounded, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(phone, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
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
                child: isConfirmed 
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                          const SizedBox(width: 8),
                          Text('Déjà présent', style: GoogleFonts.plusJakartaSans(color: AppColors.success, fontWeight: FontWeight.w800, fontSize: 13)),
                        ],
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: onConfirm,
                      icon: const Icon(Icons.verified_rounded, size: 18),
                      label: const Text('Confirmer présence'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.textSecondary, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

const double FullRadius = 99;
