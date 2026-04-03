import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_assets.dart';
import 'passenger_search_results.dart';

/// Écran de Recherche de Trajet Passager
/// Correspond à recherche_trajet_passager.html
class PassengerSearch extends StatefulWidget {
  const PassengerSearch({super.key});

  @override
  State<PassengerSearch> createState() => _PassengerSearchState();
}

class _PassengerSearchState extends State<PassengerSearch> {
  final TextEditingController _departureController = TextEditingController(text: 'Conakry');
  final TextEditingController _destinationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int _passengers = 1;

  @override
  void dispose() {
    _departureController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _swapLocations() {
    setState(() {
      final temp = _departureController.text;
      _departureController.text = _destinationController.text;
      _destinationController.text = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
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
              'RECHERCHE PREMIUM',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Text(
              'Recherche de Trajet',
              style: AppTextStyles.headingLarge.copyWith(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Planifiez votre prochain voyage à travers la Guinée avec simplicité.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Search Module (Bento Style)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 30,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Inputs
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      Column(
                        children: [
                          _buildInput(
                            label: 'DÉPART',
                            hint: 'D\'où partez-vous ?',
                            icon: Icons.location_on,
                            controller: _departureController,
                          ),
                          const SizedBox(height: 12),
                          _buildInput(
                            label: 'DESTINATION',
                            hint: 'Où allez-vous ?',
                            icon: Icons.flag,
                            controller: _destinationController,
                          ),
                        ],
                      ),
                      Positioned(
                        right: 16,
                        top: 50,
                        child: GestureDetector(
                          onTap: _swapLocations,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.swap_vert, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Date & Travelers Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildInput(
                          label: 'DATE',
                          hint: 'Quand ?',
                          icon: Icons.calendar_today,
                          value: '${_selectedDate.day} ${_getMonth(_selectedDate.month)}',
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 90)),
                            );
                            if (picked != null) setState(() => _selectedDate = picked);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInput(
                          label: 'PASSAGERS',
                          hint: 'Combien ?',
                          icon: Icons.person,
                          value: '$_passengers Passager${_passengers > 1 ? 's' : ''}',
                          onTap: () {
                             // Simple picker logic
                             setState(() => _passengers = (_passengers % 4) + 1);
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Search Button
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PassengerSearchResults(
                              from: _departureController.text,
                              to: _destinationController.text,
                              date: _selectedDate,
                              passengers: _passengers,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search, size: 22),
                          const SizedBox(width: 12),
                          Text(
                            'Rechercher',
                            style: AppTextStyles.buttonText.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // AI Insight Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.smart_toy, color: Colors.blueAccent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'AI TIPS',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Meilleur moment pour voyager ?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Le trajet Conakry → Labé est 20% moins fréquenté le mardi matin. Réservez maintenant pour plus de confort.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Popular Routes
            const Text(
              'Itinéraires Populaires',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            _buildRouteItem('Conakry - Mamou', '4h 30m'),
            _buildRouteItem('Kindia - Conakry', '2h 15m'),
            _buildRouteItem('Labé - Conakry', '8h 30m'),

            const SizedBox(height: 40),
            
            // Minimalist Map Vis
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                image: const DecorationImage(
                  image: const NetworkImage(AppAssets.searchBackground),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black12, BlendMode.darken),
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'COUVERTURE EN DIRECT : 98%',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required String hint,
    required IconData icon,
    TextEditingController? controller,
    String? value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.5),
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
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  if (onTap == null && controller != null)
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        value ?? hint,
                        style: TextStyle(
                          color: value != null ? Colors.white : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteItem(String title, String duration) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: AppColors.primary, size: 18),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
          Text(
            duration,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sept', 'Oct', 'Nov', 'Déc'];
    return months[month - 1];
  }
}
