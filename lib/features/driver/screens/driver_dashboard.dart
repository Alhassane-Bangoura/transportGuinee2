import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/models/user_profile.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'driver_trips.dart';
import 'driver_passengers.dart';
import 'driver_profile.dart';
import '../../assistant/screens/assistant_screen.dart';

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

  final List<Map<String, dynamic>> _passengers = [
    {
      'name': 'Amadou Diallo',
      'initials': 'AD',
      'seat': '04',
      'ticket': '#GT-2309',
      'checked': true
    },
    {
      'name': 'Mariama Sylla',
      'initials': 'MS',
      'seat': '07',
      'ticket': '#GT-2311',
      'checked': false
    },
  ];

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
          child: CircularProgressIndicator(color: AppColors.success),
        ),
      );
    }

    final Color primaryColor = AppColors.primary;
    final Color backgroundColor = AppColors.background;
    final Color textSlate900 = AppColors.textPrimary;
    final Color textSlate500 = AppColors.textSecondary;
    final Color textSlate400 = AppColors.textHint;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              _buildHomeContent(primaryColor, textSlate900, textSlate500, textSlate400),
              const DriverTripsPage(),
              const DriverPassengersPage(),
              DriverProfilePage(profile: _profile, onRefresh: _loadProfile),
            ],
          ),
          _buildBottomNav(primaryColor, textSlate400),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AssistantScreen(userRole: 'CHAUFFEUR'),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.smart_toy, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildHomeContent(Color primaryColor, Color textSlate900, Color textSlate500, Color textSlate400) {
    return CustomScrollView(
      slivers: [
        _buildSliverHeader(primaryColor, textSlate900),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildSectionHeader('Trajet du jour', trailing: 'Détails'),
              const SizedBox(height: 12),
              _buildDailyTripCard(primaryColor),
              const SizedBox(height: 24),
              _buildSectionHeader('Revenus', trailing: 'Mise à jour à 10:45'),
              const SizedBox(height: 12),
              _buildEarningsCard(primaryColor, textSlate900, textSlate500, textSlate400),
              const SizedBox(height: 24),
              _buildSectionHeader('Liste du trajet actuel', trailing: '12 Présents'),
              const SizedBox(height: 12),
              _buildPassengerList(primaryColor, textSlate900, textSlate500),
              const SizedBox(height: 24),
              _buildSectionHeader('Documents véhicule'),
              const SizedBox(height: 12),
              _buildDocumentsList(primaryColor, textSlate900),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverHeader(Color primary, Color textColor) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      expandedHeight: 80,
      toolbarHeight: 80,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.accent.withValues(alpha: 0.2), width: 2),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            'https://i.pravatar.cc/150?u=chauffeur',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _profile?.fullName ?? 'Moussa Camara',
                        style: AppTextStyles.headingLarge.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            'Conakry, Guinée',
                            style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Text(
                      'En ligne',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    ScaleTransition(
                      scale: Tween(begin: 0.8, end: 1.2).animate(_pulseController),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.headingLarge.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: AppTextStyles.label.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: trailing.startsWith('Mise') ? AppColors.textSecondary : AppColors.accent,
            ),
          ),
      ],
    );
  }

  Widget _buildDailyTripCard(Color primary) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Stack(
              children: [
                Image.network(
                  'https://i.ibb.co/v4mS8N6/bus-interior.jpg',
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.primary.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PROCHAIN DÉPART',
                            style: AppTextStyles.label.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            'Conakry → Labé',
                            style: AppTextStyles.headingLarge.copyWith(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 24),
                      ),
                    ],
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
                    _buildTripInfoItem(Icons.schedule_rounded, 'DÉPART', '08:00'),
                    const SizedBox(width: 32),
                    _buildTripInfoItem(Icons.group_rounded, 'PASSAGERS', '12 / 15'),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                            children: [
                              const TextSpan(text: 'Statut : '),
                              TextSpan(
                                text: 'Prêt au départ',
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.success, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'DÉMARRER LE TRAJET',
                            style: AppTextStyles.label.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'PASSAGERS',
                            style: AppTextStyles.label.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: AppColors.textHint,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEarningsCard(Color primary, Color textColor, Color subColor, Color barColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Aujourd'hui",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "450.000 GNF",
                style: AppTextStyles.headingLarge.copyWith(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Simplified Bar Chart
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(0.4, AppColors.primary.withValues(alpha: 0.1)),
                _buildBar(0.6, AppColors.primary.withValues(alpha: 0.1)),
                _buildBar(0.3, AppColors.primary.withValues(alpha: 0.1)),
                _buildBar(0.8, AppColors.primary.withValues(alpha: 0.1)),
                _buildBar(0.5, AppColors.primary.withValues(alpha: 0.1)),
                _buildBar(0.9, AppColors.primary.withValues(alpha: 0.1)),
                _buildBar(0.7, AppColors.accent),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.border),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CETTE SEMAINE',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textHint,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '2.8M GNF',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CE MOIS',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textHint,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '10.5M GNF',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double heightFactor, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          height: 60 * heightFactor,
        ),
      ),
    );
  }

  Widget _buildPassengerList(Color primary, Color textColor, Color subColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ..._passengers.map((p) => _buildPassengerRow(p, primary, textColor, subColor)),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Voir les 10 autres',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.expand_more_rounded, color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerRow(Map<String, dynamic> p, Color primary, Color textColor, Color subColor) {
    bool isLast = _passengers.last == p;
    bool isChecked = p['checked'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isChecked ? AppColors.primary.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  p['initials'],
                  style: AppTextStyles.headingLarge.copyWith(
                    color: isChecked ? AppColors.primary : AppColors.textHint,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p['name'],
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Siège ${p['seat']} • Ticket ${p['ticket']}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Icon(
            isChecked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: isChecked ? AppColors.primary : AppColors.border,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList(Color primary, Color textColor) {
    return Column(
      children: [
        _buildDocumentItem(Icons.badge_outlined, 'Permis de conduire', 'VÉRIFIÉ',
            const Color(0xFFF0FDF4), AppColors.success, AppColors.success),
        const SizedBox(height: 12),
        _buildDocumentItem(Icons.description_outlined, 'Assurance véhicule', 'EN ATTENTE',
            const Color(0xFFFFF7ED), AppColors.accent, AppColors.accent),
        const SizedBox(height: 12),
        _buildDocumentItem(Icons.warning_amber_rounded, 'Carte technique', 'EXPIRÉ',
            const Color(0xFFFEF2F2), AppColors.error, AppColors.error,
            hasBorder: true),
      ],
    );
  }

  Widget _buildDocumentItem(
      IconData icon, String title, String status, Color bg, Color textCol, Color iconCol,
      {bool hasBorder = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: hasBorder ? AppColors.error : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconCol.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconCol, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status,
                      style: AppTextStyles.label.copyWith(
                        color: textCol,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 24),
        ],
      ),
    );
  }

  Widget _buildBottomNav(Color primary, Color inactive) {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.home_rounded, 'Accueil'),
            _buildNavItem(1, Icons.route_rounded, 'Trajets'),
            _buildNavItem(2, Icons.group_rounded, 'Passagers'),
            _buildNavItem(3, Icons.person_rounded, 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.accent : Colors.white.withValues(alpha: 0.4),
            size: 26,
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
