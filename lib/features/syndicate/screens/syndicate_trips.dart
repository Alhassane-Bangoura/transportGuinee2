import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';

class SyndicateTripsPage extends StatefulWidget {
  const SyndicateTripsPage({super.key});

  @override
  State<SyndicateTripsPage> createState() => _SyndicateTripsPageState();
}

class _SyndicateTripsPageState extends State<SyndicateTripsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildPremiumHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              children: [
                _buildAITips(),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SUIVI DES DÉPARTS', 
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.primary, 
                            fontSize: 10, 
                            fontWeight: FontWeight.w800, 
                            letterSpacing: 1.5
                          )
                        ),
                        Text('Activité du Trajet', 
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white, 
                            fontSize: 24, 
                            fontWeight: FontWeight.w900, 
                            letterSpacing: -0.5
                          )
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surface, 
                        borderRadius: BorderRadius.circular(12), 
                        border: Border.all(color: AppColors.border)
                      ),
                      child: const Icon(Icons.filter_list_rounded, color: AppColors.primary, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDepartureReadyCard(
                  'Sprinter - Mercedes Benz',
                  'RC-9021-B',
                  'Moussa Camara',
                  12, 15,
                  AppAssets.vehicleInterior1,
                  AppAssets.driverActivityAvatar,
                ),
                const SizedBox(height: 24),
                _buildDepartureReadyCard(
                  'Toyota Hiace',
                  'RC-4412-A',
                  'Ibrahima Diallo',
                  8, 18,
                  AppAssets.vehicleInterior2,
                  AppAssets.driverAvatar3,
                  isWaiting: true,
                ),
                const SizedBox(height: 48),
                Text('RÉCAPITULATIF DU JOUR', 
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary, 
                    fontSize: 12, 
                    fontWeight: FontWeight.w800, 
                    letterSpacing: 1.5
                  )
                ),
                const SizedBox(height: 16),
                _buildSummaryGrid(),
                const SizedBox(height: 48),
                Text('DERNIERS DÉPARTS VALIDÉS', 
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary, 
                    fontSize: 12, 
                    fontWeight: FontWeight.w800, 
                    letterSpacing: 1.5
                  )
                ),
                const SizedBox(height: 16),
                _buildRecentDepartures(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, 
                  border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 2)
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.network(
                    AppAssets.syndicateActivityAvatar, 
                    fit: BoxFit.cover
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('GuineeTransport', 
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primary, 
                  fontWeight: FontWeight.w900, 
                  fontSize: 18, 
                  letterSpacing: -0.5
                )
              ),
            ],
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary, size: 24)),
        ],
      ),
    );
  }

  Widget _buildAITips() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.lightbulb_outline_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Optimisation IA du planning', 
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.primary, 
                    fontWeight: FontWeight.w800, 
                    fontSize: 15
                  )
                ),
                const SizedBox(height: 4),
                Text(
                  'Le flux passager vers Conakry est en hausse de 15%. Nous recommandons d\'avancer le départ du Sprinter CR-402 de 20 minutes.',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary, 
                    fontSize: 13, 
                    height: 1.5, 
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartureReadyCard(String model, String plate, String driver, int current, int total, String vehicleImg, String driverImg, {bool isWaiting = false}) {
    double progress = current / total;
    Color statusColor = isWaiting ? Colors.amber : Colors.green;
    String statusText = isWaiting ? 'EN ATTENTE' : 'PRÊT À PARTIR';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), 
            blurRadius: 40, 
            offset: const Offset(0, 20)
          )
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                child: Image.network(vehicleImg, height: 180, width: double.infinity, fit: BoxFit.cover),
              ),
              Positioned(
                top: 16, right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(100)),
                  child: Text(statusText, 
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white, 
                      fontSize: 10, 
                      fontWeight: FontWeight.w900, 
                      letterSpacing: 0.5
                    )
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(model, 
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white, 
                            fontSize: 18, 
                            fontWeight: FontWeight.w800
                          )
                        ),
                        Text('Matricule: $plate', 
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textSecondary, 
                            fontSize: 12, 
                            fontWeight: FontWeight.w600
                          )
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text('$current/$total', 
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.primary, 
                            fontSize: 20, 
                            fontWeight: FontWeight.w900
                          )
                        ),
                        Text('SIÈGES', 
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textSecondary, 
                            fontSize: 10, 
                            fontWeight: FontWeight.w800
                          )
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: progress, 
                    minHeight: 8, 
                    backgroundColor: AppColors.background, 
                    valueColor: AlwaysStoppedAnimation<Color>(isWaiting ? Colors.amber : AppColors.primary)
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(driverImg, width: 44, height: 44, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Chauffeur', 
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.textSecondary, 
                                fontSize: 10, 
                                fontWeight: FontWeight.w700
                              )
                            ),
                            Text(driver, 
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white, 
                                fontSize: 14, 
                                fontWeight: FontWeight.w800
                              )
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1), 
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: const Icon(Icons.call_rounded, color: AppColors.primary, size: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isWaiting ? null : () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusColor,
                      disabledBackgroundColor: AppColors.background,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(isWaiting ? 'EN ATTENTE DE PASSAGERS' : 'VALIDER DÉPART', 
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w900, 
                            fontSize: 13, 
                            letterSpacing: 1
                          )
                        ),
                        const SizedBox(width: 8),
                        Icon(isWaiting ? Icons.group_outlined : Icons.local_shipping_rounded, size: 20),
                      ],
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

  Widget _buildSummaryGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildSummaryCard('VALIDÉS', '24', Icons.done_all_rounded, Colors.blue),
        _buildSummaryCard('EN ATTENTE', '07', Icons.schedule_rounded, Colors.amber),
        _buildSummaryCard('PONCTUALITÉ', '92%', Icons.speed_rounded, Colors.green),
        _buildSummaryCard('RECETTE', '1.2M', Icons.payments_rounded, AppColors.primary),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface, 
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: AppColors.border)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const Spacer(),
          Text(value, 
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white, 
              fontSize: 22, 
              fontWeight: FontWeight.w900
            )
          ),
          Text(label, 
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textSecondary, 
              fontSize: 10, 
              fontWeight: FontWeight.w800
            )
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDepartures() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface, 
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: AppColors.border)
      ),
      child: Column(
        children: [
          _buildDepartureItem('Sprinter RC-112-C', 'Mamou', '10:45'),
          const Divider(height: 1, color: AppColors.border),
          _buildDepartureItem('Coaster RC-885-A', 'Labé', '09:15'),
        ],
      ),
    );
  }

  Widget _buildDepartureItem(String vehicle, String destination, String time) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05), 
              borderRadius: BorderRadius.circular(16)
            ),
            child: const Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vehicle, 
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white, 
                    fontSize: 14, 
                    fontWeight: FontWeight.w800
                  )
                ),
                Text('Destination: $destination', 
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary, 
                    fontSize: 12, 
                    fontWeight: FontWeight.w600
                  )
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, 
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white, 
                  fontSize: 14, 
                  fontWeight: FontWeight.w800
                )
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1), 
                  borderRadius: BorderRadius.circular(4)
                ),
                child: Text('VALIDÉ', 
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.primary, 
                    fontSize: 8, 
                    fontWeight: FontWeight.w900
                  )
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
