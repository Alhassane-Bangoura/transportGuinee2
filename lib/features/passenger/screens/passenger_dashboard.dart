import 'package:flutter/material.dart';
// Removed unused google_fonts import
import 'passenger_search_results.dart';
import 'passenger_tickets.dart';
import 'passenger_trips.dart';
import 'passenger_profile.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gt_components.dart';
import '../../assistant/screens/assistant_screen.dart';

class PassengerDashboard extends StatefulWidget {
  final UserProfile? profile;
  const PassengerDashboard({super.key, this.profile});

  @override
  State<PassengerDashboard> createState() => _PassengerDashboardState();
}

class _PassengerDashboardState extends State<PassengerDashboard> {
  int _selectedIndex = 0;
  UserProfile? _profile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    if (widget.profile != null) {
      _profile = widget.profile;
      _isLoadingProfile = false;
    } else {
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService.getCurrentProfile();
    if (mounted) {
      setState(() {
        _profile = profile;
        _isLoadingProfile = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final List<Widget> pages = [
      PassengerHomeContent(profile: _profile),
      const PassengerTickets(),
      const PassengerTrips(),
      PassengerProfile(profile: _profile, onRefresh: _loadProfile),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AssistantScreen(userRole: 'PASSAGER')),
                );
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.smart_toy, color: Colors.white),
            )
          : null,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBottomNav() {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: const Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_filled, 'Accueil', 0),
          _buildNavItem(Icons.route, 'Trajets', 2),
          _buildNavItem(Icons.confirmation_number, 'Billets', 1),
          _buildNavItem(Icons.person, 'Profil', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _selectedIndex == index;
    final color = isActive ? AppColors.primary : AppColors.textHint;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: AppTextStyles.label.copyWith(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class PassengerHomeContent extends StatelessWidget {
  final UserProfile? profile;
  const PassengerHomeContent({super.key, this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.9),
            border: Border(bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
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
              style: AppTextStyles.displayMedium.copyWith(
                fontSize: 20,
                color: AppColors.primary,
                letterSpacing: -1,
                fontWeight: FontWeight.w900,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      )
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDmEWDB4sb_ovUHBtyGDxStU2nBoTxXuGKzBlY4JDyBtxAZDP4cA0ZN2cLBvyiuXJYZJOntzwRAHG8Alsna-QTRqOuNytMZeJMD6SETIe88sEbYnmUmSLabYeGvUZeqzAzhs4AyZa0EZbCjAn2Fq5_hcr2tRsOflnfm13nGg9il3Vb44rvvuC2F0A6ADQcgqnqV76U_4DqGy--irSRIQ67vpMop558P5NU50s6_HLWg3D2BuHiilD_OkQueyuHHgVnkp3KWGSBVbo3K',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome
            Text(
              'Bonjour,',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
            Text(
              profile?.fullName ?? 'Alpha Diallo',
              style: AppTextStyles.displayMedium.copyWith(fontSize: 32, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 24),

            // Search Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
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
                          _buildSearchField(
                            'DE',
                            'Conakry, GN',
                            Icons.trip_origin,
                          ),
                          const SizedBox(height: 8),
                          _buildSearchField(
                            'À',
                            'Où souhaitez-vous aller ?',
                            Icons.location_on,
                            isHint: true,
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
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {},
                              child: const Icon(Icons.swap_vert, color: AppColors.primary, size: 20),
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
                        child: _buildSearchField(
                          'DATE',
                          'Aujourd\'hui',
                          Icons.calendar_today,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSearchField(
                          'PASSAGERS',
                          '1 Passager',
                          Icons.group,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GTButton(
                    label: 'Trouver des Bus Disponibles',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PassengerSearchResults(
                            from: 'Conakry',
                            to: 'Labé',
                            date: DateTime.now(),
                            passengers: 1,
                          ),
                        ),
                      );
                    },
                    icon: Icons.search,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // AI Suggestion Bubble
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        blurRadius: 8,
                      )
                    ],
                  ),
                  child: const Icon(Icons.smart_toy, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                            children: [
                              const TextSpan(text: 'Besoin d\'aide pour trouver un bus rapide pour '),
                              TextSpan(
                                text: 'Labé',
                                style: AppTextStyles.bodyMedium.copyWith(
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
                            Material(
                              color: AppColors.primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Text(
                                    'OUI, MERCI',
                                    style: AppTextStyles.label.copyWith(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'PLUS TARD',
                                style: AppTextStyles.label.copyWith(color: AppColors.textHint, fontSize: 10, fontWeight: FontWeight.w800),
                              ),
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
                  style: AppTextStyles.headingLarge.copyWith(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'VOIR TOUT',
                    style: AppTextStyles.label.copyWith(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800),
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
                    'Conakry → Kindia',
                    '2h 30m',
                    '45,000 GNF',
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDqLYwyZCz2D62e9tSuKVI2N_qEeQn1uhKlB6TGKtdlWSBcPPdXZuYA0HaLY_LjdwA12lOwykfHhmtaDJ1NBJJqqksOQ4KSIl152duWg7gQhC7ggpIAEap0YUVW5iqvBp-id6d2UR10j4ewjkpnnaDt1p3c1B4nxNrNPavTznSEchoakLfT98SDVcpmhsERz0dK41nQ4QRQg3iQUroleeHvpxuLIg4NDQbnsKP67McyPZBpXEXqROeozmpJ2mxjpTpizjPgGUI3zDZ8',
                    'ACTIF',
                    const Color(0xFFE8F5E9),
                    const Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 16),
                  _buildRouteCard(
                    'Conakry → Labé',
                    '8h 15m',
                    '120,000 GNF',
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBmlsLwxj8Tew0XJ295owiMqeGNcOuYg5COipx6v69rvw-29eyb0THmCbPtsF8gZ6ZPpyXl5QfgrPPocIw4N_4hYkrlQVuDbAh20g6OIXBxTj1xU5Fco24r5pepWV0vV4JGJFNw2jQyWhao3aMogUP8S7luAgZk8xZl-ch7HdOlWUxbSzifpzJrQ65tWMnERWvHodqE2CwMVjQAgrXOaEqThjfFnIJ-VRhcLvAk8LYy7opdYeF3ntsRtwwLCXaonjjF65Bd9H4zQDA0',
                    'PLUS RAPIDE',
                    const Color(0xFFE3F2FD),
                    const Color(0xFF1565C0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Travel Modules Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _buildBentoItem(
                  Icons.confirmation_number_outlined,
                  'Mes Billets',
                  '2 Voyages à venir',
                  AppColors.primaryLight,
                  AppColors.primary,
                ),
                _buildBentoItem(
                  Icons.history,
                  'Historique',
                  '14 Voyages terminés',
                  AppColors.textPrimary,
                  AppColors.white,
                ),
              ],
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    ),
  ],
);
}

  Widget _buildSearchField(String label, String value, IconData icon, {bool isHint = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
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
                  style: AppTextStyles.label.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textHint,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isHint ? AppColors.textHint : AppColors.textPrimary,
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
    String title,
    String duration,
    String price,
    String imageUrl,
    String tag,
    Color tagBg,
    Color tagText,
  ) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                  image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: tagBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: AppTextStyles.label.copyWith(color: tagText, fontSize: 9, fontWeight: FontWeight.w800),
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
                  style: AppTextStyles.headingLarge.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.payments_outlined, size: 14, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(
                      price,
                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      foregroundColor: AppColors.primary,
                    ),
                    child: Text(
                      'RÉSERVER MAINTENANT',
                      style: AppTextStyles.label.copyWith(fontSize: 10, fontWeight: FontWeight.w800),
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

  Widget _buildBentoItem(IconData icon, String title, String sub, Color color, Color bg) {
    bool isPrimary = bg == AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: isPrimary ? null : Border.all(color: AppColors.border),
        boxShadow: isPrimary ? [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.headingLarge.copyWith(
              fontSize: 16,
              color: isPrimary ? AppColors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            sub,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 11,
              color: isPrimary ? AppColors.white.withValues(alpha: 0.8) : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
