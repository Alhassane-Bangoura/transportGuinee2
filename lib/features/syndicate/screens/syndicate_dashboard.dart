import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/models/user_profile.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'syndicate_drivers.dart';
import 'syndicate_add_driver.dart';
import 'syndicate_trips.dart';
import 'syndicate_profile.dart';
import '../../assistant/screens/assistant_screen.dart';

class SyndicateDashboard extends StatefulWidget {
  const SyndicateDashboard({super.key});

  @override
  State<SyndicateDashboard> createState() => _SyndicateDashboardState();
}

class _SyndicateDashboardState extends State<SyndicateDashboard> {
  UserProfile? _profile;
  bool _isLoadingProfile = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
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

    final Color primaryColor = AppColors.primary;
    final Color backgroundColor = AppColors.background;
    final Color textSlate900 = AppColors.textPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              _buildHomeContent(primaryColor, textSlate900),
              const SyndicateDriversPage(),
              const SyndicateAddDriverPage(),
              const SyndicateTripsPage(),
              SyndicateProfilePage(profile: _profile, onRefresh: _loadProfile),
            ],
          ),
          _buildBottomNav(primaryColor),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AssistantScreen(userRole: 'SYNDICAT'),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.smart_toy, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildHomeContent(Color primary, Color textColor) {
    return CustomScrollView(
      slivers: [
        _buildSliverHeader(primary, textColor),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                'Tableau de bord',
                style: AppTextStyles.headingLarge.copyWith(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              Text(
                "Aujourd'hui, Conakry",
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              _buildStatsGrid(primary),
              const SizedBox(height: 24),
              _buildPriorityAlerts(primary, textColor),
              const SizedBox(height: 24),
              _buildManagedRoutes(primary, textColor),
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
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _profile?.fullName ?? 'Syndicat Transport',
                        style: AppTextStyles.headingLarge.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Conakry, Guinée',
                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  _buildIconBtn(Icons.search_rounded),
                  const SizedBox(width: 8),
                  _buildIconBtn(Icons.notifications_none_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(Color primary) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('Chauffeurs', '1,240', '+2%', true)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Trajets', '320', '+5%', true)),
          ],
        ),
        const SizedBox(height: 12),
        _buildRevenueCard('12.5M', '+8%'),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String trend, bool isPositive) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  label == 'Chauffeurs' ? Icons.badge_outlined : Icons.route_outlined,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPositive ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trend,
                  style: AppTextStyles.label.copyWith(
                    color: isPositive ? AppColors.success : AppColors.error,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTextStyles.headingLarge.copyWith(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(String value, String trend) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Revenu Total (GNF)',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.headingLarge.copyWith(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.trending_up_rounded, color: AppColors.success, size: 24),
                const SizedBox(height: 4),
                Text(
                  trend,
                  style: AppTextStyles.label.copyWith(color: AppColors.success, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityAlerts(Color primary, Color textColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Alertes prioritaires',
                style: AppTextStyles.headingLarge.copyWith(fontSize: 18, fontWeight: FontWeight.w800)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('3 NOUVELLES',
                  style: AppTextStyles.label.copyWith(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.accent)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildAlertRow(
          Icons.priority_high_rounded,
          'Licence expirée',
          'Mamadou Diallo - Toyota Hiace AG-234',
          AppColors.error,
        ),
        const SizedBox(height: 12),
        _buildAlertRow(
          Icons.description_outlined,
          'Assurance expirée',
          'Abdoulaye Barry - Renault Master TK-091',
          AppColors.accent,
        ),
        const SizedBox(height: 12),
        _buildAlertRow(
          Icons.person_off_outlined,
          'Chauffeur suspendu',
          'Ousmane Sylla - Suspension temporaire (7j)',
          AppColors.textSecondary,
          action: 'Profil',
        ),
      ],
    );
  }

  Widget _buildAlertRow(IconData icon, String title, String desc, Color color, {String action = 'Gérer'}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                Text(desc,
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(
            action,
            style: AppTextStyles.label.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagedRoutes(Color primary, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lignes de transport gérées',
          style: AppTextStyles.headingLarge.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        _buildRouteCard('Conakry', 'Mamou', '45 départs/j', '850/j', 0.85),
        const SizedBox(height: 12),
        _buildRouteCard('Conakry', 'Labé', '28 départs/j', '520/j', 0.92),
        const SizedBox(height: 12),
        _buildRouteCard('Conakry', 'Kankan', '18 départs/j', '340/j', 0.78),
      ],
    );
  }

  Widget _buildRouteCard(String from, String to, String trips, String passengers, double progress) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(from, style: AppTextStyles.headingLarge.copyWith(fontSize: 14, fontWeight: FontWeight.w800)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.east_rounded, color: AppColors.primary, size: 16),
                    ),
                    Text(to, style: AppTextStyles.headingLarge.copyWith(fontSize: 14, fontWeight: FontWeight.w800)),
                  ],
                ),
                const Icon(Icons.more_horiz_rounded, color: AppColors.textSecondary),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildRouteMetric('Trajets', trips)),
                    Expanded(child: _buildRouteMetric('Passagers', passengers)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Taux de remplissage',
                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: AppColors.textSecondary)),
                    Text('${(progress * 100).toInt()}%',
                        style: AppTextStyles.headingLarge.copyWith(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.headingLarge.copyWith(fontSize: 15, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildIconBtn(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: Icon(icon, color: AppColors.primary, size: 20)),
    );
  }

  Widget _buildBottomNav(Color primary) {
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
            _buildNavItem(0, Icons.dashboard_rounded, 'Accueil'),
            _buildNavItem(1, Icons.badge_rounded, 'Chauffeurs'),
            _buildAddBtn(),
            _buildNavItem(3, Icons.route_rounded, 'Trajets'),
            _buildNavItem(4, Icons.person_rounded, 'Profil'),
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
            size: 24,
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

  Widget _buildAddBtn() {
    return InkWell(
      onTap: () => setState(() => _currentIndex = 2),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
