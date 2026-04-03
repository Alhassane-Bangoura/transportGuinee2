import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../../core/models/user_profile.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/trip.dart';
import '../../../core/services/trip_service.dart';
import 'package:intl/intl.dart';
import 'driver_trips.dart';
import 'driver_passengers.dart';
import 'driver_profile.dart';
import 'driver_passenger_list.dart';
import '../../assistant/screens/assistant_screen.dart';
import '../../../core/widgets/premium_bottom_nav_bar.dart';

class DriverDashboard extends StatefulWidget {
  final UserProfile? profile;
  const DriverDashboard({super.key, this.profile});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard>
    with SingleTickerProviderStateMixin {
  UserProfile? _profile;
  bool _isLoadingProfile = true;
  late AnimationController _pulseController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    if (widget.profile != null) {
      _profile = widget.profile;
      _isLoadingProfile = false;
    } else {
      _loadProfile();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final response = await AuthService.getCurrentProfile();
    if (mounted) {
      setState(() {
        _profile = response.data;
        _isLoadingProfile = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(),
          const DriverTripsPage(),
          const DriverPassengersPage(),
          DriverProfilePage(profile: _profile, onRefresh: _loadProfile),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: PremiumBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          NavItem(icon: Icons.home, label: 'Accueil'),
          NavItem(icon: Icons.route_outlined, label: 'Trajets'),
          NavItem(icon: Icons.group_outlined, label: 'Passagers'),
          NavItem(icon: Icons.person_outline, label: 'Profil'),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: FloatingActionButton(
                onPressed: () {
                  final role = _profile?.role.toUpperCase() ?? 'CHAUFFEUR';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AssistantScreen(userRole: role),
                    ),
                  );
                },
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.smart_toy, color: AppColors.onPrimary),
              ),
            )
          : null,
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour, ${_profile?.fullName.split(' ').first ?? 'Mamadou'}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Prêt pour votre journée de route ?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: AppColors.border)),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary, size: 24),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(10),
                    ),
                  ),
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: AppColors.background, width: 2)),
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),

          // Next Trip Card
          Text(
            'PROCHAIN TRAJET',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textHint,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<Trip>>(
            stream: _profile != null ? TripService.getDriverTripsStream(_profile!.id) : const Stream.empty(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              final trips = snapshot.data ?? [];
              if (trips.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text('Aucun trajet assigné pour le moment.',
                        style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 14)),
                  ),
                );
              }

              final nextTrip = trips.first;
              final timeFormat = DateFormat('hh:mm a');
              final formattedTime = timeFormat.format(nextTrip.departureTime);

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 160,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            image: DecorationImage(
                              image: AssetImage('assets/images/bus_mock.png'), // Fallback direct or standard bg
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          height: 160,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              nextTrip.status.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      nextTrip.departureCityName,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 18),
                                    ),
                                    Text(
                                      nextTrip.arrivalCityName,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildQuickInfo(Icons.schedule, formattedTime),
                              const SizedBox(width: 20),
                              _buildQuickInfo(Icons.group_outlined, '${nextTrip.totalSeats ?? 0} places'),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => DriverPassengerList(tripId: nextTrip.id)),
                                );
                              },
                              icon: const Icon(Icons.visibility_outlined, size: 20),
                              label: Text('Détails du Trajet', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          ),
          const SizedBox(height: 24),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.route_outlined,
                  title: 'Trajets aujourd\'hui',
                  value: '03',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.event_seat_outlined,
                  title: 'Places restantes',
                  value: '08',
                  color: Colors.green,
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Reminder Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Rappel: Vérifiez l\'état des pneus avant le départ vers Labé.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    Color? color,
    required VoidCallback onTap,
  }) {
    final displayColor = color ?? AppColors.primary;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: displayColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: displayColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Voir tout',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
