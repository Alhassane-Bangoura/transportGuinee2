import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';

class DriverEditProfileScreen extends StatefulWidget {
  final UserProfile profile;
  const DriverEditProfileScreen({super.key, required this.profile});

  @override
  State<DriverEditProfileScreen> createState() => _DriverEditProfileScreenState();
}

class _DriverEditProfileScreenState extends State<DriverEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _licenseController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _plateController;
  late TextEditingController _seatsController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final meta = widget.profile.metadata ?? {};
    _nameController = TextEditingController(text: widget.profile.cleanFullName);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _licenseController = TextEditingController(text: meta['license_number'] ?? '');
    _brandController = TextEditingController(text: meta['vehicle_brand'] ?? '');
    _modelController = TextEditingController(text: meta['vehicle_model'] ?? '');
    _plateController = TextEditingController(text: meta['vehicle_plate'] ?? '');
    _seatsController = TextEditingController(text: (meta['vehicle_seats'] ?? '15').toString());
  }

  @override
  void dispose() {
    for (var controller in [_nameController, _phoneController, _licenseController, _brandController, _modelController, _plateController, _seatsController]) {
      controller.dispose();
    }
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
      debugPrint('[DriverEdit] Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du choix de l\'image : $e')),
        );
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String? avatarUrl = widget.profile.avatarUrl;
      if (_selectedImage != null) {
        final uploadedUrl = await StorageService.uploadProfileImage(_selectedImage!, widget.profile.id);
        if (uploadedUrl != null) avatarUrl = uploadedUrl;
      }

      final updatedMetadata = Map<String, dynamic>.from(widget.profile.metadata ?? {});
      updatedMetadata['license_number'] = _licenseController.text.trim();
      updatedMetadata['vehicle_brand'] = _brandController.text.trim();
      updatedMetadata['vehicle_model'] = _modelController.text.trim();
      updatedMetadata['vehicle_plate'] = _plateController.text.trim();
      updatedMetadata['vehicle_seats'] = int.tryParse(_seatsController.text.trim()) ?? 15;

      final response = await AuthService.updateProfile(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        avatarUrl: avatarUrl,
        metadata: updatedMetadata,
      );

      setState(() => _isLoading = false);
      if (response.isSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil mis à jour')));
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${response.message}')));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur inattendue: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('ÉDITION PROFIL', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 1)),
        leading: IconButton(icon: const Icon(Icons.close, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
        actions: [
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.only(right: 16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
          else
            TextButton(onPressed: _handleSave, child: Text('SAUVER', style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.w900))),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
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
                    _buildSectionHeader('COORDONNÉES'),
                    const SizedBox(height: 16),
                    _buildFluidField(controller: _nameController, label: 'Nom Complet', icon: Icons.person_outline),
                    const SizedBox(height: 16),
                    _buildFluidField(controller: _phoneController, label: 'Téléphone', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                    const SizedBox(height: 16),
                    _buildFluidField(controller: _licenseController, label: 'Numéro de Permis', icon: Icons.badge_outlined),
                    const SizedBox(height: 32),
                    _buildSectionHeader('VÉHICULE'),
                    const SizedBox(height: 16),
                    _buildFluidField(controller: _brandController, label: 'Marque', icon: Icons.factory_outlined),
                    const SizedBox(height: 16),
                    _buildFluidField(controller: _modelController, label: 'Modèle', icon: Icons.model_training_outlined),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildFluidField(controller: _plateController, label: 'Plaque', icon: Icons.confirmation_number_outlined)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildFluidField(controller: _seatsController, label: 'Places', icon: Icons.airline_seat_recline_extra_outlined, keyboardType: TextInputType.number)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary.withOpacity(0.6), letterSpacing: 1.5));

  Widget _buildFluidField({required TextEditingController controller, required String label, required IconData icon, TextInputType? keyboardType}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border.withOpacity(0.5)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))]),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        decoration: InputDecoration(
          icon: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.primary, size: 20)),
          labelText: label,
          labelStyle: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary.withOpacity(0.5), fontSize: 13),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
      ),
    );
  }
}
