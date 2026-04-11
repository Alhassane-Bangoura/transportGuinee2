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
import 'driver_publish_trip.dart';
import '../../../core/constants/app_assets.dart';
import '../../assistant/screens/assistant_screen.dart';
import '../../../core/services/booking_service.dart';
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
      _setupRealtimeNotifications();
    }
  }

  void _setupRealtimeNotifications() {
    if (_profile == null) return;
    BookingService.getDriverBookingsStream(_profile!.id).listen((bookings) {
      if (bookings.isNotEmpty) {
        final lastBooking = bookings.first;
        final createdAt = DateTime.tryParse(lastBooking['created_at'] ?? '');
        if (createdAt != null && DateTime.now().difference(createdAt).inSeconds < 10) {
          _showBookingNotification(lastBooking);
        }
      }
    });
  }

  void _showBookingNotification(Map<String, dynamic> booking) {
    if (!mounted) return;
    final passengerName = booking['profiles']?['full_name'] ?? 'Un passager';
    final from = booking['trips']?['departure_city']?['name'] ?? '';
    final to = booking['trips']?['arrival_city']?['name'] ?? '';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Nouvelle réservation ! $passengerName pour $from ➔ $to',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'VOIR',
          textColor: Colors.white,
          onPressed: () => setState(() => _currentIndex = 2),
        ),
      ),
    );
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
    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.directions_bus, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GUINEE TRANSPORT',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Gérez vos trajets facilement',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                _buildNotificationBadge(),
              ],
            ),
            const SizedBox(height: 32),

            // Welcome Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, ${(_profile?.fullName.replaceAll(RegExp(r'\[.*?\]\s*'), '') ?? 'Mamadou').split(' ').first}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Prêt pour votre journée de route ?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Next Trip Card
            Text(
              'PROCHAIN TRAJET',
              style: AppTextStyles.label,
            ),
            const SizedBox(height: 12),
            _buildEnhancedNextTripCard(),
            const SizedBox(height: 24),

            // Stats Grid
            StreamBuilder<List<Trip>>(
              stream: _profile != null ? TripService.getDriverTripsStream(_profile!.id) : const Stream.empty(),
              builder: (context, snapshot) {
                final allTrips = snapshot.data ?? [];
                final now = DateTime.now();
                final todayStart = DateTime(now.year, now.month, now.day);
                
                final todayTrips = allTrips.where((t) {
                  final depDate = t.departureTime;
                  return depDate.year == todayStart.year && 
                         depDate.month == todayStart.month && 
                         depDate.day == todayStart.day && 
                         t.status != 'completed';
                }).toList();
                
                final remainingSeats = allTrips.where((t) => t.status != 'completed').fold<int>(0, (sum, t) => sum + t.availableSeats);

                return Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.route,
                        title: "Trajets d'aujourd'hui",
                        value: todayTrips.length.toString().padLeft(2, '0'),
                        onTap: () => setState(() => _currentIndex = 1),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.event_seat,
                        title: 'Places restantes',
                        value: remainingSeats.toString().padLeft(2, '0'),
                        iconColor: const Color(0xFF059669),
                        iconBgColor: const Color(0xFFD1FAE5),
                        onTap: () => setState(() => _currentIndex = 2),
                      ),
                    ),
                  ],
                );
              }
            ),
            const SizedBox(height: 24),

            // Quick Info Section (Rappel)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_rounded, color: AppColors.primary, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Rappel: Vérifiez l\'état des pneus avant le départ vers Labé.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Publication Card
            _buildPublishActionCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildPublishActionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nouvelle annonce',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Publiez votre prochain départ',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (_profile != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DriverPublishTripScreen(profile: _profile!),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                'PUBLIER MAINTENANT',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBadge() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 22),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedNextTripCard() {
    return StreamBuilder<List<Trip>>(
      stream: _profile != null ? TripService.getDriverTripsStream(_profile!.id) : const Stream.empty(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 160,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24)),
            child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        final trips = snapshot.data ?? [];
        final now = DateTime.now();
        // Filtrage pour trouver le prochain trajet (celui qui n'est pas fini et le plus proche dans le futur)
        final nextTrips = trips.where((t) => t.status != 'completed' && t.departureTime.add(const Duration(hours: 4)).isAfter(now)).toList();

        if (nextTrips.isEmpty) {
          return _buildEmptyTripState();
        }

        final trip = nextTrips.first;
        final formattedTime = DateFormat('HH:mm').format(trip.departureTime);
        final formattedDate = DateFormat('dd MMM').format(trip.departureTime);

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Stack(
                  children: [
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(trip.vehicleImage ?? AppAssets.vehicleImage1),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(FullRadius),
                        ),
                        child: Text(
                          trip.status.toUpperCase() == 'SCHEDULED' ? 'À VENIR' : trip.status.toUpperCase(),
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
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(trip.departureCityName, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(trip.arrivalCityName, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildCardInfo(Icons.calendar_today, formattedDate),
                        const SizedBox(width: 20),
                        _buildCardInfo(Icons.schedule, formattedTime),
                        const SizedBox(width: 20),
                        _buildCardInfo(Icons.event_seat, '${trip.availableSeats} places'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DriverPassengerList(tripId: trip.id)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Gérer les passagers', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyTripState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.route_outlined, size: 48, color: AppColors.textHint.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('Aucun trajet actif', 
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text('Cliquez sur Publier pour commencer', 
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardInfo(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    Color? iconColor,
    Color? iconBgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor ?? AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
            ),
            const SizedBox(height: 12),
            Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Voir plus', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary)),
                const Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

const double FullRadius = 99;
