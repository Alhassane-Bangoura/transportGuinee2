import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/models/city.dart';
import '../../../core/models/station.dart';
import '../../../core/models/route_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/success_dialog.dart';
import '../login_page.dart';

class DriverRegisterPage extends StatefulWidget {
  const DriverRegisterPage({super.key});

  @override
  State<DriverRegisterPage> createState() => _DriverRegisterPageState();
}

class _DriverRegisterPageState extends State<DriverRegisterPage> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _licenseController = TextEditingController();
  final _expiryController = TextEditingController();
  
  final _vehicleBrandController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  final _vehicleSeatsController = TextEditingController();

  List<City> _cities = [];
  List<Station> _stations = [];
  List<RouteModel> _routes = [];

  City? _selectedCity;
  Station? _selectedStation;
  RouteModel? _selectedRoute;
  String? _selectedExperience;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    try {
      final cities = await LocationService.getCities();
      setState(() => _cities = cities);
    } catch (e) {
      debugPrint('Error loading cities: $e');
    }
  }

  Future<void> _onCityChanged(City? city) async {
    setState(() {
      _selectedCity = city;
      _selectedStation = null;
      _selectedRoute = null;
      _stations = [];
      _routes = [];
    });

    if (city != null) {
      // 1. Charger les gares de la ville
      try {
        final stations = await LocationService.getStationsByCity(city.id);
        setState(() => _stations = stations);
        if (stations.length == 1) {
          setState(() => _selectedStation = stations.first);
        }
      } catch (e) {
        debugPrint('Station Load Error: $e');
      }

      // 2. Charger les trajets (Destinations) de la ville
      setState(() => _isLoading = true);
      try {
        final routes = await LocationService.getRoutesByStation(city.id);
        if (mounted) {
          setState(() {
            _routes = routes;
            _isLoading = false;
            if (routes.length == 1) {
              _selectedRoute = routes.first;
            }
          });
        }
      } catch (e) {
        debugPrint('Route Load Error: $e');
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onStationChanged(Station? station) async {
    if (station == null) return;
    
    setState(() {
      _selectedStation = station;
      _selectedRoute = null;
      _routes = [];
      _isLoading = true;
    });

    try {
      final routes = await LocationService.getRoutesByStation(
        station.id, 
        cityId: _selectedCity?.id
      );
      
      if (mounted) {
        setState(() {
          _routes = routes;
          _isLoading = false;
          if (routes.length == 1) {
            _selectedRoute = routes.first;
          }
        });
      }
    } catch (e) {
      debugPrint('Route Load Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _licenseController.dispose();
    _expiryController.dispose();
    _vehicleBrandController.dispose();
    _vehicleModelController.dispose();
    _vehiclePlateController.dispose();
    _vehicleSeatsController.dispose();
    super.dispose();
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, imageQuality: 70);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Erreur image picker: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const SizedBox(height: 10),
              Text(
                'Rejoignez-nous,\nChauffeurs !',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Faites partie de l\'aventure GuineeTransport.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              
              // Image Picker Avatar
              Center(
                child: GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                        child: _profileImage == null
                            ? const Icon(Icons.person, size: 50, color: AppColors.primary)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(Icons.camera_alt, color: AppColors.primary, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              _buildInputField(label: 'NOM COMPLET', controller: _nameController, hint: 'Ex: Mamadou Diallo', icon: Icons.person_outline_rounded),
              const SizedBox(height: 20),
              _buildInputField(label: 'TÉLÉPHONE', controller: _phoneController, hint: '6XX XX XX XX', icon: Icons.phone_android_rounded, keyboardType: TextInputType.phone),
              const SizedBox(height: 20),
              _buildInputField(label: 'ADRESSE E-MAIL', controller: _emailController, hint: 'chauffeur@exemple.com', icon: Icons.alternate_email_rounded, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              _buildInputField(label: 'MOT DE PASSE', controller: _passwordController, hint: '••••••••', icon: Icons.lock_outline_rounded, isPassword: true, obscureText: !_isPasswordVisible, onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible)),
              const SizedBox(height: 20),
              _buildInputField(label: 'CONFIRMATION', controller: _confirmPasswordController, hint: '••••••••', icon: Icons.lock_reset_rounded, isPassword: true, obscureText: !_isConfirmPasswordVisible, onToggleVisibility: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible)),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  children: [
                    _buildSectionTitle(Icons.badge_rounded, 'Documents'),
                    const SizedBox(height: 20),
                    _buildInputField(label: 'NUMÉRO PERMIS', controller: _licenseController, hint: 'GNE-12345678', icon: Icons.article_rounded, isSmall: true),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildInputField(label: 'EXPIRATION', controller: _expiryController, hint: 'JJ/MM/AA', icon: Icons.calendar_today_rounded, isSmall: true, readOnly: true, onTap: _pickExpiryDate)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdownField(label: 'EXPÉRIENCE', value: _selectedExperience, options: ['1-2 ans', '3-5 ans', '5-10 ans', '10+ ans'], onChanged: (v) => setState(() => _selectedExperience = v))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCityDropdown(),
                    const SizedBox(height: 16),
                    _buildStationDropdown(),
                    const SizedBox(height: 16),
                    _buildRouteDropdown(),
                    const SizedBox(height: 32),
                    _buildSectionTitle(Icons.directions_car_rounded, 'Véhicule'),
                    const SizedBox(height: 20),
                    _buildInputField(label: 'MARQUE', controller: _vehicleBrandController, hint: 'Ex: Mercedes', icon: Icons.factory_rounded, isSmall: true),
                    const SizedBox(height: 16),
                    _buildInputField(label: 'MODÈLE', controller: _vehicleModelController, hint: 'Ex: Sprinter', icon: Icons.model_training_rounded, isSmall: true),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildInputField(label: 'PLAQUE', controller: _vehiclePlateController, hint: 'RC-XXXX-X', icon: Icons.confirmation_number_rounded, isSmall: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildInputField(label: 'PLACES', controller: _vehicleSeatsController, hint: '15', icon: Icons.airline_seat_recline_extra_rounded, isSmall: true, keyboardType: TextInputType.number)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildTermsCheckbox(),
              const SizedBox(height: 32),
              _buildRegisterButton(),
              const SizedBox(height: 24),
              _buildLoginLink(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    ),
  ),
);
}

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 10),
        Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    bool isSmall = false,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary.withOpacity(0.6), letterSpacing: 1)),
        ),
        Container(
          decoration: BoxDecoration(
            color: isSmall ? Colors.transparent : AppColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withOpacity(0.8), width: 1.5),
            boxShadow: isSmall ? null : [BoxShadow(color: AppColors.primary.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            style: GoogleFonts.plusJakartaSans(fontSize: isSmall ? 14 : 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.plusJakartaSans(fontSize: isSmall ? 14 : 15, color: AppColors.textHint.withOpacity(0.8), fontWeight: FontWeight.w500),
              prefixIcon: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: AppColors.primary, size: isSmall ? 16 : 18),
              ),
              suffixIcon: isPassword ? IconButton(onPressed: onToggleVisibility, icon: Icon(obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: AppColors.textSecondary.withOpacity(0.5))) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({required String label, String? value, required List<String> options, required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary.withOpacity(0.6))),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border.withOpacity(0.5))),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text('Choisir', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textHint.withOpacity(0.5))),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary, size: 20),
              items: options.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCityDropdown() => _buildDropdownRow<City>(label: 'VILLE', value: _selectedCity, items: _cities, itemLabel: (c) => c.name, onChanged: _onCityChanged);
  Widget _buildStationDropdown() => _buildDropdownRow<Station>(label: 'GARE ROUTIÈRE', value: _selectedStation, items: _stations, itemLabel: (s) => s.name, onChanged: _onStationChanged, enabled: _selectedCity != null);
  Widget _buildRouteDropdown() {
    bool hasNoRoutes = _selectedStation != null && _routes.isEmpty && !_isLoading;
    
    return _buildDropdownRow<RouteModel>(
      label: 'DESTINATION (VILLE)', 
      value: _selectedRoute, 
      items: _routes, 
      itemLabel: (r) => r.arrivalCityName != null 
          ? '🏠 Vers ${r.arrivalCityName}' 
          : '📍 Vers ${r.arrivalStationName}', 
      onChanged: (r) => setState(() => _selectedRoute = r), 
      enabled: _selectedStation != null && _routes.isNotEmpty,
      hint: hasNoRoutes ? 'Aucun trajet trouvé' : 'Choisir la destination',
    );
  }

  Widget _buildDropdownRow<T>({
    required String label, 
    required T? value, 
    required List<T> items, 
    required String Function(T) itemLabel, 
    required ValueChanged<T?> onChanged, 
    bool enabled = true,
    String hint = 'Choisir',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary.withOpacity(0.6))),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: enabled ? AppColors.background : AppColors.background.withOpacity(0.5), 
            borderRadius: BorderRadius.circular(20), 
            border: Border.all(color: AppColors.border.withOpacity(0.5))
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              hint: Text(hint, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textHint.withOpacity(0.5))),
              isExpanded: true,
              icon: _isLoading && label == 'DESTINATION (VILLE)'
                ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary, size: 20),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(itemLabel(e), style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600)))).toList(),
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(value: _acceptTerms, onChanged: (v) => setState(() => _acceptTerms = v ?? false), activeColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
        Expanded(child: Text("J'accepte les conditions d'utilisation", style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary))),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('S\'INSCRIRE', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
        child: Text.rich(TextSpan(text: 'Déjà inscrit ? ', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary), children: [TextSpan(text: 'Se connecter', style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.bold))])),
      ),
    );
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 365)), firstDate: DateTime.now(), lastDate: DateTime(2100));
    if (picked != null) setState(() => _expiryController.text = "${picked.day}/${picked.month}/${picked.year}");
  }

  Future<void> _handleRegister() async {
    if (!_acceptTerms) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Acceptez les conditions'))); return; }
    setState(() => _isLoading = true);
    try {
      await AuthService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        roleKey: 'driver',
        stationId: _selectedStation?.id,
        routeId: _selectedRoute?.id,
        metadata: {
          'license_number': _licenseController.text.trim(),
          'expiry_date': _expiryController.text.trim(),
          'experience': _selectedExperience,
          'vehicle_brand': _vehicleBrandController.text.trim(),
          'vehicle_model': _vehicleModelController.text.trim(),
          'vehicle_plate': _vehiclePlateController.text.trim(),
          'vehicle_seats': int.tryParse(_vehicleSeatsController.text.trim()) ?? 15,
          if (_profileImage != null) 'local_profile_image_path': _profileImage!.path,
        },
      );
      if (!mounted) return;
      SuccessDialog.show(context: context, title: "Bienvenue !", message: "Compte créé !", buttonText: "SE CONNECTER", onButtonPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
