import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'passenger_tickets.dart';
import 'passenger_trips.dart';
import 'passenger_profile.dart';
import 'passenger_search_results.dart';
import 'passenger_ai_assistant.dart';
import 'passenger_reservation.dart';
import 'passenger_booking.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/models/trip.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/trip_service.dart';
import 'package:guineetransport/core/services/wallet_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/premium_bottom_nav_bar.dart';
import '../../../core/constants/app_assets.dart';

class PassengerDashboard extends StatefulWidget {
  final UserProfile? profile;
  final int initialIndex;
  const PassengerDashboard({super.key, this.profile, this.initialIndex = 0});

  @override
  State<PassengerDashboard> createState() => _PassengerDashboardState();
}

class _PassengerDashboardState extends State<PassengerDashboard> {
  late int _selectedIndex;
  UserProfile? _profile;
  bool _isLoadingProfile = true;
  StreamSubscription<NotificationModel>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    if (widget.profile != null) {
      _profile = widget.profile;
      _isLoadingProfile = false;
      _initNotifications();
    } else {
      _loadProfile();
    }
  }

  void _initNotifications() {
    NotificationService().initialize();
    _notificationSubscription = NotificationService().onNotification.listen((notification) {
      if (mounted) {
        _handleIncomingNotification(notification);
      }
    });
  }

  void _handleIncomingNotification(NotificationModel notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(notification.message, style: const TextStyle(fontSize: 12)),
                ],
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
          onPressed: () {
            setState(() {
              _selectedIndex = 1; // Naviguer vers les trajets
            });
          },
        ),
      ),
    );
  }

  Future<void> _loadProfile() async {
    final response = await AuthService.getCurrentProfile();
    if (mounted) {
      setState(() {
        _profile = response.data;
        _isLoadingProfile = false;
      });
      _initNotifications();
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
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

    final List<Widget> pages = [
      PassengerHomeContent(
        profile: _profile,
        onNavigateToTrips: () => setState(() => _selectedIndex = 1),
        onNavigateToTickets: () => setState(() => _selectedIndex = 2),
        onNavigateToProfile: () => setState(() => _selectedIndex = 3),
      ),
      const PassengerTrips(),
      const PassengerTickets(),
      PassengerProfile(profile: _profile, onRefresh: _loadProfile),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
        ),
        extendBody: true, // Important for glassmorphism
      bottomNavigationBar: PremiumBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          NavItem(icon: Icons.home, label: 'Accueil'),
          NavItem(icon: Icons.route_outlined, label: 'Trajets'),
          NavItem(icon: Icons.confirmation_number_outlined, label: 'Billets'),
          NavItem(icon: Icons.person_outline, label: 'Profil'),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PassengerAIAssistant()),
                  );
                },
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                elevation: 8,
                child: const Icon(Icons.smart_toy),
              ),
            )
          : null,
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppColors.textPrimary),
              accountName: Text(_profile?.fullName ?? 'Passager',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              accountEmail: Text(_profile?.role ?? 'passenger',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 14)),
              currentAccountPicture: CircleAvatar(
                backgroundImage: _profile?.profileImage,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: AppColors.primary),
              title: const Text('Mon Profil', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 3;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.confirmation_number, color: AppColors.primary),
              title: const Text('Mes Billets', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 2;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: AppColors.primary),
              title: const Text('Mes Trajets', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 1;
                });
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Déconnexion', style: TextStyle(color: AppColors.error)),
              onTap: () async {
                await AuthService.signOut();
                if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class PassengerHomeContent extends StatefulWidget {
  final UserProfile? profile;
  final VoidCallback? onNavigateToTrips;
  final VoidCallback? onNavigateToTickets;
  final VoidCallback? onNavigateToProfile;
  
  const PassengerHomeContent({
    super.key, 
    this.profile,
    this.onNavigateToTrips,
    this.onNavigateToTickets,
    this.onNavigateToProfile,
  });

  @override
  State<PassengerHomeContent> createState() => _PassengerHomeContentState();
}

class _PassengerHomeContentState extends State<PassengerHomeContent> {
  String _fromCity = "Conakry";
  String _toCity = "";
  DateTime _selectedDate = DateTime.now();
  int _passengers = 1;

  List<Trip> _upcomingTrips = [];
  bool _isLoadingTrips = true;

  @override
  void initState() {
    super.initState();
    // Initialisation immédiate du Wallet pour garantir la persistence du solde
    WalletService().init();
    
    _fetchUpcomingTrips();
  }

  Future<void> _fetchUpcomingTrips() async {
    final response = await TripService.getUpcomingTrips(limit: 5);
    if (mounted) {
      setState(() {
        _upcomingTrips = response.data ?? [];
        _isLoadingTrips = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showPassengerPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Nombre de passager', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPassengerBtn(Icons.remove, () {
                  if (_passengers > 1) setState(() => _passengers--);
                  Navigator.pop(context);
                  _showPassengerPicker();
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('$_passengers', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                _buildPassengerBtn(Icons.add, () {
                  if (_passengers < 10) setState(() => _passengers++);
                  Navigator.pop(context);
                  _showPassengerPicker();
                }),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('VALIDER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border.all(color: AppColors.border), shape: BoxShape.circle),
        child: Icon(icon, color: AppColors.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.95),
            border: Border(
                bottom:
                    BorderSide(color: AppColors.border.withOpacity(0.5))),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: AppColors.primary),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
            title: Text(
              'GUINEETRANSPORT',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                color: AppColors.primary,
                letterSpacing: -0.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: widget.onNavigateToProfile,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      backgroundImage: widget.profile?.profileImage,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchUpcomingTrips,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome
                  Text(
                    'Bonjour,',
                    style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                Text(
                  widget.profile?.cleanFullName ?? 'Utilisateur',
                  style: GoogleFonts.plusJakartaSans(
                      color: AppColors.primary,
                      fontSize: 34,
                      height: 1.2,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 24),

                // Search Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  String? res = await _showSimpleInputDialog('Ville de départ', 'D\'où partez-vous ?');
                                  if (res != null) setState(() => _fromCity = res);
                                },
                                child: _buildSearchField(
                                  'DE',
                                  _fromCity,
                                  Icons.trip_origin,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  // Simple input dialog for mockup
                                  String? res = await _showSimpleInputDialog('Destination', 'Où souhaitez-vous aller ?');
                                  if (res != null) setState(() => _toCity = res);
                                },
                                child: _buildSearchField(
                                  'À',
                                  _toCity.isEmpty ? 'Où souhaitez-vous aller ?' : _toCity,
                                  Icons.location_on,
                                  isHint: _toCity.isEmpty,
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            right: 30,
                            top: 45,
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.border),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.shadow,
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  )
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    setState(() {
                                      final temp = _fromCity;
                                      _fromCity = _toCity;
                                      _toCity = temp;
                                    });
                                  },
                                  child: const Icon(Icons.swap_vert,
                                      color: AppColors.primary, size: 20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _selectDate,
                              child: _buildSearchField(
                                'DATE',
                                "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                                Icons.calendar_today,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: _showPassengerPicker,
                              child: _buildSearchField(
                                'PASSAGERS',
                                '$_passengers Passager${_passengers > 1 ? 's' : ''}',
                                Icons.group,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (_toCity.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez choisir une destination')));
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PassengerSearchResults(
                                  from: _fromCity,
                                  to: _toCity,
                                  date: _selectedDate,
                                  passengers: _passengers,
                                ),
                              ),
                             );
                          },
                          icon: const Icon(Icons.search,
                              color: AppColors.onPrimary),
                          label: const Text(
                            'Trouver des Bus Disponibles',
                            style: TextStyle(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // AI Assistant Suggestion Bubble
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.smart_toy, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: Colors.blue.withOpacity(0.05)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                children: [
                                  const TextSpan(text: 'Besoin d\'aide pour trouver un bus rapide pour '),
                                  TextSpan(
                                    text: 'Labé',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const TextSpan(text: ' aujourd\'hui ?'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const PassengerAIAssistant()),
                                    );
                                  },
                                  child: _buildAIActionButton('OUI, MERCI', AppColors.primary, true),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Compris, à plus tard !')));
                                  },
                                  child: _buildAIActionButton('PLUS TARD', AppColors.textSecondary, false),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Popular Routes Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Trajets Populaires',
                      style: AppTextStyles.headingLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
                    ),
                    TextButton(
                      onPressed: widget.onNavigateToTrips,
                      child: Text(
                        'VOIR TOUT',
                        style: AppTextStyles.label.copyWith(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 280,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildRouteCard(
                        context,
                        'Conakry → Kindia',
                        '2h 30m',
                        '45,000 GNF',
                        AppAssets.vehicleVan,
                        'ACTIF',
                      ),
                      const SizedBox(width: 16),
                      _buildRouteCard(
                        context,
                        'Conakry → Labé',
                        '8h 15m',
                        '120,000 GNF',
                        AppAssets.vehicleBus,
                        'PLUS RAPIDE',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Upcoming Trips Section - Real Data
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Prochains Trajets',
                      style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20, color: AppColors.primary),
                      onPressed: _fetchUpcomingTrips,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_isLoadingTrips)
                  const Center(child: CircularProgressIndicator(color: AppColors.primary))
                else if (_upcomingTrips.isEmpty)
                  Text('Aucun trajet prévu pour le moment.', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary))
                else
                  ..._upcomingTrips.map((trip) => _buildTripListItem(trip)),

                const SizedBox(height: 32),

                // Travel Modules Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.15,
                  children: [
                    _buildBentoItem(
                      Icons.confirmation_number_outlined,
                      'Mes Billets',
                      'Voir mes tickets',
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.1),
                      onTap: widget.onNavigateToTickets,
                    ),
                    _buildBentoItem(
                      Icons.history,
                      'Historique',
                      'Tous mes trajets',
                      AppColors.primary,
                      AppColors.surface,
                      onTap: widget.onNavigateToTrips,
                    ),
                    _buildBentoItem(
                      Icons.person_outline,
                      'Mon Profil',
                      'Gérer mon compte',
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.1),
                      onTap: widget.onNavigateToProfile,
                    ),
                    _buildBentoItem(
                      Icons.smart_toy_outlined,
                      'Assistant AI',
                      'M\'aider à choisir',
                      AppColors.primary,
                      AppColors.surface,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PassengerAIAssistant()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

  Future<String?> _showSimpleInputDialog(String title, String hint) async {
    String value = "";
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          onChanged: (v) => value = v,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, value), child: const Text('OK')),
        ],
      ),
    );
  }

  Widget _buildTripListItem(Trip trip) {
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.directions_bus, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${trip.departureCityName} → ${trip.arrivalCityName}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('${trip.departureTime.day}/${trip.departureTime.month} à ${trip.departureTime.hour}:${trip.departureTime.minute.toString().padLeft(2, '0')}', 
                   style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Text(trip.formattedPrice, style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PassengerBooking(trip: trip)),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildAIActionButton(String text, Color color, bool isFilled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isFilled ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSearchField(String label, String value, IconData icon,
      {bool isHint = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    color: isHint
                        ? AppColors.textHint
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(
    BuildContext context,
    String title,
    String duration,
    String price,
    String imageUrl,
    String tag,
  ) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 130,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  image: DecorationImage(
                      image: NetworkImage(imageUrl), fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border.withOpacity(0.3)),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.plusJakartaSans(
                        color: tag == 'ACTIF' ? Colors.green : Colors.blue,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    const Icon(Icons.payments_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      price,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PassengerTrips(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'VOIR LES TRAJETS',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBentoItem(
      IconData icon, String title, String sub, Color iconColor, Color bg, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: iconColor),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  sub,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

