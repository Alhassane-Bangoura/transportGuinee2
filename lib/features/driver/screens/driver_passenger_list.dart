import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/services/booking_service.dart';
import '../../../core/utils/app_response.dart';

/// Écran de la Liste des Passagers pour le Chauffeur
/// Correspond à liste_passager_chauffeur.html
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
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
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
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
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
                        Text('TRAJET', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text('Conakry → Mamou', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('DATE', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text('24 Oct. 2023', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildSummaryBadge('BUS G-204', AppColors.primary, Colors.white),
                    const SizedBox(width: 8),
                    _buildSummaryBadge('14/20 CONFIRMÉS', Colors.teal.withValues(alpha: 0.2), Colors.teal),
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
                    child: Text('Aucun passager pour le moment.',
                      style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
                  );
                }

                final bookings = response.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  itemCount: bookings.length + 1, // +1 for the button at the bottom
                  itemBuilder: (context, index) {
                    if (index == bookings.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 32, bottom: 20),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ouverture SMS...')));
                          },
                          icon: const Icon(Icons.group, size: 20),
                          label: const Text('Contacter tous les passagers'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 10,
                            shadowColor: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                      );
                    }

                    final booking = bookings[index];
                    final profile = booking['profiles'];
                    final tickets = booking['tickets'] as List<dynamic>? ?? [];
                    final ticket = tickets.isNotEmpty ? tickets.first : null;
                    final bool isConfirmed = ticket != null && ticket['status'] == 'used';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildPassengerCard(
                        name: profile != null ? profile['full_name'] : 'Inconnu',
                        seat: '${booking['seats']} Place(s)',
                        phone: profile != null ? profile['phone'] ?? 'Non renseigné' : '',
                        imgUrl: 'https://cdn-icons-png.flaticon.com/512/149/149071.png', // Default icon
                        isConfirmed: isConfirmed,
                        onConfirm: () async {
                          if (ticket != null) {
                            final res = await BookingService.validateTicket(ticket['id']);
                            if (res.isSuccess) {
                              setState(() {}); // refresh the UI locally easily
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Présence confirmée !')));
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pas de ticket valide.')));
                          }
                        }
                      ),
                    );
                  },
                );
              }
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSummaryBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(100)),
      child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: textColor, letterSpacing: 0.5)),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isConfirmed ? Colors.teal.withValues(alpha: 0.03) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isConfirmed ? Colors.teal.withValues(alpha: 0.2) : AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(radius: 28, backgroundImage: NetworkImage(imgUrl)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(6)),
                          child: Text(seat, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.call, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(phone, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.1),
                        border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.verified, color: Colors.teal, size: 18),
                          const SizedBox(width: 8),
                          Text('Déjà présent', style: GoogleFonts.plusJakartaSans(color: Colors.teal, fontWeight: FontWeight.w800, fontSize: 13)),
                        ],
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: onConfirm,
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Confirmer présence'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primary, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 90,
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 'Accueil', false),
          _buildNavItem(Icons.route_outlined, 'Trajets', false),
          _buildNavItem(Icons.group, 'Passagers', true),
          _buildNavItem(Icons.person_outline, 'Profil', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? AppColors.primary : AppColors.textSecondary, size: 28),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
