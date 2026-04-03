import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final Map<String, TextEditingController> _metadataControllers = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(text: widget.profile.phone);
    
    // Initialize metadata controllers based on role
    widget.profile.metadata?.forEach((key, value) {
      if (value is String) {
        _metadataControllers[key] = TextEditingController(text: value);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _metadataControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updatedMetadata = Map<String, dynamic>.from(widget.profile.metadata ?? {});
      _metadataControllers.forEach((key, controller) {
        updatedMetadata[key] = controller.text;
      });

      await AuthService.updateProfile(
        fullName: _nameController.text,
        phone: _phoneController.text,
        metadata: updatedMetadata,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès')),
        );
        Navigator.of(context).pop(true); // Return true to indicate update
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Modifier le profil',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('INFORMATIONS GÉNÉRALES'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: 'Nom complet',
                icon: Icons.person_outline,
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Téléphone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: AuthService.validatePhone,
              ),
              
              if (_metadataControllers.isNotEmpty) ...[
                const SizedBox(height: 32),
                _buildSectionTitle('DÉTAILS SPÉCIFIQUES'),
                const SizedBox(height: 16),
                ..._metadataControllers.entries.where((entry) => 
                  !entry.key.contains('_id') && 
                  entry.key != 'phone' && 
                  entry.key != 'full_name'
                ).map((entry) {
                  final String rawKey = entry.key;
                  String label = rawKey.replaceAll('_', ' ').toUpperCase();
                  if (rawKey == 'role_key') label = 'RÔLE';
                  if (rawKey == 'emergency_name') label = "CONTACT D'URGENCE";
                  if (rawKey == 'emergency_phone') label = "TÉL. D'URGENCE";
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildTextField(
                      controller: entry.value,
                      label: label,
                      icon: _getIconForMetadata(entry.key),
                    ),
                  );
                }),
              ],

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Enregistrer les modifications',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.textSecondary,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
    );
  }

  IconData _getIconForMetadata(String key) {
    if (key.contains('station')) return Icons.location_city;
    if (key.contains('city')) return Icons.map_outlined;
    if (key.contains('license')) return Icons.badge_outlined;
    if (key.contains('employee')) return Icons.work_outline;
    return Icons.info_outline;
  }
}
