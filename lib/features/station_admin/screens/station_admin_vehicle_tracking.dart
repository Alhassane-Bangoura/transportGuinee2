import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Écran de Suivi des Véhicules pour l'Admin de Gare
/// Correspond à suivi_des_vehicule_admin.html
class StationAdminVehicleTracking extends StatefulWidget {
  const StationAdminVehicleTracking({super.key});

  @override
  State<StationAdminVehicleTracking> createState() => _StationAdminVehicleTrackingState();
}

class _StationAdminVehicleTrackingState extends State<StationAdminVehicleTracking> {
  String _selectedFilter = 'Tous';
  final List<String> _filters = ['Tous', 'En attente', 'Remplissage', 'Prêt'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildVehicleCard(
                  plate: 'RC-4452-B',
                  destination: 'Vers Labé',
                  driver: 'Amadou Diallo',
                  status: 'Remplissage',
                  currentSeats: 12,
                  totalSeats: 15,
                  statusColor: Colors.orange,
                  progress: 0.8,
                  timeText: 'Arrivée: 08:30',
                ),
                const SizedBox(height: 16),
                _buildVehicleCard(
                  plate: 'RC-8812-A',
                  destination: 'Vers Kankan',
                  driver: 'Moussa Camara',
                  status: 'Prêt',
                  currentSeats: 15,
                  totalSeats: 15,
                  statusColor: Colors.green,
                  progress: 1.0,
                  timeText: 'Départ imminent',
                  showAction: true,
                  actionLabel: 'Confirmer Départ',
                ),
                const SizedBox(height: 16),
                _buildVehicleCard(
                  plate: 'RC-2233-C',
                  destination: 'Vers Nzérékoré',
                  driver: 'Ibrahima Barry',
                  status: 'En attente',
                  currentSeats: 0,
                  totalSeats: 22,
                  statusColor: AppColors.textSecondary,
                  progress: 0.0,
                  timeText: 'Position 4 dans la file',
                  opacity: 0.75,
                ),
                const SizedBox(height: 16),
                _buildVehicleCard(
                  plate: 'RC-5561-X',
                  destination: 'Vers Mamou',
                  driver: 'Souleymane Sylla',
                  status: 'Parti',
                  currentSeats: 15,
                  totalSeats: 15,
                  statusColor: Colors.blue,
                  progress: 1.0,
                  timeText: 'Départ: 07:15',
                  isTracking: true,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.directions_bus, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GUINEE TRANSPORT',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Suivi de la flotte en gare',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Stack(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Rechercher par numéro de plaque...',
                hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                icon: Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                border: InputBorder.none,
              ),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ] : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        filter,
                        style: GoogleFonts.plusJakartaSans(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard({
    required String plate,
    required String destination,
    required String driver,
    required String status,
    required int currentSeats,
    required int totalSeats,
    required Color statusColor,
    required double progress,
    required String timeText,
    bool showAction = false,
    String actionLabel = '',
    bool isTracking = false,
    double opacity = 1.0,
  }) {
    return Opacity(
      opacity: opacity,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              plate,
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            destination,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            color: statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.person, color: AppColors.textSecondary, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        driver,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.event_seat, color: AppColors.primary, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '$currentSeats / $totalSeats',
                        style: GoogleFonts.plusJakartaSans(
                          color: isTracking ? Colors.blue : (progress >= 1.0 ? Colors.green : AppColors.primary),
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.background,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.3),
                border: const Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    timeText,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (showAction)
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: Text(
                        actionLabel,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: [
                          Text(
                            isTracking ? 'Suivre' : 'Gérer',
                            style: TextStyle(
                              color: isTracking ? Colors.blue : AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Icon(
                            isTracking ? Icons.map : Icons.chevron_right,
                            color: isTracking ? Colors.blue : AppColors.primary,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
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
          _buildNavItem(Icons.warehouse, 'Gare', true),
          _buildNavItem(Icons.directions_bus, 'Flotte', false),
          _buildAddButton(),
          _buildNavItem(Icons.calendar_today, 'Planning', false),
          _buildNavItem(Icons.account_circle, 'Profil', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? AppColors.primary : AppColors.textSecondary, size: 24),
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

  Widget _buildAddButton() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(color: AppColors.background, width: 4),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
