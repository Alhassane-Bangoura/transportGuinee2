import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../login_page.dart';

class SyndicateRegisterPage extends StatefulWidget {
  const SyndicateRegisterPage({super.key});

  @override
  State<SyndicateRegisterPage> createState() => _SyndicateRegisterPageState();
}

class _SyndicateRegisterPageState extends State<SyndicateRegisterPage> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _registrationController = TextEditingController();
  final _addressController = TextEditingController();
  final _managerNameController = TextEditingController();

  String? _selectedCity;

  static const Color primaryColor = Color(0xFF135BEC);
  static const Color backgroundColor = Color(0xFFF6F6F8);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _registrationController.dispose();
    _addressController.dispose();
    _managerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Nav Bar
            Container(
              decoration: BoxDecoration(
                color: backgroundColor.withValues(alpha: 0.8),
                border: const Border(bottom: BorderSide(color: Colors.black12)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                  ),
                  const Expanded(
                    child: Text(
                      'Inscription Syndicat',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance,
                        color: primaryColor, size: 16),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Info Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: primaryColor.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.app_registration,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Portail GuineeTransport',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                Text(
                                  'Digitalisation du transport interurbain. Enregistrez votre entité officielle.',
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section: Organisation
                    _buildSectionHeader('Détails de l\'Organisation'),
                    _buildLabel('Nom du syndicat'),
                    _buildTextField(
                        hint: 'Ex: Syndicat des Transporteurs',
                        icon: Icons.groups_outlined,
                        controller: _nameController),

                    const SizedBox(height: 16),
                    _buildLabel('Ville représentée'),
                    _buildDropdownField(
                        hint: 'Sélectionner une ville',
                        value: _selectedCity,
                        options: [
                          'Conakry',
                          'Kindia',
                          'Boké',
                          'Labé',
                          'Kankan',
                          'Nzérékoré'
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedCity = val)),

                    const SizedBox(height: 16),
                    _buildLabel('Numéro d’enregistrement'),
                    _buildTextField(
                        hint: 'SYND-GN-000',
                        icon: Icons.badge_outlined,
                        controller: _registrationController),

                    const SizedBox(height: 16),
                    _buildLabel('Adresse du bureau'),
                    _buildTextField(
                        hint: 'Ex: Boulbinet, Kaloum',
                        icon: Icons.home_work_outlined,
                        controller: _addressController),

                    const SizedBox(height: 24),
                    const Divider(height: 32, thickness: 1),

                    // Section: Responsable
                    _buildSectionHeader('Détails du Responsable'),
                    _buildLabel('Nom complet du responsable'),
                    _buildTextField(
                        hint: 'Ex: Mamadou Diallo',
                        icon: Icons.person_outline,
                        controller: _managerNameController),

                    const SizedBox(height: 16),
                    _buildLabel('Téléphone personnel'),
                    _buildTextField(
                        hint: '+224 6XX XX XX XX',
                        icon: Icons.phone_iphone_outlined,
                        keyboardType: TextInputType.phone,
                        controller: _phoneController),

                    const SizedBox(height: 16),
                    _buildLabel('Email professionnel'),
                    _buildTextField(
                        hint: 'contact@syndicat.gn',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController),

                    const SizedBox(height: 24),
                    const Divider(height: 32, thickness: 1),

                    // Section: Sécurité
                    _buildSectionHeader('Sécurité du Compte'),
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
                    const Padding(
                      padding: EdgeInsets.only(top: 8, left: 4),
                      child: Text(
                          'Utilisez au moins 8 caractères avec des chiffres et symboles.',
                          style: TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey)),
                    ),

                    const SizedBox(height: 40),

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
                                  if (!context.mounted) return;
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
                                    roleKey: 'syndicate',
                                    metadata: {
                                      'represented_city': _selectedCity,
                                      'registration_number':
                                          _registrationController.text.trim(),
                                      'office_address':
                                          _addressController.text.trim(),
                                      'manager_name':
                                          _managerNameController.text.trim(),
                                    },
                                  );
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Compte syndicat créé ! Veuillez vous connecter.'),
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
                          elevation: 8,
                          shadowColor: primaryColor.withValues(alpha: 0.4),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.how_to_reg, size: 20),
                            SizedBox(width: 8),
                            Text('Finaliser l\'inscription',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),

                    const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      child: Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          text: "En cliquant sur finaliser, vous acceptez les ",
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                          children: [
                            TextSpan(
                                text: "Conditions Générales d'Utilisation",
                                style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline)),
                            TextSpan(text: " de GuineeTransport."),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Container(width: 4, height: 20, color: primaryColor),
          const SizedBox(width: 12),
          Text(title.toUpperCase(),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Colors.black87)),
    );
  }

  Widget _buildTextField({
    required String hint,
    IconData? icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggle,
    TextInputType? keyboardType,
    TextEditingController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon:
              icon != null ? Icon(icon, color: Colors.black45, size: 20) : null,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Colors.black45,
                      size: 18),
                  onPressed: onToggle)
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String hint,
    String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint,
              style: const TextStyle(color: Colors.grey, fontSize: 14)),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black45),
          items: options
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
