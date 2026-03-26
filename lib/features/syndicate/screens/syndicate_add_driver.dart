import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/driver_service.dart';
import '../../../core/models/user_profile.dart';

class SyndicateAddDriverPage extends StatefulWidget {
  const SyndicateAddDriverPage({super.key});

  @override
  State<SyndicateAddDriverPage> createState() => _SyndicateAddDriverPageState();
}

class _SyndicateAddDriverPageState extends State<SyndicateAddDriverPage> {
  final _searchController = TextEditingController();
  UserProfile? _foundDriver;
  bool _isSearching = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _foundDriver = null;
    });

    try {
      final driver = await DriverService.searchDriver(query);
      if (mounted) {
        setState(() {
          _foundDriver = driver;
          if (driver == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Aucun chauffeur trouvé avec ces informations.')),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _submit() async {
    if (_foundDriver == null) return;

    setState(() => _isLoading = true);

    try {
      await DriverService.assignDriverToSyndicate(_foundDriver!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chauffeur ajouté au syndicat avec succès !'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'ajouter : ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textPrimary,
              elevation: 2,
              shadowColor: Colors.black.withValues(alpha: 0.1),
            ),
          ),
        ),
        title: Text(
          'Rechercher & Ajouter',
          style: AppTextStyles.headingLarge.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RECHERCHE DE CHAUFFEUR',
                    style: AppTextStyles.label.copyWith(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Téléphone ou Email',
                            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                            filled: true,
                            fillColor: AppColors.surfaceVariant.withValues(alpha: 0.3),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                          onSubmitted: (_) => _search(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSearching ? null : _search,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: _isSearching 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (_foundDriver != null) ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.surfaceVariant,
                      child: Icon(Icons.person_rounded, size: 40, color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _foundDriver!.fullName,
                      style: AppTextStyles.headingLarge.copyWith(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'CHAUFFEUR QUALIFIÉ',
                      style: AppTextStyles.label.copyWith(color: AppColors.textSecondary, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 16),
                    _buildDriverInfoRow(Icons.phone_rounded, 'Téléphone', _foundDriver!.phone ?? 'N/A'),
                    const SizedBox(height: 12),
                    _buildDriverInfoRow(Icons.location_on_rounded, 'Gare Assignée', 'Gare ID: ${_foundDriver!.stationId}'),
                    const SizedBox(height: 12),
                    _buildDriverInfoRow(Icons.route_rounded, 'Trajet Principal', 'Trajet ID: ${_foundDriver!.routeId}'),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ] else if (!_isSearching)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.person_search_rounded, size: 64, color: AppColors.textHint.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'Entrez les coordonnées du chauffeur\npour l\'ajouter à votre syndicat.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            _buildSecurityNotice(),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: _isLoading ? AppColors.textHint : AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ( _isLoading ? AppColors.textHint : AppColors.primary).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: InkWell(
        onTap: _isLoading ? null : _submit,
        borderRadius: BorderRadius.circular(20),
        child: Center(
          child: _isLoading 
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    'Ajouter au Syndicat',
                    style: AppTextStyles.headingLarge.copyWith(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildSecurityNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFCE8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFEF08A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_rounded, color: Color(0xFFA16207), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Isolation GARE-TRAJET : Vous ne pouvez ajouter que des chauffeurs appartenant à votre gare et inscrits sur l\'un de vos trajets gérés.',
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: const Color(0xFF854D0E), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
