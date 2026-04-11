import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/trip.dart';
import '../../../core/services/trip_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user_profile.dart';
import 'package:intl/intl.dart';
import 'driver_passenger_list.dart';

class DriverMyTrips extends StatefulWidget {
  const DriverMyTrips({super.key});

  @override
  State<DriverMyTrips> createState() => _DriverMyTripsState();
}

class _DriverMyTripsState extends State<DriverMyTrips> {
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final response = await AuthService.getCurrentProfile();
    if (mounted) {
      setState(() {
        _profile = response.data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
            onPressed: () {},
          ),
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
                'SUIVEZ VOS TRAJETS',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            _buildNotificationIcon(),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
            tabs: const [
              Tab(text: 'AUJOURD\'HUI'),
              Tab(text: 'PROCHAINS'),
              Tab(text: 'HISTORIQUE'),
            ],
          ),
        ),
        body: StreamBuilder<List<Trip>>(
          stream: _profile != null ? TripService.getDriverTripsStream(_profile!.id) : const Stream.empty(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allTrips = snapshot.data ?? [];
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);

            final todayTrips = allTrips.where((t) {
              final depDate = t.departureTime;
              return depDate.year == today.year && 
                     depDate.month == today.month && 
                     depDate.day == today.day && 
                     t.status != 'completed';
            }).toList();

            final nextTrips = allTrips.where((t) {
              final depDate = t.departureTime;
              final isToday = depDate.year == today.year && 
                             depDate.month == today.month && 
                             depDate.day == today.day;
              return depDate.isAfter(now) && !isToday;
            }).toList();

            final historyTrips = allTrips.where((t) => t.status == 'completed' || t.departureTime.isBefore(now)).toList();

            return TabBarView(
              children: [
                _buildTripList(todayTrips, 'Aujourd\'hui'),
                _buildTripList(nextTrips, 'Prochains'),
                _buildTripList(historyTrips, 'Historique'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTripList(List<Trip> trips, String type) {
    if (trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.route_outlined, size: 64, color: AppColors.textHint.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'Aucun trajet dans $type',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return _buildTripCard(
          trip: trip,
          status: _getDisplayStatus(trip.status),
          statusColor: _getStatusColor(trip.status),
        );
      },
    );
  }

  String _getDisplayStatus(String status) {
    switch (status) {
      case 'scheduled': return 'PROGRAMMÉE';
      case 'boarding': return 'EN COURS';
      case 'in_transit': return 'EN ROUTE';
      case 'completed': return 'TERMINÉ';
      case 'cancelled': return 'ANNULÉ';
      default: return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled': return AppColors.textSecondary;
      case 'boarding': return AppColors.primary;
      case 'in_transit': return AppColors.success;
      case 'completed': return Colors.grey;
      case 'cancelled': return AppColors.error;
      default: return AppColors.primary;
    }
  }

  Widget _buildNotificationIcon() {
    return Stack(
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
            decoration: BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTripCard({
    required Trip trip,
    required String status,
    required Color statusColor,
    double opacity = 1.0,
  }) {
    final dateFormat = DateFormat('hh:mm a');
    final time = dateFormat.format(trip.departureTime);
    final route = '${trip.departureCityName} → ${trip.arrivalCityName}';
    
    return Opacity(
      opacity: opacity,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/bus_mock.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 9,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            route,
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.schedule_rounded, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                '$time • Bus VIP',
                                style: GoogleFonts.inter(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${trip.totalSeats ?? 0}',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'PASSAGERS',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textSecondary,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DriverPassengerList(tripId: trip.id)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: status == 'EN COURS' || status == 'EN ROUTE' ? AppColors.primary : AppColors.surfaceVariant,
                            foregroundColor: status == 'EN COURS' || status == 'EN ROUTE' ? Colors.white : AppColors.textPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text(
                            'Voir les passagers',
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14),
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
                          icon: const Icon(Icons.map_rounded, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
