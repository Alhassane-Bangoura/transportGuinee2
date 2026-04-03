import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/models/city.dart';
import '../../../core/models/station.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/success_dialog.dart';
import '../login_page.dart';

class StationAdminRegisterPage extends StatefulWidget {
  const StationAdminRegisterPage({super.key});

  @override
  State<StationAdminRegisterPage> createState() => _StationAdminRegisterPageState();
}

class _StationAdminRegisterPageState extends State<StationAdminRegisterPage> {
  bool _isPasswordVisible = false;
  bool _acceptTerms = false;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _employeeIdController = TextEditingController();

  List<City> _cities = [];
  List<Station> _stations = [];
  City? _selectedCity;
  Station? _selectedStation;
  String? _selectedFunction;

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
      _stations = [];
    });
    if (city != null) {
      try {
        final stations = await LocationService.getStationsByCity(city.id);
        setState(() => _stations = stations);
      } catch (e) {
        debugPrint('Error loading stations: $e');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _employeeIdController.dispose();
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
                'Gérez votre\nGare Routière',
                style: AppTextStyles.headingLarge.copyWith(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Prenez le contrôle des flux, des véhicules et des départs en un clic.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // Progress Indicator
              Row(
                children: [
                   Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Admin Section
              _buildSectionHeader('INFORMATIONS ADMINISTRATEUR'),
              _buildInputField(
                label: 'NOM COMPLET',
                controller: _nameController,
                hint: 'Ex: Mamadou Diallo',
                icon: Icons.person_rounded,
              ),
              const SizedBox(height: 24),

              _buildInputField(
                label: 'TÉLÉPHONE',
                controller: _phoneController,
                hint: '+224 6XX XX XX XX',
                icon: Icons.phone_android_rounded,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              _buildInputField(
                label: 'EMAIL PROFESSIONNEL',
                controller: _emailController,
                hint: 'admin@gare.gn',
                icon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 32),

              // Professional Assignment Section
              _buildSectionHeader('AFFECTATION PROFESSIONNELLE'),
              _buildCityDropdown(),
              const SizedBox(height: 24),
              _buildStationDropdown(),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      label: 'N° EMPLOYÉ',
                      controller: _employeeIdController,
                      hint: 'EMP-2024',
                      icon: Icons.badge_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownRow<String>(
                      label: 'FONCTION',
                      value: _selectedFunction,
                      items: [
                        'Responsable Départ',
                        'Responsable Arrivée',
                        'Chef Billetterie',
                        'Gérant Principal'
                      ],
                      itemLabel: (s) => s,
                      onChanged: (v) => setState(() => _selectedFunction = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Security Section
              _buildSectionHeader('SÉCURITÉ DU COMPTE'),
              _buildInputField(
                label: 'MOT DE PASSE',
                controller: _passwordController,
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                obscureText: !_isPasswordVisible,
                onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
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
                        text: "En créant ce compte, j'accepte les ",
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        children: [
                          TextSpan(
                            text: "conditions d'utilisation professionnelles",
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: " de GuineeTransport."),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Create Account Button
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
                              'Créer mon compte admin',
                              style: AppTextStyles.buttonText.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.admin_panel_settings_rounded),
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
                    'Compte déjà existant ? ',
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: AppTextStyles.label.copyWith(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ],
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
            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textHint,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCityDropdown() {
    return _buildDropdownRow<City>(
      label: 'VILLE REPRÉSENTÉE',
      value: _selectedCity,
      items: _cities,
      itemLabel: (city) => city.name,
      onChanged: _onCityChanged,
    );
  }

  Widget _buildStationDropdown() {
    return _buildDropdownRow<Station>(
      label: 'GARE ASSIGNÉE',
      value: _selectedStation,
      items: _stations,
      itemLabel: (station) => station.name,
      onChanged: (v) => setState(() => _selectedStation = v),
      enabled: _selectedCity != null,
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
            color: enabled ? AppColors.surface : AppColors.border.withValues(alpha: 0.1),
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
                        child: Text(itemLabel(e), style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
                      ))
                  .toList(),
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleRegister() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez accepter les conditions')));
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final fullName = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Votre nom est obligatoire')));
      return;
    }

    final emailError = AuthService.validateEmail(email);
    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(emailError)));
      return;
    }

    final phoneError = AuthService.validatePhone(phone);
    if (phoneError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(phoneError)));
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

    if (_selectedStation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner une gare')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        roleKey: 'station_admin',
        stationId: _selectedStation!.id,
        metadata: {
          'employee_id': _employeeIdController.text.trim(),
          'function': _selectedFunction,
        },
      );

      if (!mounted) return;

      SuccessDialog.show(
        context: context,
        title: "Compte Admin Créé !",
        message: "Votre accès administrateur de gare a été configuré. Vous pouvez maintenant gérer les flux et départs.",
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
