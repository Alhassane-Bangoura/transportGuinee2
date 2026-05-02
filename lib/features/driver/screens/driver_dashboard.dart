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
import 'dart:async';
import '../../../core/models/notification_model.dart';
import 'driver_ai_assistant.dart';
import '../../../core/services/booking_service.dart';
import '../../../core/widgets/premium_bottom_nav_bar.dart';
import '../../../core/services/notification_service.dart';
import 'driver_notifications.dart';
import 'driver_help_support.dart';
import 'driver_settings.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _unreadCount = 0;
  late StreamSubscription<NotificationModel> _notificationSubscription;

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
      _initNotificationService();
    } else {
      _loadProfile();
    }
  }

  void _initNotificationService() {
    NotificationService().initialize();
    _notificationSubscription = NotificationService().onNotification.listen((notification) {
      _loadUnreadCount();
      _showBookingNotificationFromModel(notification);
    });
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final notifications = await NotificationService().getNotifications();
    if (mounted) {
      setState(() {
        _unreadCount = notifications.where((n) => !n.isRead).length;
      });
    }
  }

  void _showBookingNotificationFromModel(NotificationModel notification) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${notification.title}: ${notification.message}',
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
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DriverNotificationsScreen()),
          ).then((_) => _loadUnreadCount()),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _notificationSubscription.cancel();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final response = await AuthService.getCurrentProfile();
    if (mounted) {
      setState(() {
        _profile = response.data;
        _isLoadingProfile = false;
      });
      _initNotificationService();
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
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DriverAIAssistant(),
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
                    IconButton(
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.menu, color: Colors.white, size: 24),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
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
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DriverNotificationsScreen()),
                    ).then((_) => _loadUnreadCount());
                  },
                  child: _buildNotificationBadge(),
                ),
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
                final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
                
                final todayTrips = allTrips.where((t) {
                  return t.departureTime.isAfter(todayStart) && 
                         t.departureTime.isBefore(todayEnd) && 
                         t.status.toUpperCase() != 'COMPLETED';
                }).toList();
                
                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: BookingService.getDriverBookingsStream(_profile!.id),
                  builder: (context, bookingSnapshot) {
                    final allBookings = bookingSnapshot.data ?? [];
                    
                    // Calcul des places restantes sur tous les trajets programmés (disponibles actuellement)
                    int totalRemaining = 0;
                    for (var t in allTrips) {
                      if (t.status.toUpperCase() == 'SCHEDULED' || t.status.toUpperCase() == 'PROGRAMMÉE') {
                        totalRemaining += t.availableSeats;
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.route,
                                title: "Trajets d'aujourd'hui",
                                value: todayTrips.isEmpty ? '00' : todayTrips.length.toString().padLeft(2, '0'),
                                onTap: () => setState(() => _currentIndex = 1),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.event_seat,
                                title: 'Places restantes',
                                value: totalRemaining.toString().padLeft(2, '0'),
                                iconColor: const Color(0xFF059669),
                                iconBgColor: const Color(0xFFD1FAE5),
                                onTap: () => setState(() => _currentIndex = 2),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('VOS TRAJETS DU JOUR', style: AppTextStyles.label),
                            TextButton(
                              onPressed: () => setState(() => _currentIndex = 1),
                              child: Text('Voir tout', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (todayTrips.isEmpty)
                          _buildEmptyTripListMini()
                        else
                          ...todayTrips.map((t) => _buildTodayTripMiniCard(t, allBookings)),
                      ],
                    );
                  }
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
                  ).then((_) => setState(() {}));
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
        if (_unreadCount > 0)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  _unreadCount > 9 ? '+' : _unreadCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 6, fontWeight: FontWeight.bold),
                ),
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
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return Container(
            height: 160,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24)),
            child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        final trips = snapshot.data ?? [];
        final now = DateTime.now();
        
        // Trouver le trajet le plus proche (Tant qu'il n'est pas terminé)
        final activeTrips = trips.where((t) => 
          t.status.toUpperCase() != 'COMPLETED' && 
          t.status.toUpperCase() != 'TERMINÉ' &&
          t.departureTime.add(const Duration(hours: 4)).isAfter(now)
        ).toList();
        
        // Trier par date de départ (le plus proche en premier)
        activeTrips.sort((a, b) => a.departureTime.compareTo(b.departureTime));

        if (activeTrips.isEmpty) {
          return _buildEmptyTripState();
        }

        final trip = activeTrips.first;
        final formattedTime = DateFormat('HH:mm').format(trip.departureTime);
        final formattedDate = DateFormat('dd MMM').format(trip.departureTime);

        // Récupérer les réservations pour ce trajet spécifique en temps réel
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: BookingService.getDriverBookingsStream(_profile!.id),
          builder: (context, bookingSnapshot) {
            // On utilise directement availableSeats car le trigger de la base de données décrémente déjà cette valeur
            final realAvailableSeats = trip.availableSeats;

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
                            _buildCardInfo(Icons.event_seat, '$realAvailableSeats places'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => _currentIndex = 2);
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
          }
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

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.surface, border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: _profile?.profileImage ?? NetworkImage(AppAssets.stationPreview),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _profile?.fullName ?? 'Chauffeur',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: AppColors.textPrimary),
            title: Text('Aide & Support', style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverHelpSupportScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            title: Text('Paramètres', style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverSettingsScreen()));
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: Text('Déconnexion', style: GoogleFonts.plusJakartaSans(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () async {
              try {
                // S'assurer que le drawer est fermé avant de naviguer
                Navigator.pop(context);
                await AuthService.signOut();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              } catch (e) {
                print('Logout error: $e');
              }
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
  Widget _buildEmptyTripListMini() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Center(
        child: Text('Aucun autre trajet prévu aujourd\'hui.', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 13)),
      ),
    );
  }

  Widget _buildTodayTripMiniCard(Trip t, List<Map<String, dynamic>> allBookings) {
    final tripBookings = allBookings.where((b) => b['trip_id'] == t.id && b['status'] != 'cancelled').toList();
    final bookedSeats = tripBookings.fold<int>(0, (sum, b) => sum + (b['seats'] as int));
    // La capacité publiée d'origine est simplement les places restantes actuelles + les places déjà prises
    final totalPublishedSeats = t.availableSeats + bookedSeats;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Text(DateFormat('HH:mm').format(t.departureTime), style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 14)),
                Text('Départ', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary.withOpacity(0.6))),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${t.departureCityName} → ${t.arrivalCityName}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 15)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.people_outline, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('$bookedSeats/$totalPublishedSeats réservés', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Supprimer le trajet ?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                  content: Text('Voulez-vous vraiment supprimer ce trajet ? Cette action est irréversible.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ANNULER')),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true), 
                      child: const Text('SUPPRIMER', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                final res = await TripService.deleteTrip(t.id);
                if (mounted) {
                  if (res.isSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trajet supprimé avec succès')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message), backgroundColor: Colors.red));
                  }
                }
              }
            },
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DriverPassengerList(tripId: t.id)),
              );
            },
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

const double FullRadius = 99;
