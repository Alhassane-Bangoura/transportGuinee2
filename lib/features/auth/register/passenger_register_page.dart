import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/auth_service.dart';
import '../login_page.dart';

class PassengerRegisterPage extends StatefulWidget {
  const PassengerRegisterPage({super.key});

  @override
  State<PassengerRegisterPage> createState() => _PassengerRegisterPageState();
}

class _PassengerRegisterPageState extends State<PassengerRegisterPage> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  static const Color primaryColor = Color(0xFF0AC247);
  static const Color backgroundColor = Color(0xFFF5F8F6);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Expanded(
                    child: Text(
                      'Inscription Passager',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Créer votre compte',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Veuillez remplir les informations ci-dessous pour commencer vos trajets avec GuineeTransport.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildFieldLabel('Nom complet'),
                    _buildTextField(
                        hint: 'Ex: Mamadou Diallo',
                        icon: Icons.person_outline,
                        controller: _nameController),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Numéro de téléphone'),
                    _buildTextField(
                        hint: '+224 6XX XX XX XX',
                        icon: Icons.phone_iphone_outlined,
                        keyboardType: TextInputType.phone,
                        controller: _phoneController),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Email'),
                    _buildTextField(
                        hint: 'votre@email.com',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Mot de passe'),
                    _buildTextField(
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: !_isPasswordVisible,
                      onSuffixTap: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible),
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Confirmer le mot de passe'),
                    _buildTextField(
                      hint: '••••••••',
                      icon: Icons.lock_reset_outlined,
                      isPassword: true,
                      obscureText: !_isConfirmPasswordVisible,
                      onSuffixTap: () => setState(() =>
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible),
                      controller: _confirmPasswordController,
                    ),

                    const SizedBox(height: 24),

                    // Emergency Contact Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: primaryColor.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.contact_emergency_outlined,
                                  color: primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Contact d’urgence',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildFieldLabel('Nom du contact'),
                          _buildTextField(
                              hint: 'Nom du proche',
                              isSmall: true,
                              controller: _emergencyNameController),
                          const SizedBox(height: 12),
                          _buildFieldLabel('Numéro du contact'),
                          _buildTextField(
                              hint: '+224 6XX XX XX XX',
                              isSmall: true,
                              keyboardType: TextInputType.phone,
                              controller: _emergencyPhoneController),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _acceptTerms,
                          onChanged: (v) =>
                              setState(() => _acceptTerms = v ?? false),
                          activeColor: primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: "J'accepte les ",
                              style: const TextStyle(
                                  fontSize: 14, color: Color(0xFF64748B)),
                              children: [
                                TextSpan(
                                    text: "Conditions d'Utilisation",
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold)),
                                const TextSpan(text: " et la "),
                                TextSpan(
                                    text: "Politique de Confidentialité",
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold)),
                                const TextSpan(text: " de GuineeTransport."),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (!_acceptTerms) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Veuillez accepter les conditions d\'utilisation'),
                                    ),
                                  );
                                  return;
                                }
                                 final email = _emailController.text.trim();
                                final phone = _phoneController.text.trim();
                                final name = _nameController.text.trim();
                                final password = _passwordController.text;

                                final nameError = name.isEmpty ? 'Le nom est obligatoire' : null;
                                final emailError = AuthService.validateEmail(email);
                                final phoneError = AuthService.validatePhone(phone);
                                final passwordError = password.length < 6 ? 'Le mot de passe doit contenir au moins 6 caractères' : null;

                                if (nameError != null || emailError != null || phoneError != null || passwordError != null) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(nameError ?? emailError ?? phoneError ?? passwordError ?? '')),
                                  );
                                  return;
                                }

                                setState(() => _isLoading = true);
                                try {
                                  await AuthService.signUp(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text,
                                    fullName: _nameController.text.trim(),
                                    phone: _phoneController.text.trim(),
                                    roleKey: 'passenger',
                                    metadata: {
                                      'emergency_name':
                                          _emergencyNameController.text.trim(),
                                      'emergency_phone':
                                          _emergencyPhoneController.text.trim(),
                                    },
                                  );

                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Compte créé avec succès ! Veuillez vous connecter.'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginPage()),
                                    (route) => false,
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;

                                  String errorMessage = e
                                          .toString()
                                          .contains('user_already_exists')
                                      ? 'Ce compte existe déjà. Veuillez vous connecter.'
                                      : 'Erreur : ${e.toString().replaceAll('AuthException: ', '')}';

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(errorMessage),
                                      action: e
                                              .toString()
                                              .contains('user_already_exists')
                                          ? SnackBarAction(
                                              label: 'SE CONNECTER',
                                              onPressed: () {
                                                if (!context.mounted) return;
                                                Navigator.of(context)
                                                      .pushReplacement(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const LoginPage()),
                                                );
                                              },
                                            )
                                          : null,
                                    ),
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
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 3),
                              )
                            : const Text('S\'inscrire',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Center(
                      child: Text.rich(
                        TextSpan(
                          text: "Déjà un compte ? ",
                          style: const TextStyle(color: Color(0xFF64748B)),
                          children: [
                            TextSpan(
                              text: "Se connecter",
                              style: const TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Navigator.maybePop(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    IconData? icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onSuffixTap,
    bool isSmall = false,
    TextInputType? keyboardType,
    TextEditingController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
          prefixIcon: icon != null
              ? Icon(icon, color: primaryColor.withValues(alpha: 0.7))
              : null,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFF94A3B8)),
                  onPressed: onSuffixTap,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16, vertical: isSmall ? 12 : 16),
        ),
      ),
    );
  }
}
