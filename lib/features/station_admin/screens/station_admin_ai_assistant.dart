import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class StationAdminAIAssistant extends StatefulWidget {
  const StationAdminAIAssistant({super.key});

  @override
  State<StationAdminAIAssistant> createState() => _StationAdminAIAssistantState();
}

class _StationAdminAIAssistantState extends State<StationAdminAIAssistant> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildDateDivider(),
                  const SizedBox(height: 24),
                  _buildAIMessage(
                    "Bonjour Admin. Aujourd'hui, la gare a enregistré 18 départs. La destination la plus fréquentée est Conakry. Trois véhicules sont prêts à partir.",
                  ),
                  const SizedBox(height: 24),
                  _buildSuggestionChips(),
                  const SizedBox(height: 48),
                  _buildVoiceWavePlaceholder(),
                ],
              ),
            ),
            _buildInputArea(),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.primary.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.primary),
            onPressed: () {},
          ),
          Column(
            children: [
              Text(
                'GUINEE TRANSPORT',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Assistant de Gare Intelligent',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primary.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  textStyle: const TextStyle(letterSpacing: 2),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDateDivider() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          "AUJOURD'HUI",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildAIMessage(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(4),
                  ),
                  border: Border.all(color: AppColors.primary.withOpacity(0.05)),
                ),
                child: Text(
                  text,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'Assistant IA • 09:41',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textHint,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 48), // Padding so it doesn't take full width
      ],
    );
  }

  Widget _buildSuggestionChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildChip(Icons.assessment, 'Générer rapport'),
          const SizedBox(width: 10),
          _buildChip(Icons.security, 'Alerte sécurité'),
          const SizedBox(width: 10),
          _buildChip(Icons.location_on, 'Statut Conakry'),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceWavePlaceholder() {
    return Column(
      children: [
        Opacity(
          opacity: 0.4,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _waveBar(12),
              _waveBar(24),
              _waveBar(16),
              _waveBar(32),
              _waveBar(20),
              _waveBar(12),
              _waveBar(24),
              _waveBar(16),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'En attente de commande vocale...',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _waveBar(double height) {
    return Container(
      width: 4,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.primary.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          const Icon(Icons.add_circle, color: AppColors.textHint),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: TextField(
                controller: _messageController,
                style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Posez une question...',
                  hintStyle: TextStyle(color: AppColors.textHint),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: const Icon(Icons.mic, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.send, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.only(bottom: 24, top: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.primary.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, 'Accueil', isActive: false),
          _navItem(Icons.smart_toy, 'Assistant', isActive: true),
          _navItem(Icons.directions_bus, 'Gares', isActive: false),
          _navItem(Icons.settings, 'Paramètres', isActive: false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, {required bool isActive}) {
    final color = isActive ? AppColors.primary : AppColors.textSecondary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: color,
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
