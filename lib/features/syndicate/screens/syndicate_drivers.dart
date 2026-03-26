import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SyndicateDriversPage extends StatefulWidget {
  const SyndicateDriversPage({super.key});

  @override
  State<SyndicateDriversPage> createState() => _SyndicateDriversPageState();
}

class _SyndicateDriversPageState extends State<SyndicateDriversPage> {
  String _selectedFilter = 'Tous';

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = AppColors.primary;
    final Color backgroundColor = AppColors.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(primaryColor),
            _buildFilters(primaryColor),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                children: [
                  _buildDriverCard(
                    'Moussa Diallo',
                    'RC-7782-A',
                    'Conakry → Mamou',
                    'ACTIF',
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCP0rDp0R3mZikQxmxBOp5UDJ6W4hl_rIkm-oNWh3_b1zabnymlkfGkrmoWI609p-Bx_exC_X-7UiILImGbq642RbGX8liQ9qcLZNuXYqdn4bgDj8Y3JBe-hhfGyETyUf5u2oR6HovCctUqtiJNeYYU7xq2pZK9Pt-t4vOEuZhJVT19fsy5gHvT2zCKpgNZQLEaIg1kxsyVNlWjiBJfoO6EcVjmd1O_YXVMIS6OjFsRfYZzoy2gYhj57SS8xwLxdRf3QDRw9MO0ifpL',
                    true,
                  ),
                  const SizedBox(height: 16),
                  _buildDriverCard(
                    'Abdoulaye Sow',
                    'RC-0912-B',
                    'Conakry → Labé',
                    'REPOS',
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBVgq9NadZRK-yFcdjoQVOYTmMUzEN96KcbN29w7TbCMJnlPtSddqy5Fmq931XfEutWbYXOW5rpAtl1xt5bxCRvH0C7xdQp7zmlbSOtDWaIGvNCjV51OB_NQwzi5v0Rq7pW3EQmh0tAVRFOpgB46L2YK7goP8qtoHU9jbtsRBSqWm_ul0REtAO9V3n6UOubKdmUzZTJ1VePmexUyOhIuqSK6Waj0l0jiH7K9OUqD32fT3qPCvWFh4it2cvMEh4Bzyc0hQvc2ceMxNWe',
                    false,
                    isResting: true,
                  ),
                  const SizedBox(height: 16),
                  _buildDriverCard(
                    'Mariama Camara',
                    'RC-4456-C',
                    'Conakry → Kindia',
                    'ACTIF',
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCio8Yn3wYtyx58BMDugN3VbPq-IuAnbIv87P1YbOOX5bZjAOt35WOkBGzH_4FSxGQnx_0QeVbV9gKLJpHRyIyiKAzsBNpeKMW9m6dZ3Gw2DvFhyP95pOWf4fTt4QbUzUAqSl-p-csICHRvn7zbIM8LMzvFi7qeTO-M9zmg_Mj5sowL72G1n8BEK5rgwjvNtHTuKYOcUA99NHezENhLqGdmS4ES1YoMaACSnD7TzH2tPukp-OljsWAx2M73sHfdPL9RFD8NQ77Ml48w',
                    true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color primary) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gestion des Chauffeurs',
                style: AppTextStyles.headingLarge.copyWith(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Supervisez votre équipe et la flotte en temps réel.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(Color primary) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('Tous'),
          const SizedBox(width: 8),
          _buildFilterChip('Actifs'),
          const SizedBox(width: 8),
          _buildFilterChip('Repos'),
          const SizedBox(width: 8),
          _buildFilterChip('Suspendus'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isActive = _selectedFilter == label;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = label),
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

  Widget _buildDriverCard(String name, String vehicleId, String route, String status, String img, bool isActive, {bool isResting = false}) {
    Color statusColor = isActive ? AppColors.success : (isResting ? AppColors.accent : AppColors.error);
    
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        img,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: AppTextStyles.headingLarge.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status,
                              style: AppTextStyles.label.copyWith(
                                color: statusColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '+224 6XX XX XX XX',
                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_shipping_rounded, color: AppColors.textSecondary, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Renault Kerax 440',
                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  Text(
                    vehicleId,
                    style: AppTextStyles.label.copyWith(fontSize: 10, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.route_rounded, color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  route,
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Détails', style: TextStyle(fontWeight: FontWeight.w700)),
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
                    icon: const Icon(Icons.block_rounded, color: AppColors.textSecondary, size: 20),
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

