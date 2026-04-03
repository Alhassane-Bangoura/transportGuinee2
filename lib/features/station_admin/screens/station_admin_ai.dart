import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Écran de l'Assistant IA pour l'Admin de Gare
/// Correspond à assisatant_admin.html
class StationAdminAI extends StatefulWidget {
  const StationAdminAI({super.key});

  @override
  State<StationAdminAI> createState() => _StationAdminAIState();
}

class _StationAdminAIState extends State<StationAdminAI> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu, color: AppColors.primary)),
        title: Column(
          children: [
            Text('GUINEE TRANSPORT', style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 18)),
            Text('ASSISTANT DE GARE INTELLIGENT', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 1)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.account_circle, color: AppColors.primary)),
        ],
      ),
      body: Column(
        children: [
          // Chat area
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Date Divider
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(100)),
                    child: Text('AUJOURD\'HUI', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 1)),
                  ),
                ),
                const SizedBox(height: 24),

                // AI Message
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white, height: 1.5),
                                children: [
                                  const TextSpan(text: 'Bonjour Admin. Aujourd\'hui, la gare a enregistré '),
                                  TextSpan(text: '18 départs', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
                                  const TextSpan(text: '. La destination la plus fréquentée est '),
                                  const TextSpan(text: 'Conakry', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const TextSpan(text: '. Trois véhicules sont prêts à partir.'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Assistant IA • 09:41', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 24),

                // Suggestion chips
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildChip(Icons.assessment, 'Générer rapport'),
                      const SizedBox(width: 8),
                      _buildChip(Icons.security, 'Alerte sécurité'),
                      const SizedBox(width: 8),
                      _buildChip(Icons.location_on, 'Statut Conakry'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Voice Wave Placeholder
                Opacity(
                  opacity: 0.4,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var h in [12.0, 24.0, 16.0, 32.0, 20.0, 12.0, 24.0, 16.0])
                            Container(width: 4, height: h, margin: const EdgeInsets.symmetric(horizontal: 2), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(100))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('EN ATTENTE DE COMMANDE VOCALE...', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 1)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Input section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(100), border: Border.all(color: AppColors.primary.withValues(alpha: 0.1))),
                    child: Row(
                      children: [
                        const Icon(Icons.add_circle_outline, color: AppColors.textSecondary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Posez une question...',
                              hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5)),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Container(
                          width: 32, height: 32,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.mic, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.send, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Nav
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 90,
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 'Accueil', false),
          _buildNavItem(Icons.smart_toy, 'Assistant', true),
          _buildNavItem(Icons.directions_bus_outlined, 'Gares', false),
          _buildNavItem(Icons.settings_outlined, 'Paramètres', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? AppColors.primary : AppColors.textSecondary, size: 24),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
