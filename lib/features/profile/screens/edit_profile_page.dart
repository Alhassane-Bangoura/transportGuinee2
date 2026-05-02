import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';
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

    // Récupérer une éventuelle image perdue lors du redémarrage de l'activité sur Android
    _handleLostData();
  }

  Future<void> _handleLostData() async {
    if (!Platform.isAndroid) return;
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) return;
    if (response.file != null && mounted) {
      setState(() => _selectedImage = File(response.file!.path));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _metadataControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  File? _selectedImage;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery, 
        imageQuality: 70,
        maxWidth: 1000,
        maxHeight: 1000,
      );
      if (pickedFile != null && mounted) {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    } catch (e) {
      debugPrint('[EditProfile] Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de charger l\'image : $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      String? avatarUrl = widget.profile.avatarUrl;
      if (_selectedImage != null) {
        avatarUrl = await StorageService.uploadProfileImage(_selectedImage!, widget.profile.id);
      }

      final updatedMetadata = Map<String, dynamic>.from(widget.profile.metadata ?? {});
      _metadataControllers.forEach((key, controller) {
        updatedMetadata[key] = controller.text;
      });

      await AuthService.updateProfile(
        fullName: _nameController.text,
        phone: _phoneController.text,
        avatarUrl: avatarUrl,
        metadata: updatedMetadata,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Erreur de mise à jour'),
            content: Text(e.toString()),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
            ],
          ),
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
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 4),
                        image: DecorationImage(
                          image: _selectedImage != null 
                            ? FileImage(_selectedImage!) as ImageProvider
                            : widget.profile.profileImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
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
