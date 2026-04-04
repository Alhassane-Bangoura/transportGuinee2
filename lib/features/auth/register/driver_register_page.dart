import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
  bool _acceptTerms = false;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _licenseController = TextEditingController();
  final _expiryController = TextEditingController();

  List<City> _cities = [];
  List<Station> _stations = [];
  List<RouteModel> _routes = [];

  City? _selectedCity;
  Station? _selectedStation;
  RouteModel? _selectedRoute;
  String? _selectedExperience;

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
      try {
        final stations = await LocationService.getStationsByCity(city.id);
        setState(() => _stations = stations);
        debugPrint('[DriverRegister] Loaded ${stations.length} stations for city ${city.name}');
      } catch (e) {
        debugPrint('Error loading stations: $e');
      }
    }
  }

  Future<void> _onStationChanged(Station? station) async {
    setState(() {
      _selectedStation = station;
      _selectedRoute = null;
      _routes = [];
    });
    if (station != null) {
      debugPrint('[DriverRegister] Station changed: ${station.name} (${station.id})');
      try {
        final routes = await LocationService.getRoutesByStation(station.id);
        setState(() {
          _routes = routes;
          if (routes.length == 1) {
            _selectedRoute = routes.first;
          }
        });
        debugPrint('[DriverRegister] Loaded ${routes.length} route(s) for station ${station.name}');
      } catch (e) {
        debugPrint('Error loading routes: $e');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _licenseController.dispose();
    _expiryController.dispose();
    super.dispose();
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              
              // Header
              Text(
                'Rejoignez-nous,\nChauffeurs !',
                style: AppTextStyles.headingLarge.copyWith(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Faites partie de l\'aventure GuineeTransport et gérez vos trajets en toute simplicité.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // Form Fields
              _buildInputField(
                label: 'NOM COMPLET',
                controller: _nameController,
                hint: 'Ex: Mamadou Diallo',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 24),

              _buildInputField(
                label: 'NUMÉRO DE TÉLÉPHONE',
                controller: _phoneController,
                hint: '+224 6XX XX XX XX',
                icon: Icons.phone_android_rounded,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              _buildInputField(
                label: 'ADRESSE E-MAIL',
                controller: _emailController,
                hint: 'chauffeur@exemple.com',
                icon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),

              _buildInputField(
                label: 'MOT DE PASSE',
                controller: _passwordController,
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                obscureText: !_isPasswordVisible,
                onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),

              const SizedBox(height: 40),

              // Professional Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.badge_rounded, color: AppColors.primary, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Détails du Permis',
                          style: AppTextStyles.headingLarge.copyWith(fontSize: 18, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildInputField(
                      label: 'NUMÉRO DE PERMIS',
                      controller: _licenseController,
                      hint: 'GNE-12345678',
                      icon: Icons.article_rounded,
                      isSmall: true,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            label: 'EXPIRATION',
                            controller: _expiryController,
                            hint: 'JJ/MM/AAAA',
                            icon: Icons.calendar_today_rounded,
                            isSmall: true,
                            readOnly: true,
                            onTap: _pickExpiryDate,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdownField(
                            label: 'EXPÉRIENCE',
                            value: _selectedExperience,
                            options: ['1-2 ans', '3-5 ans', '5-10 ans', '10+ ans'],
                            onChanged: (v) => setState(() => _selectedExperience = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildCityDropdown(),
                    const SizedBox(height: 20),
                    _buildStationDropdown(),
                    const SizedBox(height: 20),
                    _buildRouteDropdown(),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Terms and Conditions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _acceptTerms,
                      onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: "J'accepte les ",
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        children: [
                          TextSpan(
                            text: "Conditions d'Utilisation",
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: " et la "),
                          TextSpan(
                            text: "Politique de Confidentialité",
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Register Button
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'S\'inscrire',
                              style: AppTextStyles.buttonText.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.arrow_forward_rounded),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 32),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Déjà inscrit ? ',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    ),
                    child: Text(
                      'Se connecter',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
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
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface, // Correction ici
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: isSmall ? 14 : 16,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textHint,
                fontWeight: FontWeight.w400,
                fontSize: isSmall ? 14 : 16,
              ),
              prefixIcon: Icon(icon, color: AppColors.primary, size: isSmall ? 20 : 22),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: onToggleVisibility,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isSmall ? 14 : 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCityDropdown() {
    return _buildDropdownRow<City>(
      label: 'VILLE',
      value: _selectedCity,
      items: _cities,
      itemLabel: (city) => city.name,
      onChanged: _onCityChanged,
    );
  }

  Widget _buildStationDropdown() {
    return _buildDropdownRow<Station>(
      label: 'GARE ROUTIÈRE',
      value: _selectedStation,
      items: _stations,
      itemLabel: (station) => station.name,
      onChanged: _onStationChanged,
      enabled: _selectedCity != null,
    );
  }

  Widget _buildRouteDropdown() {
    return _buildDropdownRow<RouteModel>(
      label: 'TRAJET UNIQUE',
      value: _selectedRoute,
      items: _routes,
      itemLabel: (route) => route.arrivalCityName != null 
          ? 'Vers ${route.arrivalCityName}' 
          : 'Vers ${route.arrivalStationName ?? "Inconnu"}',
      onChanged: (RouteModel? route) {
        setState(() {
          _selectedRoute = route;
        });
      },
      enabled: _selectedStation != null,
    );
  }

  Widget _buildDropdownRow<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: enabled ? AppColors.white : AppColors.border.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              hint: Text('Choisir', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint)),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
              items: items
                  .map((e) => DropdownMenuItem<T>(
                        value: e,
                        child: Text(
                          itemLabel(e),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary, // Forcer le texte sombre sur fond blanc
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text('Choisir', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint)),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
              items: options.map((e) => DropdownMenuItem(value: e, child: Text(e, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _expiryController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez accepter les conditions')));
      return;
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le nom est obligatoire')));
      return;
    }

    final phoneError = AuthService.validatePhone(phone);
    if (phoneError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(phoneError)));
      return;
    }

    final emailError = AuthService.validateEmail(email);
    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(emailError)));
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mot de passe trop court')));
      return;
    }

    if (_selectedStation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner une gare')));
      return;
    }

    if (_selectedRoute == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner votre trajet unique.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.signUp(
        email: email,
        password: password,
        fullName: name,
        phone: phone,
        roleKey: 'driver',
        stationId: _selectedStation!.id,
        routeId: _selectedRoute!.id,
        metadata: {
          'license_number': _licenseController.text.trim(),
          'expiry_date': _expiryController.text.trim(),
          'experience': _selectedExperience,
        },
      );

      if (!mounted) return;

      SuccessDialog.show(
        context: context,
        title: "Félicitations Chauffeur !",
        message: "Votre compte a été créé avec succès. Bienvenue dans l'équipe GuineeTransport !",
        buttonText: "SE CONNECTER",
        onButtonPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : ${e.toString().replaceAll('AuthException: ', '')}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
