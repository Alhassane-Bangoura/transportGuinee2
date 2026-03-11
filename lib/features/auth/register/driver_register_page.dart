import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/auth_service.dart';
import '../login_page.dart';

class DriverRegisterPage extends StatefulWidget {
  const DriverRegisterPage({super.key});

  @override
  State<DriverRegisterPage> createState() => _DriverRegisterPageState();
}

class _DriverRegisterPageState extends State<DriverRegisterPage> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _licenseController = TextEditingController();
  final _expiryController = TextEditingController();
  final _syndicateController = TextEditingController();

  String? _selectedExperience;
  String? _selectedCity;

  static const Color primaryColor = Color(0xFF11D452);
  static const Color backgroundColor = Color(0xFFF6F8F6);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _licenseController.dispose();
    _expiryController.dispose();
    _syndicateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  const Expanded(
                    child: Text(
                      'Inscription Chauffeur',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profil Chauffeur',
                              style: GoogleFonts.manrope(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Text(
                              'Informations professionnelles',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Étape 1 sur 2',
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Progress Bar
                    Container(
                      height: 6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.5,
                        child: Container(
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    _buildLabel('Nom complet'),
                    _buildTextField(
                        hint: 'Ex: Mamadou Diallo',
                        icon: Icons.person_outline,
                        controller: _nameController),

                    const SizedBox(height: 20),

                    _buildLabel('Téléphone'),
                    _buildTextField(
                        hint: '+224 6XX XX XX XX',
                        icon: Icons.call_outlined,
                        keyboardType: TextInputType.phone,
                        controller: _phoneController),

                    const SizedBox(height: 20),

                    _buildLabel('Email'),
                    _buildTextField(
                        hint: 'chauffeur@exemple.com',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController),

                    const SizedBox(height: 20),

                    _buildLabel('Mot de passe'),
                    _buildTextField(
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: !_isPasswordVisible,
                      controller: _passwordController,
                      onToggle: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible),
                    ),

                    const SizedBox(height: 32),

                    const Row(
                      children: [
                        Icon(Icons.badge_outlined, color: primaryColor),
                        SizedBox(width: 8),
                        Text('Détails du Permis',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Numéro de permis'),
                    _buildTextField(
                        hint: 'GNE-12345678', controller: _licenseController),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Expiration'),
                              _buildTextField(
                                hint: 'JJ/MM/AAAA',
                                suffixIcon: Icons.calendar_today_outlined,
                                controller: _expiryController,
                                onSuffixTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now()
                                        .add(const Duration(days: 365)),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.light(
                                            primary: primaryColor,
                                            onPrimary: Colors.white,
                                            onSurface: Colors.black,
                                          ),
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
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Expérience'),
                              _buildDropdownField(
                                value: _selectedExperience,
                                options: [
                                  '1-2 ans',
                                  '3-5 ans',
                                  '5-10 ans',
                                  '10+ ans'
                                ],
                                onChanged: (val) =>
                                    setState(() => _selectedExperience = val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _buildLabel('Ville principale'),
                    _buildDropdownField(
                        value: _selectedCity,
                        options: [
                          'Conakry',
                          'Kindia',
                          'Labé',
                          'Kankan',
                          'Nzérékoré'
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedCity = val)),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel('Syndicat affilié'),
                        const Text('Optionnel',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                      ],
                    ),
                    _buildTextField(
                        hint: 'Nom de l\'organisation',
                        controller: _syndicateController),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                final email = _emailController.text.trim();
                                final password = _passwordController.text;
                                final fullName = _nameController.text.trim();
                                final phone = _phoneController.text.trim();

                                final emailError = AuthService.validateEmail(email);
                                final phoneError = AuthService.validatePhone(phone);
                                final passwordError = password.length < 6 ? 'Le mot de passe doit contenir au moins 6 caractères' : null;

                                if (fullName.isEmpty || emailError != null || phoneError != null || passwordError != null) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(fullName.isEmpty 
                                        ? 'Le nom est obligatoire' 
                                        : (emailError ?? phoneError ?? passwordError ?? '')),
                                    ),
                                  );
                                  return;
                                }
                                setState(() => _isLoading = true);
                                try {
                                  await AuthService.signUp(
                                    email: email,
                                    password: password,
                                    fullName: fullName,
                                    phone: phone,
                                    roleKey: 'driver',
                                    metadata: {
                                      'license_number':
                                          _licenseController.text.trim(),
                                      'expiry_date':
                                          _expiryController.text.trim(),
                                      'experience': _selectedExperience,
                                      'city': _selectedCity,
                                      'syndicate':
                                          _syndicateController.text.trim(),
                                    },
                                  );
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Compte chauffeur créé ! Veuillez vous connecter.'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  if (!context.mounted) return;
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginPage()),
                                    (route) => false,
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Erreur : ${e.toString().replaceAll('AuthException: ', '')}')),
                                  );
                                  setState(() => _isLoading = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Suivant',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Center(
                      child: Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          text: "En continuant, vous acceptez les ",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          children: [
                            TextSpan(
                                text: "Conditions d'Utilisation",
                                style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline)),
                            TextSpan(text: " de GuineeTransport."),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 100), // footer space
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          border: const Border(top: BorderSide(color: Colors.black12)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_outlined, 'Accueil'),
            _buildNavItem(Icons.route_outlined, 'Trajets'),
            _buildNavItem(Icons.person, 'Profil', isActive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    IconData? icon,
    IconData? suffixIcon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggle,
    VoidCallback? onSuffixTap,
    TextInputType? keyboardType,
    TextEditingController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon:
              icon != null ? Icon(icon, color: Colors.grey, size: 20) : null,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                      size: 20,
                      color: Colors.grey),
                  onPressed: onToggle)
              : (suffixIcon != null
                  ? IconButton(
                      icon: Icon(suffixIcon, size: 20, color: Colors.grey),
                      onPressed: onSuffixTap,
                    )
                  : null),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: const Text('Sélectionner',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
          isExpanded: true,
          items: options
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool isActive = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? primaryColor : Colors.grey, size: 24),
        Text(label,
            style: TextStyle(
                color: isActive ? primaryColor : Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
