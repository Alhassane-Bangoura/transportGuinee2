import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SyndicateTripsPage extends StatefulWidget {
  const SyndicateTripsPage({super.key});

  @override
  State<SyndicateTripsPage> createState() => _SyndicateTripsPageState();
}

class _SyndicateTripsPageState extends State<SyndicateTripsPage> {
  String _selectedTab = 'Aujourd\'hui';

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = AppColors.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                children: [
                  _buildTripCard(
                    'Conakry → Mamou',
                    'Mamadou Diallo',
                    '08:30',
                    14,
                    20,
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCv0mcVGiM6HgScSJSFHtbCvsxyOHpaLP68V1qvWJnMRRH_MYdj-ndlBCcHDHDKqD49Pb2otwSnHeKATlY8kVQji1pkjo-nq2raQ7xbVYw7i__--foH05dVvNPelp2OnL1rEu9ahwyK7P8Ko4F-XwoRGmuALtrkg6-ZGI-H3Rttqjv5WAwQ5Sh6uLEh-5pC3zNERpXKFeTDG5iIj5pp7EsQYgN_TmhLme3EM_4r-oV7l2qJiTkAm7h68cjK4lCOzK7Rq_otQVZHBDeN',
                  ),
                  const SizedBox(height: 16),
                  _buildTripCard(
                    'Conakry → Labé',
                    'Ibrahim Sow',
                    '10:15',
                    19,
                    20,
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuC7mKFlXUx-gRFfFdH9uGb9POuYDCwWUztO5KRn0w1IGXrEb4trHWjV6RbdiE2Y2At7myOCOPR8l2zY4WrIandvqDuGYhm2zZvS2Q1JhelO9-WfqSO272OZz7oIgcNhhOHpnCdMUbeCBKxv8-24U2I_z0QvnuHjJ6yyOMSsX4pw8moKB2FD2xYn_fHJ9w72-I4RFY9DyEF2k9eueprTcw1WryfgGLOhEvwBBHXG_F552wcOksgBYAsW-SW_pJN-EcSVPZ24JETMndVW',
                    isCritical: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTripCard(
                    'Conakry → Kindia',
                    'Aissatou Barry',
                    '14:00',
                    5,
                    20,
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDQ8RrChdxT4F5ka7jaa69W0WRK-DxjTsivwDFeaA5KdS1uD8mIxF6a6BVXchvWm-Bu33AJfWnfOJ_wVAOIF4MtnUmQwtlTml1_7AdLOaGDuq2ErFKah72K5OQkpJI9hTmXR_s7Ttw5c4sUtOW6t8hQgtZUtB8-FSvCqCA6RIseFCJveLsFaquRmG6LI8xHDkWwFDxTaG5CGTTOEsSsGyak8K36co5ohTYFkGHFGN60ogC41EiU-Dq7NC9c5GgojzC7lBQWlJa9OkTT',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Remplissage des véhicules',
            style: AppTextStyles.headingLarge.copyWith(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Gare: ',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                'Conakry (Bambéto)',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildTabItem('Aujourd\'hui'),
          const SizedBox(width: 8),
          _buildTabItem('Prochains'),
          const SizedBox(width: 8),
          _buildTabItem('Historique'),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label) {
    bool isActive = _selectedTab == label;
    return InkWell(
      onTap: () => setState(() => _selectedTab = label),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(String route, String driver, String time, int current, int total, String img, {bool isCritical = false}) {
    double progress = current / total;
    Color progressBarColor = isCritical ? AppColors.error : AppColors.primary;

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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                        image: DecorationImage(
                          image: NetworkImage(img),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver,
                          style: AppTextStyles.headingLarge.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          route,
                          style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    time,
                    style: AppTextStyles.headingLarge.copyWith(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Taux de remplissage',
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$current',
                        style: AppTextStyles.headingLarge.copyWith(fontSize: 18, color: AppColors.primary, fontWeight: FontWeight.w900),
                      ),
                      TextSpan(
                        text: ' / $total places',
                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(progressBarColor),
              ),
            ),
            if (isCritical) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'DERNIÈRE PLACE DISPONIBLE',
                  style: AppTextStyles.label.copyWith(color: AppColors.error, fontSize: 9, fontWeight: FontWeight.w800),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.visibility_rounded, size: 18),
                    label: const Text('Voir places'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.check_circle_rounded, size: 18),
                    label: const Text('Valider'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

